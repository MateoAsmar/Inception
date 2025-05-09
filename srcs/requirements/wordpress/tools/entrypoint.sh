#!/bin/sh

# Verify MariaDB connectivity before proceeding
DB_HOST=mariadb
until mysqladmin ping -h "$DB_HOST" -u root -p"${MYSQL_ROOT_PASSWORD}" --silent
do
    echo "Waiting for database connection..."
    sleep 5
done

# Clear existing installation if present
WP_DIR="/var/www/html"
if [ -f "${WP_DIR}/wp-config.php" ] || [ -d "${WP_DIR}/wp-content" ]; then
    printf "Removing existing WordPress files...\n"
    find "$WP_DIR" -mindepth 1 -delete
fi

# Install WordPress if not configured
if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    wp core download --allow-root --path="$WP_DIR"
    
    WP_DB_SETTINGS="--dbhost=mariadb:3306 \
                    --dbname=${MYSQL_DATABASE} \
                    --dbuser=${MYSQL_USER} \
                    --dbpass=${MYSQL_PASSWORD}"
    
    wp config create $WP_DB_SETTINGS \
       --path="$WP_DIR" \
       --allow-root

    wp core install --path="$WP_DIR" \
       --url="https://${DOMAIN_NAME}" \
       --title="Inception Project" \
       --admin_email="${WP_ADMIN_EMAIL}" \
       --admin_user="${WP_ADMIN_USER}" \
       --admin_password="${WP_ADMIN_PASSWORD}" \
       --skip-email \
       --allow-root
fi

exec php-fpm82 -F