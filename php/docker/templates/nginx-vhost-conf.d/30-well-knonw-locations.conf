# vim: set ft=nginx:

location ~ /\. {
    return 403;
}

location = /favicon.ico {
    log_not_found  off;
    try_files $uri =404;
}

location = /apple-touch-icon.png {
    log_not_found  off;
    try_files $uri =404;
}

location = /apple-touch-icon-precomposed.png {
    log_not_found  off;
    try_files $uri =404;
}

location = /crossdomain.xml {
    try_files $uri =404;
}
