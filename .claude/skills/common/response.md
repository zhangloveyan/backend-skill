# R 响应类

## 实现

```java
package com.{company}.{project}.common.core;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.io.Serializable;

/**
 * 统一API响应结果
 */
@Data
@Schema(description = "统一响应结果")
public class R<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    @Schema(description = "状态码，0表示成功")
    private int code;

    @Schema(description = "提示信息")
    private String message;

    @Schema(description = "响应数据")
    private T data;

    @Schema(description = "时间戳")
    private long timestamp;

    public R() {
        this.timestamp = System.currentTimeMillis();
    }

    public static <T> R<T> success() {
        R<T> r = new R<>();
        r.setCode(0);
        r.setMessage("成功");
        return r;
    }

    public static <T> R<T> success(T data) {
        R<T> r = new R<>();
        r.setCode(0);
        r.setMessage("成功");
        r.setData(data);
        return r;
    }

    public static <T> R<T> success(String message, T data) {
        R<T> r = new R<>();
        r.setCode(0);
        r.setMessage(message);
        r.setData(data);
        return r;
    }

    public static <T> R<T> fail(int code, String message) {
        R<T> r = new R<>();
        r.setCode(code);
        r.setMessage(message);
        return r;
    }

    public static <T> R<T> fail(ErrorCode errorCode) {
        R<T> r = new R<>();
        r.setCode(errorCode.getCode());
        r.setMessage(errorCode.getMessage());
        return r;
    }

    public static <T> R<T> fail(ErrorCode errorCode, String message) {
        R<T> r = new R<>();
        r.setCode(errorCode.getCode());
        r.setMessage(message);
        return r;
    }

    public boolean isSuccess() {
        return this.code == 0;
    }
}
```

## 使用示例

```java
// 成功响应
@GetMapping("/{id}")
public R<UserResponse> detail(@PathVariable Long id) {
    return R.success(userService.getDetail(id));
}

// 无数据响应
@DeleteMapping("/{id}")
public R<Void> delete(@PathVariable Long id) {
    userService.deleteById(id);
    return R.success();
}

// 失败响应（通常由异常处理器返回）
return R.fail(ErrorCode.NOT_FOUND);
return R.fail(ErrorCode.PARAM_ERROR, "用户名不能为空");
```
