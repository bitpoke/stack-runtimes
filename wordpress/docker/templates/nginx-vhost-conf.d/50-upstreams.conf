# vim: set ft=nginx:

if ( $http_cookie ~ "wordpress_logged_in" ) { set $upstream 'php-critical'; }
if ( $uri ~ "/wp-login.php$" ) { set $upstream 'php-critical'; }
if ( $uri ~ "/wp-cron.php$" ) { set $upstream 'php-async'; }
