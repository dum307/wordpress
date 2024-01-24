#!/bin/bash
mysqldump -u root {{ mysql_db }} > {{ ansible_user_dir }}/{{ mysql_db }}_dump_$(date +'%Y%m%d%H%M')
