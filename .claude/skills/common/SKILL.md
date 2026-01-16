---
name: common
description: 查看公共类规范和使用方式。包括R响应类、ErrorCode错误码、BusinessException异常、工具类等。
---

# 公共类规范

## 公共类清单

| 类 | 包路径 | 用途 |
|----|--------|------|
| R | common.core | 统一响应类 |
| ErrorCode | common.core | 错误码枚举 |
| BusinessException | common.exception | 业务异常 |
| GlobalExceptionHandler | common.exception | 全局异常处理 |
| Constants | common.constant | 全局常量 |
| RedisKeys | common.constant | Redis Key 常量 |
| RedisUtils | common.utils | Redis 工具类 |
| AssertUtils | common.utils | 断言工具类 |
| LoginUserHolder | common.security | 登录用户上下文 |

---

## 快速使用

### 返回响应

```java
return R.success();                    // 成功，无数据
return R.success(data);                // 成功，有数据
return R.fail(ErrorCode.NOT_FOUND);    // 失败
```

### 抛出异常

```java
throw new BusinessException(ErrorCode.NOT_FOUND);
throw new BusinessException(ErrorCode.PARAM_ERROR, "用户名不能为空");
```

### 断言校验

```java
AssertUtils.notNull(user, ErrorCode.NOT_FOUND);
AssertUtils.isTrue(condition, ErrorCode.PARAM_ERROR, "条件不满足");
```

### 获取登录用户

```java
LoginUser loginUser = LoginUserHolder.get();
Long userId = loginUser.getUserId();
```

### Redis 操作

```java
// 设置缓存
redisUtils.set(RedisKeys.USER_INFO + userId, data, Constants.CACHE_1_HOUR);

// 获取缓存
String value = redisUtils.get(RedisKeys.USER_INFO + userId);

// 删除缓存
redisUtils.delete(RedisKeys.USER_INFO + userId);
```

---

## 详细文档

- [R 响应类](response.md)
- [请求规范](request.md)
- [ErrorCode 错误码](errorcode.md)
- [异常处理](exception.md)
- [全局常量](constants.md)
- [工具类](utils.md)
