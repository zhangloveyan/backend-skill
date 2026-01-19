# 工具类

## AssertUtils 断言工具

```java
package com.{company}.{project}.common.utils;

import com.{company}.{project}.common.core.ErrorCode;
import com.{company}.{project}.common.exception.BusinessException;

/**
 * 断言工具类
 */
public class AssertUtils {

    public static void notNull(Object obj, ErrorCode errorCode) {
        if (obj == null) {
            throw new BusinessException(errorCode);
        }
    }

    public static void notNull(Object obj, ErrorCode errorCode, String message) {
        if (obj == null) {
            throw new BusinessException(errorCode, message);
        }
    }

    public static void isTrue(boolean condition, ErrorCode errorCode) {
        if (!condition) {
            throw new BusinessException(errorCode);
        }
    }

    public static void isTrue(boolean condition, ErrorCode errorCode, String message) {
        if (!condition) {
            throw new BusinessException(errorCode, message);
        }
    }

    public static void notEmpty(String str, ErrorCode errorCode) {
        if (str == null || str.trim().isEmpty()) {
            throw new BusinessException(errorCode);
        }
    }
}
```

---

## RedisUtils Redis工具类

```java
package com.{company}.{project}.common.utils;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import java.util.concurrent.TimeUnit;

@Component
@RequiredArgsConstructor
public class RedisUtils {

    private final StringRedisTemplate redisTemplate;

    public void set(String key, String value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, String value, long timeout) {
        redisTemplate.opsForValue().set(key, value, timeout, TimeUnit.SECONDS);
    }

    public String get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    public Boolean expire(String key, long timeout) {
        return redisTemplate.expire(key, timeout, TimeUnit.SECONDS);
    }

    public Long increment(String key) {
        return redisTemplate.opsForValue().increment(key);
    }
}
```

---

## RedisKeys Redis Key 常量

```java
package com.{company}.{project}.common.constant;

/**
 * Redis Key 常量
 */
public class RedisKeys {

    private static final String PREFIX = "{project}:";

    // ========== 用户相关 ==========
    public static final String USER_TOKEN = PREFIX + "user:token:";
    public static final String USER_INFO = PREFIX + "user:info:";

    // ========== 验证码 ==========
    public static final String CAPTCHA = PREFIX + "captcha:";
    public static final String SMS_CODE = PREFIX + "sms:code:";

    // ========== 限流 ==========
    public static final String RATE_LIMIT = PREFIX + "rate:limit:";
}
```

---

## LoginUserHolder 登录用户上下文

```java
package com.{company}.{project}.common.security;

/**
 * 登录用户上下文
 */
public class LoginUserHolder {

    private static final ThreadLocal<LoginUser> HOLDER = new ThreadLocal<>();

    public static void set(LoginUser loginUser) {
        HOLDER.set(loginUser);
    }

    public static LoginUser get() {
        return HOLDER.get();
    }

    public static void remove() {
        HOLDER.remove();
    }
}
```
