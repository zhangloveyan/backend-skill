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
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

/**
 * 全局异常处理。
 * <p>
 * 统一将系统内抛出的异常转换为前端可识别的 {@link R} 结构，
 * 并按类型区分日志级别（业务异常 warn，系统异常 error）。
 * </p>
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BusinessException.class)
    @ResponseBody
    public R<Void> handleBusinessException(BusinessException ex) {
        log.warn("业务异常: code={}, message={}", ex.getCode(), ex.getMessage());
        return R.failure(ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler(InternalException.class)
    @ResponseBody
    public R<Void> handleInternalException(InternalException ex) {
        log.warn("内部接口异常: code={}, message={}", ex.getCode(), ex.getMessage());
        return R.failure(ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    @ResponseBody
    public R<Void> handleValidationException(Exception ex) {
        String message = "请求参数校验失败";
        log.warn("参数校验异常", ex);
        return R.failure(ErrorCode.BAD_REQUEST.getCode(), message);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseBody
    public R<Void> handleHttpMessageNotReadable(HttpMessageNotReadableException ex) {
        HttpServletRequest request = getCurrentRequest();
        if (request == null) {
            log.warn("请求参数解析失败 - 无法获取请求信息");
            return R.failure(ErrorCode.BAD_REQUEST.getCode(), "请求参数解析失败");
        }

        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        String queryString = request.getQueryString();

        log.warn("请求体解析失败 - URI: {}, Method: {}, QueryString: {}, Error: {}",
                requestUri, method, queryString, ex.getMessage(), ex);

        return R.failure(ErrorCode.BAD_REQUEST.getCode(), "请求体解析失败");
    }

    @ExceptionHandler(Exception.class)
    @ResponseBody
    public R<Void> handleException(Exception ex) {
        HttpServletRequest request = getCurrentRequest();
        if (request == null) {
            log.error("系统异常 - 无法获取请求信息", ex);
            return R.failure(ErrorCode.SYSTEM_ERROR);
        }

        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        String queryString = request.getQueryString();

        log.error("系统异常 - URI: {}, Method: {}, QueryString: {}",
                requestUri, method, queryString, ex);
        return R.failure(ErrorCode.SYSTEM_ERROR);
    }

    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseBody
    public R<Void> handleNoResourceFoundException(NoResourceFoundException ex) {
        log.warn("资源未找到: {}", ex.getMessage());
        return R.failure(ErrorCode.NOT_FOUND.getCode(), "请求的资源未找到");
    }
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseBody
    public R<Void> handleHttpRequestMethodNotSupportedException(HttpRequestMethodNotSupportedException ex) {
        HttpServletRequest request = getCurrentRequest();
        if (request == null) {
            log.warn("请求方法不支持 - 无法获取请求信息");
            return R.failure(ErrorCode.METHOD_NOT_ALLOWED);
        }

        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        String supportedMethods = null;
        if (ex.getSupportedMethods() != null) {
            supportedMethods = String.join(", ", ex.getSupportedMethods());
        }

        log.warn("请求方法不支持 - URI: {}, 当前方法: {}, 支持的方法: {}",
                requestUri, method, supportedMethods);

        return R.failure(ErrorCode.METHOD_NOT_ALLOWED.getCode(),
                String.format("请求方法 '%s' 不被支持，该路径只支持: %s", method, supportedMethods));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    @ResponseBody
    public R<Void> handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException ex) {
        HttpServletRequest request = getCurrentRequest();
        if (request == null) {
            log.warn("参数类型不匹配 - 无法获取请求信息", ex);
            return R.failure(ErrorCode.BAD_REQUEST.getCode(), "请求参数类型不正确");
        }

        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        String queryString = request.getQueryString();
        String paramName = ex.getName();
        Object value = ex.getValue();
        String requiredType = ex.getRequiredType() == null ? "unknown" : ex.getRequiredType().getSimpleName();
        String handler = "-";
        if (ex.getParameter() != null && ex.getParameter().getMethod() != null) {
            handler = ex.getParameter().getMethod().getDeclaringClass().getSimpleName()
                    + "." + ex.getParameter().getMethod().getName();
        }

        log.warn("参数类型不匹配 - URI: {}, Method: {}, Handler: {}, Param: {}, Value: {}, RequiredType: {}, QueryString: {}",
                requestUri, method, handler, paramName, value, requiredType, queryString, ex);

        return R.failure(ErrorCode.BAD_REQUEST.getCode(), "请求参数类型不正确");
    }

    private HttpServletRequest getCurrentRequest() {
        RequestAttributes requestAttributes = RequestContextHolder.getRequestAttributes();
        if (requestAttributes == null) {
            return null;
        }
        return ((ServletRequestAttributes) requestAttributes).getRequest();
    }
}
```
