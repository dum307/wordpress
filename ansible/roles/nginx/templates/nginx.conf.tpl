server {
        listen {{ http_port }};
        root /var/www/{{ http_host }};
        index index.php index.html index.htm index.nginx-debian.html;
        server_name {{ http_host }};

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}
