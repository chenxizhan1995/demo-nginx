# http 反向代理
- new,2022-06-09,chenxizhan1995@163.com

## 1. 示例-uri 映射

### 1.1. proxy_pass 带有 URI：会替换
```
    location /test1/demo1/ {
        proxy_pass http://127.0.0.1/remote/;
    }
```
有映射关系

`/test1/demo1/{path}` -> `/remote/{path}`

实验如下：
```bash
curl -w "\n" "http://localhost/test1/demo1/hello?name=jack"
/remote/hello?name=jack
```
### 1.2. proxy_pass 不带有 URI：保持不变
```
    location /test1/demo2/ {
        proxy_pass http://127.0.0.1;
    }
```
有映射关系 `/test1/demo2/{path}` -> `/test1/demo2/{path}`

实验如下：
```bash
curl -w "\n" "http://localhost/test1/demo2/hello?name=jack"
/test1/demo2/hello?name=jack
```

### 1.3. 与 `rewrite ... break;` 共存时
```
    location /test1/demo3/ {
        rewrite /test1/demo3/(.*) /test1/foo/$1 break;
        proxy_pass http://127.0.0.1:81/test-1/;
    }
```
有映射关系 `/test1/demo3/{path}` ->  `/test1/foo/{path}`

实验如下
```bash
curl -w "\n" "http://localhost/test1/demo3/hello?name=jack"
/test1/foo/hello?name=jack
```
### 1.4. 使用变量时
```
    # 4. proxy_pass 中使用变量
    # 覆盖原 uri
    location /test1/demo4/ {
        proxy_pass http://127.0.0.1:81/test1-demo4/$uri;
    }
```

有映射关系 `/test1/demo4/{path} -> /test1-demo4//test1/demo4/{path}`

```bash
curl -w "\n" "http://localhost/test1/demo4/hello?name=jack"
/test1-demo4//test1/demo4/hello
```

### 1.5. 接 1，location 和 proxy_pass 中末尾的斜杠
```
    # 接 1，2，location 和 proxy_pass 指定的URL末尾的斜杠有特殊效果吗？
    location /test1/demo1.11/ {
        proxy_pass http://127.0.0.1:81/remote/;
    }
    location /test1/demo1.10/ {
        proxy_pass http://127.0.0.1:81/remote;
    }
    location /test1/demo1.01 {
        proxy_pass http://127.0.0.1:81/remote/;
    }
    location /test1/demo1.00 {
        proxy_pass http://127.0.0.1:81/remote;
    }
```

```bash
# 都有斜杠，替换
curl -w "\n" "http://localhost/test1/demo1.11/hello?name=jack"
/remote/hello?name=jack
# 后者没有斜杠，也是替换，当然，替换后少了斜杠
curl -w "\n" "http://localhost/test1/demo1.10/hello?name=jack"
/remotehello?name=jack
# 前者没有尾斜杠，也是替换，当然，有重复的斜杠
curl -w "\n" "http://localhost/test1/demo1.01/hello?name=jack"
/remote//hello?name=jack
# 都没有尾斜杠，也是替换，正常
curl -w "\n" "http://localhost/test1/demo1.00/hello?name=jack"
/remote/hello?name=jack
```
## test2
指定了 `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`，会
导致默认的 `proxy_set_header Host $proxy_host;` 消失吗？
Ans: 不会

```
location /test2/demo2 {
    proxy_pass http://127.0.0.1:81/debug;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}

```
实验如下：
```
$ make test2
curl -w "\n" "http://localhost/test2/demo1/hello"

            -----------------------------------
            http_host: 127.0.0.1:81
            Connection: close
            X-Forwarded-For:

curl -w "\n" "http://localhost/test2/demo2/hello"

            -----------------------------------
            http_host: 127.0.0.1:81
            Connection: close
            X-Forwarded-For:172.18.107.1
```
## 3. 超时设置
```bash
$ curl -w "\n" "http://localhost/test3/demo1/hello"
<html>
<head><title>504 Gateway Time-out</title></head>
<body>
<center><h1>504 Gateway Time-out</h1></center>
<hr><center>nginx/1.21.6</center>
</body>
</html>
```
