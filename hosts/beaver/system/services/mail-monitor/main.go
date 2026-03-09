package main

import (
	"bufio"
	"crypto/tls"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/smtp"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// ---- Prometheus metrics ----

var (
	probeSuccess = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "mail_probe_success",
		Help: "1 if the last mail probe succeeded (send + receive), 0 otherwise",
	})
	probeDuration = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "mail_probe_duration_seconds",
		Help: "Total duration of the last mail probe in seconds",
	})
	smtpDuration = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "mail_smtp_duration_seconds",
		Help: "Duration of the SMTP send step in seconds",
	})
	imapDuration = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "mail_imap_duration_seconds",
		Help: "Duration of the IMAP receive step in seconds",
	})
	probeTimestamp = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "mail_probe_last_timestamp_seconds",
		Help: "Unix timestamp of the last probe execution",
	})
)

func init() {
	prometheus.MustRegister(probeSuccess)
	prometheus.MustRegister(probeDuration)
	prometheus.MustRegister(smtpDuration)
	prometheus.MustRegister(imapDuration)
	prometheus.MustRegister(probeTimestamp)
}

// ---- Config ----

type Config struct {
	SMTPHost       string
	SMTPPort       int
	IMAPHost       string
	IMAPPort       int
	MailFrom       string
	MailTo         string
	SMTPUser       string
	SMTPPassword   string
	IMAPUser       string
	IMAPPassword   string
	ProbeInterval  time.Duration
	ReceiveTimeout time.Duration
	MetricsPort    int
}

func loadConfig() Config {
	return Config{
		SMTPHost:       getEnv("SMTP_HOST", "localhost"),
		SMTPPort:       getEnvInt("SMTP_PORT", 465),
		IMAPHost:       getEnv("IMAP_HOST", "localhost"),
		IMAPPort:       getEnvInt("IMAP_PORT", 993),
		MailFrom:       getEnv("MAIL_FROM", "monitor@justalternate.com"),
		MailTo:         getEnv("MAIL_TO", "monitor@justalternate.com"),
		SMTPUser:       getEnv("SMTP_USER", "monitor@justalternate.com"),
		SMTPPassword:   getEnv("SMTP_PASSWORD", ""),
		IMAPUser:       getEnv("IMAP_USER", "monitor@justalternate.com"),
		IMAPPassword:   getEnv("IMAP_PASSWORD", ""),
		ProbeInterval:  getEnvDuration("PROBE_INTERVAL", 5*time.Minute),
		ReceiveTimeout: getEnvDuration("RECEIVE_TIMEOUT", 60*time.Second),
		MetricsPort:    getEnvInt("METRICS_PORT", 9116),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}

func getEnvDuration(key string, fallback time.Duration) time.Duration {
	if v := os.Getenv(key); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
	}
	return fallback
}

// ---- SMTP ----

// sendProbe sends a test email via SMTP with implicit TLS (port 465).
// Returns the unique subject used so IMAP can search for it.
func sendProbe(cfg Config) (subject string, elapsed time.Duration, err error) {
	subject = fmt.Sprintf("mail-monitor-probe-%d", time.Now().UnixNano())
	start := time.Now()

	addr := net.JoinHostPort(cfg.SMTPHost, strconv.Itoa(cfg.SMTPPort))
	body := fmt.Sprintf(
		"From: %s\r\nTo: %s\r\nSubject: %s\r\nDate: %s\r\n\r\nMail monitor probe. Please ignore.\r\n",
		cfg.MailFrom,
		cfg.MailTo,
		subject,
		time.Now().UTC().Format(time.RFC1123Z),
	)

	// localhost/127.0.0.1: skip TLS verification (internal cert)
	insecure := cfg.SMTPHost == "localhost" || cfg.SMTPHost == "127.0.0.1"
	tlsConfig := &tls.Config{
		ServerName:         cfg.SMTPHost,
		InsecureSkipVerify: insecure, //nolint:gosec
	}

	// Implicit TLS (SMTPS) — dial directly over TLS, no STARTTLS handshake needed
	tlsConn, dialErr := tls.DialWithDialer(
		&net.Dialer{Timeout: 15 * time.Second},
		"tcp",
		addr,
		tlsConfig,
	)
	if dialErr != nil {
		err = fmt.Errorf("SMTP dial: %w", dialErr)
		return
	}

	client, clientErr := smtp.NewClient(tlsConn, cfg.SMTPHost)
	if clientErr != nil {
		tlsConn.Close()
		err = fmt.Errorf("SMTP new client: %w", clientErr)
		return
	}
	defer client.Close()

	auth := smtp.PlainAuth("", cfg.SMTPUser, cfg.SMTPPassword, cfg.SMTPHost)
	if authErr := client.Auth(auth); authErr != nil {
		err = fmt.Errorf("SMTP auth: %w", authErr)
		return
	}

	if mailErr := client.Mail(cfg.MailFrom); mailErr != nil {
		err = fmt.Errorf("SMTP MAIL FROM: %w", mailErr)
		return
	}
	if rcptErr := client.Rcpt(cfg.MailTo); rcptErr != nil {
		err = fmt.Errorf("SMTP RCPT TO: %w", rcptErr)
		return
	}

	wc, dataErr := client.Data()
	if dataErr != nil {
		err = fmt.Errorf("SMTP DATA: %w", dataErr)
		return
	}
	if _, writeErr := fmt.Fprint(wc, body); writeErr != nil {
		wc.Close()
		err = fmt.Errorf("SMTP write body: %w", writeErr)
		return
	}
	if closeErr := wc.Close(); closeErr != nil {
		err = fmt.Errorf("SMTP close writer: %w", closeErr)
		return
	}
	client.Quit()

	elapsed = time.Since(start)
	return
}

// ---- Raw IMAP client ----

// imapConn is a minimal raw IMAP connection over TLS.
type imapConn struct {
	conn    net.Conn
	scanner *bufio.Scanner
	w       *bufio.Writer
	tagSeq  int
}

// dialIMAP opens a TLS connection to the IMAP server and reads the greeting.
func dialIMAP(addr string, tlsConfig *tls.Config) (*imapConn, error) {
	conn, err := tls.DialWithDialer(
		&net.Dialer{Timeout: 15 * time.Second},
		"tcp",
		addr,
		tlsConfig,
	)
	if err != nil {
		return nil, fmt.Errorf("TLS dial: %w", err)
	}

	c := &imapConn{
		conn:    conn,
		scanner: bufio.NewScanner(conn),
		w:       bufio.NewWriter(conn),
	}

	// Read the greeting (must start with "* OK")
	conn.SetReadDeadline(time.Now().Add(15 * time.Second))
	if !c.scanner.Scan() {
		conn.Close()
		if err := c.scanner.Err(); err != nil {
			return nil, fmt.Errorf("IMAP greeting read: %w", err)
		}
		return nil, fmt.Errorf("IMAP greeting: connection closed")
	}
	greeting := c.scanner.Text()
	if !strings.HasPrefix(greeting, "* OK") {
		conn.Close()
		return nil, fmt.Errorf("IMAP greeting unexpected: %q", greeting)
	}
	return c, nil
}

// cmd sends an IMAP command and returns the tag used.
func (c *imapConn) cmd(format string, args ...any) (string, error) {
	c.tagSeq++
	tag := fmt.Sprintf("T%d", c.tagSeq)
	line := tag + " " + fmt.Sprintf(format, args...) + "\r\n"
	c.conn.SetWriteDeadline(time.Now().Add(15 * time.Second))
	if _, err := c.w.WriteString(line); err != nil {
		return "", err
	}
	return tag, c.w.Flush()
}

// readUntilTagged reads server lines until it sees "<tag> OK/NO/BAD ...".
// Returns all collected untagged lines and the final status line.
func (c *imapConn) readUntilTagged(tag string) ([]string, error) {
	c.conn.SetReadDeadline(time.Now().Add(30 * time.Second))
	var untagged []string
	for c.scanner.Scan() {
		line := c.scanner.Text()
		if strings.HasPrefix(line, tag+" ") {
			rest := line[len(tag)+1:]
			if strings.HasPrefix(rest, "OK") {
				return untagged, nil
			}
			return untagged, fmt.Errorf("IMAP %s: %s", tag, rest)
		}
		untagged = append(untagged, line)
	}
	if err := c.scanner.Err(); err != nil {
		return nil, fmt.Errorf("IMAP read: %w", err)
	}
	return nil, fmt.Errorf("IMAP read: connection closed waiting for %s", tag)
}

// login sends LOGIN and waits for the tagged OK.
func (c *imapConn) login(user, password string) error {
	tag, err := c.cmd("LOGIN %s %s", user, password)
	if err != nil {
		return fmt.Errorf("IMAP LOGIN send: %w", err)
	}
	if _, err := c.readUntilTagged(tag); err != nil {
		return fmt.Errorf("IMAP LOGIN: %w", err)
	}
	return nil
}

// selectMailbox sends SELECT and waits for the tagged OK.
func (c *imapConn) selectMailbox(mailbox string) error {
	tag, err := c.cmd("SELECT %s", mailbox)
	if err != nil {
		return fmt.Errorf("IMAP SELECT send: %w", err)
	}
	if _, err := c.readUntilTagged(tag); err != nil {
		return fmt.Errorf("IMAP SELECT %s: %w", mailbox, err)
	}
	return nil
}

// search sends UID SEARCH HEADER Subject <subject> and returns matching UIDs.
func (c *imapConn) search(subject string) ([]string, error) {
	tag, err := c.cmd("UID SEARCH HEADER Subject %s", subject)
	if err != nil {
		return nil, fmt.Errorf("IMAP SEARCH send: %w", err)
	}
	lines, err := c.readUntilTagged(tag)
	if err != nil {
		return nil, fmt.Errorf("IMAP SEARCH: %w", err)
	}
	// Parse "* SEARCH 1 2 3" lines
	var uids []string
	for _, l := range lines {
		if strings.HasPrefix(l, "* SEARCH") {
			parts := strings.Fields(l)
			if len(parts) > 2 {
				uids = append(uids, parts[2:]...)
			}
		}
	}
	return uids, nil
}

// deleteUIDs marks UIDs as \Deleted and expunges them.
func (c *imapConn) deleteUIDs(uids []string) error {
	uidList := strings.Join(uids, ",")

	tag, err := c.cmd("UID STORE %s +FLAGS.SILENT (\\Deleted)", uidList)
	if err != nil {
		return fmt.Errorf("IMAP STORE send: %w", err)
	}
	if _, err := c.readUntilTagged(tag); err != nil {
		return fmt.Errorf("IMAP STORE: %w", err)
	}

	tag, err = c.cmd("EXPUNGE")
	if err != nil {
		return fmt.Errorf("IMAP EXPUNGE send: %w", err)
	}
	if _, err := c.readUntilTagged(tag); err != nil {
		return fmt.Errorf("IMAP EXPUNGE: %w", err)
	}
	return nil
}

// logout sends LOGOUT and closes the connection.
func (c *imapConn) logout() {
	tag, err := c.cmd("LOGOUT")
	if err == nil {
		c.readUntilTagged(tag) //nolint:errcheck
	}
	c.conn.Close()
}

// ---- IMAP high-level operations ----

// findAndDeleteMail connects to IMAP, searches INBOX for the subject,
// marks matching messages as \Deleted, expunges them. Returns true if found.
func findAndDeleteMail(addr, user, password, subject string, tlsConfig *tls.Config) (bool, error) {
	c, err := dialIMAP(addr, tlsConfig)
	if err != nil {
		return false, err
	}
	defer c.logout()

	if err := c.login(user, password); err != nil {
		return false, err
	}
	if err := c.selectMailbox("INBOX"); err != nil {
		return false, err
	}

	uids, err := c.search(subject)
	if err != nil {
		return false, err
	}
	if len(uids) == 0 {
		return false, nil
	}

	if err := c.deleteUIDs(uids); err != nil {
		return false, err
	}

	log.Printf("[imap] found and deleted mail with subject %q (uids: %v)", subject, uids)
	return true, nil
}

// waitForMail polls IMAP until the probe mail with the given subject arrives
// or the deadline is reached. It deletes the mail after finding it.
func waitForMail(cfg Config, subject string, deadline time.Time) (elapsed time.Duration, err error) {
	start := time.Now()

	insecure := cfg.IMAPHost == "localhost" || cfg.IMAPHost == "127.0.0.1"
	tlsConfig := &tls.Config{
		ServerName:         cfg.IMAPHost,
		InsecureSkipVerify: insecure, //nolint:gosec
	}
	addr := net.JoinHostPort(cfg.IMAPHost, strconv.Itoa(cfg.IMAPPort))

	for {
		if time.Now().After(deadline) {
			err = fmt.Errorf("timeout waiting for mail with subject %q", subject)
			elapsed = time.Since(start)
			return
		}

		found, findErr := findAndDeleteMail(addr, cfg.IMAPUser, cfg.IMAPPassword, subject, tlsConfig)
		if findErr != nil {
			log.Printf("[imap] error searching for mail: %v", findErr)
		} else if found {
			elapsed = time.Since(start)
			return
		}

		time.Sleep(5 * time.Second)
	}
}

// ---- Cleanup ----

// cleanupOldProbes removes any stale probe mails left in INBOX
// (e.g. from a previous run that crashed before cleanup).
func cleanupOldProbes(cfg Config) {
	insecure := cfg.IMAPHost == "localhost" || cfg.IMAPHost == "127.0.0.1"
	tlsConfig := &tls.Config{
		ServerName:         cfg.IMAPHost,
		InsecureSkipVerify: insecure, //nolint:gosec
	}
	addr := net.JoinHostPort(cfg.IMAPHost, strconv.Itoa(cfg.IMAPPort))

	c, err := dialIMAP(addr, tlsConfig)
	if err != nil {
		log.Printf("[cleanup] IMAP dial error: %v", err)
		return
	}
	defer c.logout()

	if err := c.login(cfg.IMAPUser, cfg.IMAPPassword); err != nil {
		log.Printf("[cleanup] IMAP login error: %v", err)
		return
	}
	if err := c.selectMailbox("INBOX"); err != nil {
		log.Printf("[cleanup] IMAP SELECT error: %v", err)
		return
	}

	uids, err := c.search("mail-monitor-probe-")
	if err != nil {
		log.Printf("[cleanup] IMAP SEARCH error: %v", err)
		return
	}
	if len(uids) == 0 {
		log.Println("[cleanup] no stale probe mails found")
		return
	}

	log.Printf("[cleanup] found %d stale probe mail(s), deleting...", len(uids))
	if err := c.deleteUIDs(uids); err != nil {
		log.Printf("[cleanup] delete error: %v", err)
		return
	}
	log.Printf("[cleanup] deleted %d stale probe mail(s)", len(uids))
}

// ---- Probe loop ----

func runProbe(cfg Config, mu *sync.Mutex) {
	log.Println("[probe] starting mail probe")
	start := time.Now()

	// Step 1 — Send via SMTP
	subject, smtpElapsed, smtpErr := sendProbe(cfg)
	mu.Lock()
	smtpDuration.Set(smtpElapsed.Seconds())
	mu.Unlock()

	if smtpErr != nil {
		log.Printf("[probe] SMTP send failed: %v", smtpErr)
		mu.Lock()
		probeSuccess.Set(0)
		probeDuration.Set(time.Since(start).Seconds())
		probeTimestamp.Set(float64(time.Now().Unix()))
		mu.Unlock()
		return
	}
	log.Printf("[probe] mail sent (subject=%s) in %.2fs", subject, smtpElapsed.Seconds())

	// Step 2 — Wait for reception via IMAP
	deadline := time.Now().Add(cfg.ReceiveTimeout)
	_, imapErr := waitForMail(cfg, subject, deadline)

	mu.Lock()
	defer mu.Unlock()

	totalElapsed := time.Since(start)
	probeDuration.Set(totalElapsed.Seconds())
	probeTimestamp.Set(float64(time.Now().Unix()))

	if imapErr != nil {
		log.Printf("[probe] IMAP receive failed: %v", imapErr)
		probeSuccess.Set(0)
		imapDuration.Set(cfg.ReceiveTimeout.Seconds())
		return
	}

	imapElapsed := totalElapsed - smtpElapsed
	imapDuration.Set(imapElapsed.Seconds())
	probeSuccess.Set(1)
	log.Printf("[probe] SUCCESS — total=%.2fs smtp=%.2fs imap=%.2fs",
		totalElapsed.Seconds(), smtpElapsed.Seconds(), imapElapsed.Seconds())
}

// ---- Main ----

func main() {
	cfg := loadConfig()

	log.Printf("[main] mail-monitor starting — probe every %s, receive timeout %s, metrics port %d",
		cfg.ProbeInterval, cfg.ReceiveTimeout, cfg.MetricsPort)

	if cfg.SMTPPassword == "" || cfg.IMAPPassword == "" {
		log.Fatal("[main] SMTP_PASSWORD and IMAP_PASSWORD must be set")
	}

	// On startup, clean up any stale probe mails from a previous crashed run
	log.Println("[main] running startup cleanup...")
	cleanupOldProbes(cfg)

	var mu sync.Mutex

	// Run first probe immediately
	go runProbe(cfg, &mu)

	// Periodic probe ticker
	probeTicker := time.NewTicker(cfg.ProbeInterval)
	defer probeTicker.Stop()

	// Periodic cleanup ticker (every 6 hours) as a safety net
	cleanupTicker := time.NewTicker(6 * time.Hour)
	defer cleanupTicker.Stop()

	// HTTP server: /metrics and /health
	mux := http.NewServeMux()
	mux.Handle("/metrics", promhttp.Handler())
	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
	})
	srv := &http.Server{
		Addr:         fmt.Sprintf("127.0.0.1:%d", cfg.MetricsPort),
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}
	go func() {
		log.Printf("[main] metrics listening on 127.0.0.1:%d", cfg.MetricsPort)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("[main] metrics server error: %v", err)
		}
	}()

	for {
		select {
		case <-probeTicker.C:
			go runProbe(cfg, &mu)
		case <-cleanupTicker.C:
			log.Println("[main] running periodic cleanup...")
			go cleanupOldProbes(cfg)
		}
	}
}
