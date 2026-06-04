#!/bin/sh
set -e

if [ "$PGBOUNCER_ENABLED" != "true" ]; then
    exec supervisord -c /etc/supervisord.conf
fi

PGBOUNCER_DATABASES="${PGBOUNCER_DATABASES:-default}"

DEFAULT_POOL_SIZE="${PGBOUNCER_DEFAULT_POOL_SIZE:-5}"
MIN_POOL_SIZE="${PGBOUNCER_MIN_POOL_SIZE:-1}"
RESERVE_POOL_SIZE="${PGBOUNCER_RESERVE_POOL_SIZE:-2}"
MAX_CLIENT_CONN="${PGBOUNCER_MAX_CLIENT_CONN:-1000}"
MAX_PREPARED_STATEMENTS="${PGBOUNCER_MAX_PREPARED_STATEMENTS:-100}"
SERVER_IDLE_TIMEOUT="${PGBOUNCER_SERVER_IDLE_TIMEOUT:-300}"
SERVER_LIFETIME="${PGBOUNCER_SERVER_LIFETIME:-3600}"

validate_alias() {
    case "$1" in
        *[!A-Za-z0-9_]*|"")
            echo "entrypoint: invalid PGBOUNCER_DATABASES alias '$1' (allowed: [A-Za-z0-9_])" >&2
            exit 1
            ;;
    esac
}

resolve_prefix() {
    if [ "$1" = "default" ]; then
        echo "POSTGRES_DB"
    else
        echo "POSTGRES_DB_$(echo "$1" | tr '[:lower:]' '[:upper:]')"
    fi
}

echo "[databases]" > /etc/pgbouncer/pgbouncer.ini

OLD_IFS="$IFS"
IFS=','
for alias in $PGBOUNCER_DATABASES; do
    IFS="$OLD_IFS"
    alias=$(echo "$alias" | tr -d ' ')
    if [ -n "$alias" ]; then
        validate_alias "$alias"
        prefix=$(resolve_prefix "$alias")
        host=$(eval "printf '%s' \"\${${prefix}_HOST:-}\"")
        port=$(eval "printf '%s' \"\${${prefix}_PORT:-5432}\"")
        name=$(eval "printf '%s' \"\${${prefix}_NAME:-}\"")
        user=$(eval "printf '%s' \"\${${prefix}_USERNAME:-}\"")
        pass=$(eval "printf '%s' \"\${${prefix}_PASSWORD:-}\"")

        [ -z "$host" ] && { echo "entrypoint: ${prefix}_HOST is required for alias '${alias}'" >&2; exit 1; }
        [ -z "$name" ] && { echo "entrypoint: ${prefix}_NAME is required for alias '${alias}'" >&2; exit 1; }
        [ -z "$user" ] && { echo "entrypoint: ${prefix}_USERNAME is required for alias '${alias}'" >&2; exit 1; }
        [ -z "$pass" ] && { echo "entrypoint: ${prefix}_PASSWORD is required for alias '${alias}'" >&2; exit 1; }

        echo "pgb_${alias} = host=${host} port=${port} dbname=${name} user=${user} password=${pass}" >> /etc/pgbouncer/pgbouncer.ini
    fi
    IFS=','
done
IFS="$OLD_IFS"

cat >> /etc/pgbouncer/pgbouncer.ini <<EOF

[pgbouncer]
listen_addr = 127.0.0.1
listen_port = 6432
auth_type = any
pool_mode = transaction
default_pool_size = ${DEFAULT_POOL_SIZE}
min_pool_size = ${MIN_POOL_SIZE}
reserve_pool_size = ${RESERVE_POOL_SIZE}
max_client_conn = ${MAX_CLIENT_CONN}
max_prepared_statements = ${MAX_PREPARED_STATEMENTS}
server_idle_timeout = ${SERVER_IDLE_TIMEOUT}
server_lifetime = ${SERVER_LIFETIME}
log_connections = 0
log_disconnections = 0
log_stats = 0
logfile = /dev/stderr
pidfile = /var/run/pgbouncer/pgbouncer.pid
EOF

cat > /etc/supervisor.d/pgbouncer.ini <<EOF
[program:pgbouncer]
command=pgbouncer /etc/pgbouncer/pgbouncer.ini
autostart=true
autorestart=true
priority=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

IFS=','
for alias in $PGBOUNCER_DATABASES; do
    IFS="$OLD_IFS"
    alias=$(echo "$alias" | tr -d ' ')
    if [ -n "$alias" ]; then
        validate_alias "$alias"
        prefix=$(resolve_prefix "$alias")
        eval "export ${prefix}_HOST=127.0.0.1"
        eval "export ${prefix}_PORT=6432"
        eval "export ${prefix}_NAME=pgb_${alias}"
        eval "export ${prefix}_READ_HOST=127.0.0.1"
        eval "export ${prefix}_READ_PORT=6432"
    fi
    IFS=','
done
IFS="$OLD_IFS"

exec supervisord -c /etc/supervisord.conf
