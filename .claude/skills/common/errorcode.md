# ErrorCode 错误码

## 实现

```java
package com.{company}.{project}.common.core;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 错误码枚举
 *
 * 错误码规范：
 * - 0: 成功
 * - 1xxxx: 认证/权限
 * - 2xxxx: 用户模块
 * - 3xxxx: 订单模块
 * - 4xxxx: 商品模块
 * - 5xxxx: 支付模块
 * - 9xxxx: 系统/通用
 */
@Getter
@AllArgsConstructor
public enum ErrorCode {

    // ========== 成功 ==========
    SUCCESS(0, "成功"),

    // ========== 认证/权限 1xxxx ==========
    UNAUTHORIZED(10001, "未登录"),
    TOKEN_EXPIRED(10002, "Token已过期"),
    FORBIDDEN(10003, "无权限"),
    ACCOUNT_DISABLED(10004, "账号被禁用"),
    TOKEN_INVALID(10005, "Token无效"),
    CAPTCHA_ERROR(10006, "验证码错误"),
    CAPTCHA_EXPIRED(10007, "验证码已过期"),

    // ========== 系统/通用 9xxxx ==========
    PARAM_ERROR(90001, "参数错误"),
    PARAM_MISSING(90002, "参数缺失"),
    PARAM_FORMAT_ERROR(90003, "参数格式错误"),
    NOT_FOUND(90004, "资源不存在"),
    DATA_EXIST(90005, "数据已存在"),
    TOO_MANY_REQUESTS(90006, "请求过于频繁"),
    OPERATION_FAILED(90007, "操作失败"),
    DATA_NOT_EXIST(90008, "数据不存在"),
    METHOD_NOT_ALLOWED(90009, "请求方法不允许"),
    SYSTEM_ERROR(99999, "系统错误"),

    // ========== 用户模块 2xxxx ==========
    USER_NOT_FOUND(20001, "用户不存在"),
    USER_ALREADY_EXISTS(20002, "用户已存在"),
    USER_DISABLED(20003, "用户已禁用"),
    USER_PASSWORD_ERROR(20004, "密码错误"),

    // ========== 业务模块（按需扩展） ==========
    ;

    private final int code;
    private final String message;
}
```

## 错误码分段规范

| 范围 | 模块 | 说明 |
|------|------|------|
| 0 | 成功 | 请求成功 |
| 10000-19999 | 认证/权限 | 登录、Token、权限等 |
| 20000-29999 | 用户模块 | 用户相关错误 |
| 30000-39999 | 订单模块 | 订单相关错误 |
| 40000-49999 | 商品模块 | 商品相关错误 |
| 50000-59999 | 支付模块 | 支付相关错误 |
| 60000-69999 | 文件模块 | 文件上传等错误 |
| 90000-99999 | 系统/通用 | 参数、资源、系统级错误 |

## 新增错误码

在对应模块区域添加：

```java
// ========== 订单模块 3xxxx ==========
ORDER_NOT_FOUND(30001, "订单不存在"),
ORDER_STATUS_ERROR(30002, "订单状态异常"),
ORDER_ALREADY_PAID(30003, "订单已支付"),
```
