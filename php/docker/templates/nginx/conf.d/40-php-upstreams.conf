# vim: set ft=nginx:

# php main pool for general purpose use
upstream php {
    server unix:/var/run/php-www.sock;
}

# php main pool configured with a backup pool
# admin requests should be routed here so that they can go trough even if the main pool is busy
upstream php-critical {
    server unix:/var/run/php-www.sock;
    server unix:/var/run/php-www-backup.sock backup;
}

# php pool for running async background tasks
upstream php-async {
    server unix:/var/run/php-www-async.sock;
}
