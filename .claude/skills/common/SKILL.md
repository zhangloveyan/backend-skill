---
name: common
description: 查看公共类规范和使用方式。包括R响应类、ErrorCode错误码、异常处理、事务、缓存、并发控制、日志等。
---

# 公共类与通用规范

## 1. 公共类清单

| 类 | 包路径 | 用途 |
|----|--------|------|
| R | common.core | 统一响应类 |
| ErrorCode | common.core | 错误码枚举 |
| PageResult | common.core | 分页结果 |
| BusinessException | common.exception | 业务异常 |
| GlobalExceptionHandler | common.exception | 全局异常处理 |
| Constants | common.constant | 全局常量 |
| RedisKeys | common.constant | Redis Key 常量 |
| RedisUtils | common.utils | Redis 工具类 |
| AssertUtils | common.utils | 断言工具类 |
| LoginUserHolder | common.security | 登录用户上下文 |

---

## 2. 快速使用

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
Long userId = LoginUserHolder.getUserId();
LoginUser loginUser = LoginUserHolder.get();
```

---

## 3. 事务规范

### 使用场景

| 场景 | 是否需要事务 |
|------|-------------|
| 单表写操作 | 否（MyBatis-Plus 自动处理） |
| 多表写操作 | 是 |
| 先查后改 | 是（需保证一致性时） |
| 纯查询 | 否 |

### 标准用法

```java
// 写操作
@Transactional(rollbackFor = Exception.class)
public void bindUserRole(Long userId, List<Long> roleIds) {
    // 多表操作
}

// 只读事务（查询多表需一致性快照）
@Transactional(readOnly = true)
public UserDetailResponse getDetail(Long id) {
    // 多表查询
}
```

### 禁止事项

- 禁止在 Controller 层使用 `@Transactional`
- 禁止事务方法内调用同类的另一个事务方法（事务失效）
- 禁止事务内进行 RPC/HTTP 调用
- 禁止大事务（事务方法超�� 20 行需拆分）

---

## 4. 缓存规范

### Key 命名

```
{项目}:{模块}:{业务}:{标识}
```

示例：`toy:user:info:123`、`toy:order:detail:456`

### 过期时间

| 数据类型 | 过期时间 | 常量 |
|----------|----------|------|
| 热点数据 | 1小时 | `Constants.CACHE_1_HOUR` |
| 普通数据 | 24小时 | `Constants.CACHE_1_DAY` |
| 配置数据 | 7天 | `Constants.CACHE_7_DAY` |
| 验证码 | 5分钟 | `Constants.CACHE_5_MIN` |

### 缓存策略

```java
// 查询：先缓存后数据库
public User getById(Long id) {
    String key = RedisKeys.USER_INFO + id;
    User user = redisUtils.get(key, User.class);
    if (user == null) {
        user = userMapper.selectById(id);
        if (user != null) {
            redisUtils.set(key, user, Constants.CACHE_1_HOUR);
        }
    }
    return user;
}

// 更新：先数据库后删缓存
public void update(User user) {
    userMapper.updateById(user);
    redisUtils.delete(RedisKeys.USER_INFO + user.getId());
}
```

### 防护措施

| 问题 | 解决方案 |
|------|----------|
| 缓存穿透 | 空值缓存（短过期）或布隆过滤器 |
| 缓存击穿 | 分布式锁或永不过期+异步更新 |
| 缓存雪崩 | 过期时间加随机值 |

---

## 5. 并发控制

### 乐观锁（推荐）

```java
// Entity 添加版本字段
@Version
private Integer version;

// 更新时自动检查版本
userMapper.updateById(user);  // WHERE version = ?
```

适用：冲突概率低、读多写少

### 悲观锁

```java
@Select("SELECT * FROM user WHERE id = #{id} FOR UPDATE")
User selectForUpdate(Long id);
```

适用：冲突概率高、必须成功

### 分布式锁

```java
String lockKey = RedisKeys.LOCK_ORDER + orderId;
boolean locked = redisUtils.tryLock(lockKey, 10, TimeUnit.SECONDS);
if (!locked) {
    throw new BusinessException(ErrorCode.SYSTEM_BUSY);
}
try {
    // 业务逻辑
} finally {
    redisUtils.unlock(lockKey);
}
```

---

## 6. 异常处理

### 异常分类

| 异常类型 | 处理方式 |
|----------|----------|
| BusinessException | 返回错误码和消息 |
| MethodArgumentNotValidException | 返回参数校验错误 |
| 其他异常 | 返回系统错误，记录日志 |

### 使用规范

```java
// 业务校验失败
if (user == null) {
    throw new BusinessException(ErrorCode.USER_NOT_FOUND);
}

// 带自定义消息
throw new BusinessException(ErrorCode.PARAM_ERROR, "手机号格式不正确");

// 使用断言（推荐）
AssertUtils.notNull(user, ErrorCode.USER_NOT_FOUND);
```

---

## 7. 日志规范

### 格式

```java
log.info("[类名.方法名] 操作描述, 参数={}", value);
```

### 级别

| 级别 | 场景 |
|------|------|
| ERROR | 系统错误、影响业务的异常 |
| WARN | 潜在问题、可恢复异常 |
| INFO | 关键业务流程、重要操作 |
| DEBUG | 调试信息 |

### 禁止事项

- 禁止在循环中打印日志
- 禁止打印敏感信息（密码、手机号、身份证）
- 禁止使用 `System.out.println`

---

## 8. 异步处理

### 使用场景

- 发送通知（短信、邮件、推送）
- 日志记录
- 数据同步
- 非核心业务

### 使用方式

```java
@Async("taskExecutor")
public void sendNotification(Long userId, String message) {
    // 异步执行
}
```

### 禁止事项

- 禁止异步方法内操作主流程数据（数据可能未提交）
- 禁止异步方法抛出异常不处理
- 禁止在同类内调用异步方法（失效）
