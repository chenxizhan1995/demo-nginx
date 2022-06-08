# limit_except 指令，限制 HTTP 方法
- new,2022-06-08,chenxizhan1995@163.com
## 访问示例
### GET 和 HEAD
```bash
$ make get
curl -w "\n" localhost/get
GET,2022-06-08T03:18:57+00:00,08/Jun/2022:03:18:57 +0000

$ curl -w "\n" localhost/get -X POST
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.21.6</center>
</body>

# get 方法，会同时启用 HEAD
$ curl -w "\n" localhost/get -Iv
* About to connect() to localhost port 80 (#0)
*   Trying ::1...
* 拒绝连接
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 80 (#0)
> HEAD /get HTTP/1.1
> User-Agent: curl/7.29.0
> Host: localhost
> Accept: */*
>
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Server: nginx/1.21.6
Server: nginx/1.21.6
< Date: Wed, 08 Jun 2022 03:23:37 GMT
Date: Wed, 08 Jun 2022 03:23:37 GMT
< Content-Type: text/plain
Content-Type: text/plain
< Content-Length: 58
Content-Length: 58
< Connection: keep-alive
Connection: keep-alive

```
### POST
```bash
$ curl -w "\n" localhost/post -X POST
POST,2022-06-08T03:25:55+00:00,08/Jun/2022:03:25:55 +0000

# POST 不会自动启用对应的HEAD方法
$ curl -w "\n" localhost/post -I
HTTP/1.1 404 Not Found
Server: nginx/1.21.6
Date: Wed, 08 Jun 2022 03:27:05 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive

```
### HEAD
```
$ curl -w "\n" localhost/head -I
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Wed, 08 Jun 2022 03:28:05 GMT
Content-Type: text/plain
Content-Length: 58
Connection: keep-alive

$ curl -w "\n" localhost/head  -X GET
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.21.6</center>
</body>
</html>
```
