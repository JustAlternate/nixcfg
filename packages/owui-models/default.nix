{
  writeShellApplication,
  curl,
  jq,
  sqlite,
  coreutils,
  gnugrep,
}:
writeShellApplication {
  name = "owui-models";

  runtimeInputs = [
    curl
    jq
    sqlite
    coreutils
    gnugrep
  ];

  text = ''
    set -euo pipefail

    DB="''${OWUI_DB:-/var/lib/open-webui/data/webui.db}"

    usage() {
      cat <<'EOF'
    Usage: owui-models [--apply]

    Reconciles the Open WebUI model table with the configured provider catalog.

    In Open WebUI 0.11 an override row has base_model_id = NULL and shares its id
    with a provider model. When such a row is INACTIVE (is_active = 0), the
    provider model is removed from the model selector (utils/models.py
    get_all_models). That is why models silently disappear after using the
    Admin -> Models create/sync UI.

    This command removes the leftover inactive override rows so every provider
    model is visible, while keeping active overrides (is_active = 1) intact.

    Options:
      --apply   actually delete the rows (default: dry run)
      -h, --help
    EOF
    }

    APPLY=0
    for arg in "$@"; do
      case "$arg" in
        --apply) APPLY=1 ;;
        -h | --help)
          usage
          exit 0
          ;;
        *)
          echo "unknown argument: $arg" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    [[ -f "$DB" ]] || {
      echo "database not found: $DB" >&2
      exit 1
    }

    urls=$(sqlite3 "$DB" "SELECT value FROM config WHERE key = 'openai.api_base_urls';")
    keys=$(sqlite3 "$DB" "SELECT value FROM config WHERE key = 'openai.api_keys';")

    total_provider=0
    if [[ -n "$urls" && "$urls" != "null" ]]; then
      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT

      count=$(jq 'length' <<<"$urls")
      for ((i = 0; i < count; i++)); do
        url=$(jq -r ".[$i]" <<<"$urls")
        key=$(jq -r ".[$i] // empty" <<<"$keys" 2>/dev/null || true)

        args=(-fsS -m 20)
        if [[ -n "$key" ]]; then
          args+=(-H "Authorization: Bearer $key")
        fi

        echo "  fetching $url ..." >&2
        if response=$(curl "''${args[@]}" "$url/models"); then
          jq -r '.data[]?.id // empty' <<<"$response" >>"$tmp"
        else
          echo "  warning: could not reach $url" >&2
        fi
      done

      total_provider=$(sort -u "$tmp" | grep -c . || true)
    fi

    inactive=$(sqlite3 "$DB" "SELECT COUNT(*) FROM model WHERE base_model_id IS NULL AND is_active = 0;")
    active=$(sqlite3 "$DB" "SELECT COUNT(*) FROM model WHERE base_model_id IS NULL AND is_active = 1;")

    echo
    echo "database:        $DB"
    echo "provider models: $total_provider"
    echo "override rows:   $active active, $inactive inactive"
    echo

    if [[ "$inactive" == "0" ]]; then
      echo "nothing to do."
      exit 0
    fi

    if [[ "$APPLY" != "1" ]]; then
      echo "dry run: would delete $inactive inactive override row(s)."
      echo "re-run with --apply to apply."
      exit 0
    fi

    sqlite3 "$DB" <<'SQL'
    BEGIN;
    DELETE FROM model WHERE base_model_id IS NULL AND is_active = 0;
    COMMIT;
    PRAGMA wal_checkpoint(TRUNCATE);
    SQL

    echo "deleted $inactive inactive override row(s); $active active override(s) kept."
    echo "hard-refresh the Open WebUI page to see the models."
  '';
}
