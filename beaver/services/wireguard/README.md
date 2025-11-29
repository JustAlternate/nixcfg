```
umask 077
mkdir -p /var/lib/wireguard
wg genkey > /var/lib/wireguard/server-private.key
wg pubkey < /var/lib/wireguard/server-private.key > /var/lib/wireguard/server-public.key

chmod 600 /var/lib/wireguard/*.key

cat /var/lib/wireguard/server-public.key
```
