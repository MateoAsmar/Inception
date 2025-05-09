#!/bin/sh

# Check for existing database
if [ ! -d "/var/lib/mysql/mysql" ]; then

    # Initialize database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null
    mysqld_safe --datadir=/var/lib/mysql &
    # Wait for startup
    sleep 5
    # Security configuration
    mysql -uroot <<SQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'%';
        FLUSH PRIVILEGES;
SQL

    # Clean shutdown
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
fi

# Start persistent server
exec mysqld_safe --datadir=/var/lib/mysql