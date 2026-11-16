#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ -f .env.local ]]; then
    source ./.env.local
fi
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/jbr-21.0.11/Contents/Home"
export CATALINA_BASE=/private/tmp/rms-tomcat
export RMS_DB_URL='jdbc:mysql://127.0.0.1:13316/restaurant_management'

mysql_bin=/usr/local/mysql/bin
mysql_data=/private/tmp/rms-mysql-int
mysql_socket=/private/tmp/rms-mysql-int.sock
tomcat=/private/tmp/rms-tools/apache-tomcat-9.0.111/bin/catalina.sh
maven=/private/tmp/rms-tools/apache-maven-3.9.11/bin/mvn
web_url=http://127.0.0.1:18081/restaurant-management/LoginFrm1.jsp
deploy_war="$CATALINA_BASE/webapps/restaurant-management.war"

if [[ ! -d "$mysql_data/restaurant_management" || ! -d "$CATALINA_BASE/webapps" ||
      ! -x "$JAVA_HOME/bin/java" || ! -x "$maven" || ! -x "$tomcat" ||
      ! -x "$mysql_bin/mysqld" || ! -x "$mysql_bin/mysql" ]]; then
    printf '%s\n' 'Thiếu bộ cài hoặc dữ liệu cục bộ của Restaurant Management.' >&2
    exit 1
fi

database_ready() {
    "$mysql_bin/mysql" --no-defaults --no-login-paths --protocol=SOCKET \
        --socket="$mysql_socket" --connect-timeout=2 -u root \
        --batch --skip-column-names restaurant_management -e 'SELECT @@port' 2>/dev/null |
        grep -qx '13316'
}

if ! database_ready; then
    if nc -z -w 1 127.0.0.1 13316 2>/dev/null; then
        printf '%s\n' 'Cổng 13316 đang bận nhưng chưa xác nhận được MySQL của dự án.' >&2
        exit 1
    fi
    if ! lsof -t "$mysql_data/ibdata1" >/dev/null 2>&1; then
        printf '%s\n' 'Đang khởi động MySQL của dự án…'
        "$mysql_bin/mysqld" --no-defaults --basedir=/usr/local/mysql --datadir="$mysql_data" \
            --bind-address=127.0.0.1 --port=13316 --socket="$mysql_socket" \
            --pid-file="$mysql_data/mysql.pid" --mysqlx=OFF --daemonize \
            --log-error="$mysql_data/mysql-local.log"
    fi
    for ((attempt=0; attempt<20; attempt++)); do
        if database_ready; then
            break
        fi
        sleep 1
    done
    if ! database_ready; then
        printf '%s\n' "MySQL chưa sẵn sàng. Xem log tại $mysql_data/mysql-local.log." >&2
        exit 1
    fi
fi

"$maven" -o -Dmaven.repo.local=/private/tmp/rms-maven package
if ! cmp -s target/restaurant-management.war "$deploy_war"; then
    staged_war=$(mktemp "$CATALINA_BASE/webapps/.rms-war.XXXXXX")
    trap 'rm -f "$staged_war"' EXIT
    cp target/restaurant-management.war "$staged_war"
    mv -f "$staged_war" "$deploy_war"
fi

if ! nc -z -w 1 127.0.0.1 18081 2>/dev/null; then
    "$tomcat" start
fi

for ((attempt=0; attempt<25; attempt++)); do
    # Tomcat updates the unpacked WAR timestamp when it redeploys.
    if [[ ! "$deploy_war" -nt "$CATALINA_BASE/webapps/restaurant-management/META-INF/war-tracker" ]] &&
        curl --noproxy '*' -fsS --max-time 2 "$web_url" | grep -q 'Manager Login'; then
        printf 'Restaurant Management: %s\n' "$web_url"
        if [[ "${RMS_NO_OPEN:-}" != 1 ]]; then
            /usr/bin/open "$web_url"
        fi
        exit 0
    fi
    sleep 1
done
printf '%s\n' "Tomcat chưa phục vụ bản web vừa build. Xem log trong $CATALINA_BASE/logs." >&2
exit 1
