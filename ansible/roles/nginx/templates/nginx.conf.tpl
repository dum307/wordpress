server {
    listen {{ nginx_port }};
    server_name: {{ server_name }};

    location / {
        proxy_pass http://127.0.0.1:{{ apache_port }};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
