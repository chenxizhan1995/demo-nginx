# Nginx 变量
- new,2022-06-08,chenxizhan1995@163.com
[Alphabetical index of variables](https://nginx.org/en/docs/varindex.html)

## 调用示例


### ngx_http_browser_module
ngx_http_browser_module 模块使用 User-Agent 首部设置变量，提供的变量有三个
- `$modern_browser`  若判定浏览器为现代浏览器，则值为 1（或者是 modern_browser_value 设置的其它值）
- `$ancient_browser` 若判定浏览器为古老浏览器，则值为 1（或者是 ancient_browser_value 指定的其它值）
- `$msie`   若判定客户端浏览器为 MSIE，则为1

如下调用结果表明，nginx 默认的古老、现代浏览器判定规则，迷惑。
```bash
[chen@cdh03 demo3]$ make http_browser
curl -w "\n" http://localhost/http_browser

            modern_browser=
            ancient_browser=1
            msie=

# 模拟火狐 101.0 (64 位) 版，这是 2022-06-08 日的最新版，怎么也不能算是古老的浏览器
[chen@cdh03 demo3]$ make http_browser2
curl -w "\n" http://localhost/http_browser \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0"

            modern_browser=
            ancient_browser=1
            msie=

```
### ngx_http_core_module 和 ngx_http_proxy_module
```
$ curl -w "\n" http://localhost/http_core -v
* About to connect() to localhost port 80 (#0)
*   Trying ::1...
* 拒绝连接
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 80 (#0)
> GET /http_core HTTP/1.1
> User-Agent: curl/7.29.0
> Host: localhost
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: nginx/1.21.6
< Date: Thu, 09 Jun 2022 06:16:58 GMT
< Content-Type: text/plain
< Content-Length: 1148
< Connection: keep-alive
<

            remote_addr: 172.18.93.1
            remote_port: 58656
            remote_user:

            request: GET /http_core HTTP/1.1
            request_method: GET
            request_uri: /http_core
            server_protocol: HTTP/1.1
            scheme: http
            host: localhost
            args:
            query_string:
            arg_foo:

            http_host: localhost
            content_type:
            content_length:

            request_body:
            request_body_file:

            --------------------------------

            status: 200
            sent_http_server:
            sent_http_content_type:
            body_bytes_sent: 0
            bytes_sent: 0

            uri: /http_core
            document_uri: /http_core
            document_root: /etc/nginx/html
            realpath_root:

            hostname: 34241f9485df
            time_iso8601: 2022-06-09T06:16:58+00:00
            time_local: 09/Jun/2022:06:16:58 +0000

            -----------------------------------
            proxy_host:
            proxy_port:
            proxy_add_x_forwarded_for: 172.18.93.1
* Connection #0 to host localhost left intact
```
