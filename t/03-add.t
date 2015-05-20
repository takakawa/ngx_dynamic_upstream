use lib 'lib';
use Test::Nginx::Socket;

#repeat_each(2);

plan tests => repeat_each() * 2 * blocks();

run_tests();

__DATA__

=== TEST 1: add
--- http_config
    upstream backends {
        zone zone_for_backends 128k;
        server 127.0.0.1:6001;
        server 127.0.0.1:6002;
        server 127.0.0.1:6003;
    }
--- config
    location /dynamic {
        dynamic_upstream;
    }
--- request
    GET /dynamic?upstream=zone_for_backends&server=127.0.0.1:6004&add=
--- response_body
127.0.0.1:6001;
127.0.0.1:6002;
127.0.0.1:6003;
127.0.0.1:6004;


=== TEST 2: add and update parameters
--- http_config
    upstream backends {
        zone zone_for_backends 128k;
        server 127.0.0.1:6001;
        server 127.0.0.1:6002;
        server 127.0.0.1:6003;
    }
--- config
    location /dynamic {
        dynamic_upstream;
    }
--- request
    GET /dynamic?upstream=zone_for_backends&server=127.0.0.1:6004&add=&weight=10
--- response_body
127.0.0.1:6001 weight=1 max_fails=1 fail_timeout=10;
127.0.0.1:6002 weight=1 max_fails=1 fail_timeout=10;
127.0.0.1:6003 weight=1 max_fails=1 fail_timeout=10;
127.0.0.1:6004 weight=10 max_fails=1 fail_timeout=10;


=== TEST 4: fail to add
--- http_config
    upstream backends {
        zone zone_for_backends 128k;
        server 127.0.0.1:6001;
        server 127.0.0.1:6002;
        server 127.0.0.1:6003;
    }
--- config
    location /dynamic {
        dynamic_upstream;
    }
--- request
    GET /dynamic?upstream=zone_for_backends&server=127.0.0.1:6003&add=
--- response_body_like: 500 Internal Server Error
--- error_code: 500
