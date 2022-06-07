# demo1
- new,2022-05-24,chenxizhan1995@163.com

## 使用 nginx:1.21 做练习

首先取得镜像的默认 nginx 配置。
把镜像内的 /etc/nginx/ 目录复制到到 nginx-default/。

### 附：获取 nginx:1.21 默认配置

cdh3 上执行
```
docker run -dit --name tmp nginx:1.21
docker cp tmp:/etc/nginx nginx
docker rm -f tmp
```
在本地执行
````bash
scp -r chen@cdh3:nginx default-nginx
````

执行时会有一句报错：
```
scp: /usr/.home/chen/nginx/modules: No such file or directory
```
在 cdh3 上可以看到该路径是一个符号链接 `modules -> /usr/lib/nginx/modules`

去容器内看此目录，内容如下
```
root@8f2bf58277d3:/# ls -lh /usr/lib/nginx/modules
total 3.6M
-rw-r--r-- 1 root root  20K Jan 25 15:13 ngx_http_geoip_module-debug.so
-rw-r--r-- 1 root root  20K Jan 25 15:13 ngx_http_geoip_module.so
-rw-r--r-- 1 root root  27K Jan 25 15:13 ngx_http_image_filter_module-debug.so
-rw-r--r-- 1 root root  27K Jan 25 15:13 ngx_http_image_filter_module.so
-rw-r--r-- 1 root root 874K Jan 25 15:13 ngx_http_js_module-debug.so
-rw-r--r-- 1 root root 870K Jan 25 15:13 ngx_http_js_module.so
-rw-r--r-- 1 root root  23K Jan 25 15:13 ngx_http_xslt_filter_module-debug.so
-rw-r--r-- 1 root root  23K Jan 25 15:13 ngx_http_xslt_filter_module.so
-rw-r--r-- 1 root root  20K Jan 25 15:13 ngx_stream_geoip_module-debug.so
-rw-r--r-- 1 root root  20K Jan 25 15:13 ngx_stream_geoip_module.so
-rw-r--r-- 1 root root 852K Jan 25 15:13 ngx_stream_js_module-debug.so
-rw-r--r-- 1 root root 848K Jan 25 15:13 ngx_stream_js_module.so
```
## 尝试精简配置
```
user nginx;
events {}
http {
  server {
    listen 80;
    return 200 "$time_iso8601\n";
  }
}
```
```
user nginx;
work_processes auto;
error_log /var/log/nginx/error.log info;
pid /var/run/nginx.pid;
events {}
http {
    server {
        listent 80;
        root /usr/share/nginx/html;

        location / {
            index index.hmtl index.htm;
        }

        error_page 500 502 503 504 /50x.html
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
```
## user
```
Syntax: 	user user [group];
Default:

user nobody nobody;

Context: 	main
```
得加上。
## error_log logs/error.log error;

```
Syntax: 	error_log file [level];
Default:

error_log logs/error.log error;

Context: 	main, http, mail, stream, server, location
```

第二个参数是日志级别，从低到高依次为：
```
debug, info, notice, warn, error, crit, alert, or emerg.
```

Q. 相对路径从何处算起？
Ans：难道是从 ./configure --prefix=/usr/share/nginx 算起？

`nginx -V` 可查看nginx编译参数。`configure arguments: --prefix=/usr/share/nginx`

## pid
```
Syntax: 	pid file;
Default:

pid logs/nginx.pid;

Context: 	main
```
## worker_processes 1;
```
Syntax: 	worker_processes number | auto;
Default:

worker_processes 1;

Context: 	main
```
这个也省略掉。
## events
无默认值。

不能省略，如果缺少，启动时报错
```
nginx: [emerg] no "events" section in configuration
```

所以放一个空的 `events{}`
## work_connections
```
Syntax: 	worker_connections number;
Default:

worker_connections 512;

Context: 	events
```
## http
http 配置不能省略，否则启动会卡在下面这里，并不能提供服务。
```
/docker-entrypoint.sh: Configuration complete; ready for start up
```

访问的时候也会报错
```
curl -w "\n" localhost/hello

curl: (56) Recv failure: Connection reset by peer
make: *** [hello] 错误 56
```

## types
[Module ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html#types)
```
Syntax: 	types { ... }
Default:

types {
    text/html  html;
    image/gif  gif;
    image/jpeg jpg;
}

Context: 	http, server, location
```

Maps file name extensions to MIME types of responses. Extensions are case-insensitive. Several extensions can be mapped to one type, for example:
```
    types {
        application/octet-stream bin exe dll;
        application/octet-stream deb;
        application/octet-stream dmg;
    }
```

nginx 发行版自带 conf/mime.type 文件，内含完整的映射。

若要设置某个 location 一律响应 “application/octet-stream” MIME 类型，可以使用如下配置：
```
    location /download/ {
        types        { }
        default_type application/octet-stream;
    }
```

## default_type
[Module ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html#default_type)

```
Syntax: 	default_type mime-type;
Default:

default_type text/plain;

Context: 	http, server, location
```

Defines the default MIME type of a response. Mapping of file name extensions to MIME types can be set with the types directive.

## log_format
```
Syntax: 	log_format name [escape=default|json|none] string ...;
Default:

log_format combined "...";

Context: 	http
```
nginx 提供预定义log_format
```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```
## access_log

```
Syntax: 	access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;
Default: `access_log logs/access.log combined;

Context: 	http, server, location, if in location, limit_except
```
## sendfile
```
Syntax: 	sendfile on | off;
Default:
sendfile off;
Context: 	http, server, location, if in location
```

sendfile系统调用在两个文件描述符之间直接传递数据(完全在内核中操作)，从而避免了数据在
内核缓冲区和用户缓冲区之间的拷贝，操作效率很高，被称之为零拷贝。

[nginx中配置sendfile及详细说明](https://www.jianshu.com/p/70e1c396c320)

## keepalive_timeout
[Module ngx_http_core_module](https://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout)
默认值 75，nginx 镜像显式设置 65，省略。

```
Syntax: 	keepalive_timeout timeout [header_timeout];
Default:
keepalive_timeout 75s;
Context: 	http, server, location
```

The first parameter sets a timeout during which a keep-alive client connection will stay open on the server side. The zero value disables keep-alive client connections. The optional second parameter sets a value in the “Keep-Alive: timeout=time” response header field. Two parameters may differ.

The “Keep-Alive: timeout=time” header field is recognized by Mozilla and Konqueror. MSIE closes keep-alive connections by itself in about 60 seconds.
## error_page
```
Syntax: 	error_page code ... [=[response]] uri;
Default: 	—
Context: 	http, server, location, if in location
```

Defines the URI that will be shown for the specified errors. A uri value can contain variables.
```
    error_page 404             /404.html;
    error_page 500 502 503 504 /50x.html;
```
This causes an internal redirect to the specified uri with the client request method changed to “GET” (for all methods other than “GET” and “HEAD”).

Q. 该指令无默认值，那没有指定 error_page 指令时，为何访问不存在的 url 也能返回 404 呢？

### 附：未指定 error_page 指令时，测试 404 页面
```
server {
    listen 80;
    location /time {
      return 200 $time_iso8601;
    }
}
```
```
[chen@cdh03 demo1]$ curl localhost/time
2022-05-24T13:51:17+00:00
[chen@cdh03 demo1]$ curl localhost/hello -i
HTTP/1.1 404 Not Found
Server: nginx/1.21.6
Date: Tue, 24 May 2022 13:51:25 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive

<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.21.6</center>
</body>
</html>
```
## location = /50x.html 略

## 附：nginx:1.21 镜像的编译参数

configure arguments:
  --prefix=/etc/nginx
  --sbin-path=/usr/sbin/nginx
  --modules-path=/usr/lib/nginx/modules
  --conf-path=/etc/nginx/nginx.conf
  --error-log-path=/var/log/nginx/error.log
  --http-log-path=/var/log/nginx/access.log
  --pid-path=/var/run/nginx.pid
  --lock-path=/var/run/nginx.lock
  --http-client-body-temp-path=/var/cache/nginx/client_temp
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp
  --user=nginx
  --group=nginx
  --with-compat
  --with-file-aio
  --with-threads
  --with-http_addition_module
  --with-http_auth_request_module
  --with-http_dav_module
  --with-http_flv_module
  --with-http_gunzip_module
  --with-http_gzip_static_module
  --with-http_mp4_module
  --with-http_random_index_module
  --with-http_realip_module
  --with-http_secure_link_module
  --with-http_slice_module
  --with-http_ssl_module
  --with-http_stub_status_module
  --with-http_sub_module
  --with-http_v2_module
  --with-mail
  --with-mail_ssl_module
  --with-stream
  --with-stream_realip_module
  --with-stream_ssl_module
  --with-stream_ssl_preread_module
  --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.21.6/debian/debuild-base/nginx-1.21.6=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC'
  --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,
  --as-needed -pie'
