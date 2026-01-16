# 异常处理

## 使用场景决策

| 场景 | 处理方式 | 示例 |
|------|----------|------|
| 数据不存在 | 抛 BusinessException | `throw new BusinessException(ErrorCode.DATA_NOT_EXIST)` |
| 业务规则不满足 | 抛 BusinessException | `throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR)` |
| 请求参数格式错误 | 由框架自动处理 | `@NotBlank` 校验失败 → PARAM_ERROR |
| 权限不足 | 抛 BusinessException | `throw new BusinessException(ErrorCode.NO_PERMISSION)` |
| 第三方接口失败 | 抛 BusinessException | `throw new BusinessException(ErrorCode.THIRD_PARTY_ERROR, "支付失败")` |
| 系统内部错误 | 不捕获，由全局处理器处理 | NullPointerException → SYSTEM_ERROR |

---

## ErrorCode 使用规则

| ErrorCode | 使用场景 | 说明 |
|-----------|----------|------|
| PARAM_ERROR | **仅用于**请求参数校验失败 | 由 @Valid 触发，不要手动抛 |
| DATA_NOT_EXIST | 查询数据为空 | getById 返回 null |
| DATA_ALREADY_EXIST | 数据重复 | 唯一约束冲突 |
| NO_PERMISSION | 无操作权限 | 非数据所有者 |
| 业务模块错误码 | 具体业务规则 | ORDER_STATUS_ERROR 等 |

---

## 正确示例

```java
// ✓ 数据不存在
User user = userMapper.selectById(id);
if (user == null) {
    throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
}

// ✓ 业务规则校验
if (order.getStatus() != OrderStatus.PENDING.getCode()) {
    throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
}

// ✓ 权限校验
if (!order.getUserId().equals(loginUser.getUserId())) {
    throw new BusinessException(ErrorCode.NO_PERMISSION);
}
```

## 错误示例

```java
// ✗ 不要用 PARAM_ERROR 做业务校验
if (user == null) {
    throw new BusinessException(ErrorCode.PARAM_ERROR, "用户不存在");  // 错误！
}

// ✗ 错误内容需要封装到code中，不允许直接写入
if (order.getStatus() != OrderStatus.PENDING.getCode()) {
    throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR, "订单状态不允许此操作");
}

// ✗ 不要返回 R.fail()，应该抛异常
if (user == null) {
    return R.fail(ErrorCode.DATA_NOT_EXIST);  // 错误！Service 层不应返回 R
}
```

---

## BusinessException 业务异常

```java
package com.{company}.{project}.common.exception;

import com.{company}.{project}.common.core.ErrorCode;
import lombok.Getter;

/**
 * 业务异常
 */
@Getter
public class BusinessException extends RuntimeException {

    private final int code;
    private final String message;

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.message = errorCode.getMessage();
    }

    public BusinessException(ErrorCode errorCode, String message) {
        super(message);
        this.code = errorCode.getCode();
        this.message = message;
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }
}
```

## 使用方式

```java
// 推荐：使用 ErrorCode
throw new BusinessException(ErrorCode.NOT_FOUND);
throw new BusinessException(ErrorCode.PARAM_ERROR);

// 不推荐：直接使用数字
throw new BusinessException(90001, "参数错误");  // 避免
```

---

## GlobalExceptionHandler 全局异常处理器

```java
package com.{company}.{project}.common.exception;

import com.{company}.{project}.common.core.ErrorCode;
import com.{company}.{project}.common.core.R;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.NoHandlerFoundException;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public R<Void> handleBusinessException(BusinessException e, HttpServletRequest request) {
        log.warn("业务异常: uri={}, code={}, message={}", request.getRequestURI(), e.getCode(), e.getMessage());
        return R.fail(e.getCode(), e.getMessage());
    }

    /**
     * 参数校验异常 - @RequestBody
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R<Void> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数校验失败";
        log.warn("参数校验失败: {}", message);
        return R.fail(ErrorCode.PARAM_ERROR, message);
    }

    /**
     * 参数校验异常 - @RequestParam
     */
    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R<Void> handleBindException(BindException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数绑定失败";
        log.warn("参数绑定失败: {}", message);
        return R.fail(ErrorCode.PARAM_ERROR, message);
    }

    /**
     * 请求方法不支持
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
    public R<Void> handleHttpRequestMethodNotSupportedException(HttpRequestMethodNotSupportedException e) {
        log.warn("请求方法不支持: {}", e.getMethod());
        return R.fail(ErrorCode.METHOD_NOT_ALLOWED);
    }

    /**
     * 404 异常
     */
    @ExceptionHandler(NoHandlerFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public R<Void> handleNoHandlerFoundException(NoHandlerFoundException e) {
        log.warn("接口不存在: {}", e.getRequestURL());
        return R.fail(ErrorCode.NOT_FOUND, "接口不存在");
    }

    /**
     * 其他异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public R<Void> handleException(Exception e, HttpServletRequest request) {
        log.error("系统异常: uri={}", request.getRequestURI(), e);
        return R.fail(ErrorCode.SYSTEM_ERROR);
    }
}
```
