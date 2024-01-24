<VirtualHost 127.0.0.1:{{ apache_port }}>
    DocumentRoot {{ wordpress_root }}
    <Directory {{ wordpress_root }}>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory {{ wordpress_root }}/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
