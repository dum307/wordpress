#!/bin/bash

# Файлы-флаги
APACHE_FLAG="/tmp/apache_installed.flag"
MYSQL_FLAG="/tmp/mysql_installed.flag"
PHP_FLAG="/tmp/php_installed.flag"
WORDPRESS_FLAG="/tmp/wordpress_installed.flag"
NGINX_FLAG="/tmp/nginx_installed.flag"
TG_FLAG="/tmp/telegram_notification.flag"

# Переменные для конфигурации
MYSQL_ROOT_PASSWORD="your_mysql_root_password"
WORDPRESS_DB_USER="wordpress_user"
WORDPRESS_DB_PASSWORD="wordpress_password"
WORDPRESS_DB_NAME="wordpress_db"
TG_TOKEN=
TG_CHAT_ID=


# Функция для отправки уведомления в телеграм
send_telegram_notification() {
    curl -s -X POST https://api.telegram.org/bot${TG_TOKEN}/sendMessage?chat_id=${TG_CHAT_ID} --data-urlencode text="Installation Complete"
    touch $TG_FLAG
}

# Функция для установки и настройки Apache2
install_and_configure_apache() {
    if [ ! -e "$APACHE_FLAG" ]; then
        apt-get update
        apt-get install -y apache2
        cp wordpress.conf /etc/apache2/sites-available/
	a2dissite 000-default.conf
	a2ensite wordpress.conf
	sed -i "s/80/127.0.0.1:8080/" /etc/apache2/ports.conf
        systemctl restart apache2
        touch $APACHE_FLAG
    fi
}

# Функция для установки и настройки MySQL (MariaDB)
install_and_configure_mysql() {
    if [ ! -e "$MYSQL_FLAG" ]; then
        apt-get install -y mariadb-server
        mysql -e "CREATE DATABASE $WORDPRESS_DB_NAME;"
        mysql -e "CREATE USER '$WORDPRESS_DB_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';"
        mysql -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
        systemctl restart mariadb
        touch $MYSQL_FLAG
    fi
}

# Функция для установки и настройки PHP
install_and_configure_php() {
    if [ ! -e "$PHP_FLAG" ]; then
        apt-get install -y php libapache2-mod-php php-mysql
        touch $PHP_FLAG
    fi
}

# Функция для установки и настройки WordPress
install_and_configure_wordpress() {
    if [ ! -e "$WORDPRESS_FLAG" ]; then
        wget https://wordpress.org/latest.tar.gz
        tar -xzvf latest.tar.gz -C /var/www/
        cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
        sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/wordpress/wp-config.php
        sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/wordpress/wp-config.php
        sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/wordpress/wp-config.php
        chown -R www-data:www-data /var/www/wordpress
        chmod -R 755 /var/www/wordpress
        touch $WORDPRESS_FLAG
    fi
}

# Функция для установки и настройки Nginx
install_and_configure_nginx() {
    if [ ! -e "$NGINX_FLAG" ]; then
        apt-get install -y nginx
        rm -rf /etc/nginx/sites-enabled/default
	cp proxy.conf /etc/nginx/sites-available/
	ln -s /etc/nginx/sites-available/proxy.conf /etc/nginx/sites-enabled/
        systemctl restart nginx
        touch $NGINX_FLAG
    fi
}

# Проверяем наличие файлов-флагов для определения успешно выполненных шагов
if [ -e "$EMAIL_FLAG" ]; then
    echo "Email notification already sent. Skipping installation."
else
    install_and_configure_apache
    install_and_configure_mysql
    install_and_configure_php
    install_and_configure_wordpress
    install_and_configure_nginx

    # Отправляем уведомление в телеграм
    send_telegram_notification

    echo "Installation completed successfully."
fi
