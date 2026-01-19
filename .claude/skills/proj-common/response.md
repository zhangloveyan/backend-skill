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

---

## 响应格式规范

### 统一格式

```json
{
    "code": 0,
    "message": "成功",
    "data": { ... },
    "timestamp": 1704067200000
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| code | int | 状态码，0 表示成功 |
| message | string | 提示信息 |
| data | object/array/null | 业务数据 |
| timestamp | long | 响应时间戳（毫秒） |

### 分页响应格式

```json
{
    "code": 0,
    "message": "成功",
    "data": {
        "records": [
            { "id": 1, "name": "张三" },
            { "id": 2, "name": "李四" }
        ],
        "total": 100,
        "pageNo": 1,
        "pageSize": 10,
        "pages": 10
    },
    "timestamp": 1704067200000
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| records | array | 数据列表 |
| total | long | 总记录数 |
| pageNo | int | 当前页码 |
| pageSize | int | 每页数量 |
| pages | int | 总页数 |

### 列表响应格式

```json
{
    "code": 0,
    "message": "成功",
    "data": [
        { "id": 1, "name": "选项A" },
        { "id": 2, "name": "选项B" }
    ],
    "timestamp": 1704067200000
}
```

### 失败响应格式

```json
{
    "code": 20001,
    "message": "用户不存在",
    "data": null,
    "timestamp": 1704067200000
}
```
