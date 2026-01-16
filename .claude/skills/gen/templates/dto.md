# DTO 模板

## CreateRequest

```java
package com.{company}.{project}.{module}.model.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.io.Serial;
import java.io.Serializable;

/**
 * {description}创建请求
 */
@Data
@Schema(description = "{description}创建请求")
public class {Entity}CreateRequest implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @NotBlank(message = "名称不能为空")
    @Size(max = 100, message = "名称长度不能超过100")
    @Schema(description = "名称", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Schema(description = "状态", defaultValue = "1")
    private Integer status = 1;
}
```

## UpdateRequest

```java
package com.{company}.{project}.{module}.model.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.io.Serial;
import java.io.Serializable;

/**
 * {description}更新请求
 */
@Data
@Schema(description = "{description}更新请求")
public class {Entity}UpdateRequest implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "名称")
    private String name;

    @Schema(description = "状态")
    private Integer status;
}
```

## QueryRequest

```java
package com.{company}.{project}.{module}.model.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.io.Serial;
import java.io.Serializable;

/**
 * {description}查询请求
 */
@Data
@Schema(description = "{description}查询请求")
public class {Entity}QueryRequest implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "页码", defaultValue = "1")
    private Integer pageNo = 1;

    @Schema(description = "每页数量", defaultValue = "10")
    private Integer pageSize = 10;

    @Schema(description = "关键词")
    private String keyword;

    @Schema(description = "状态")
    private Integer status;
}
```

## Response

```java
package com.{company}.{project}.{module}.model.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * {description}响应
 */
@Data
@Schema(description = "{description}响应")
public class {Entity}Response implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "名称")
    private String name;

    @Schema(description = "状态")
    private Integer status;

    @Schema(description = "创建时间")
    private Date createTime;

    @Schema(description = "更新时间")
    private Date updateTime;
}
```

---

## 常用校验注解

| 注解 | 说明 | 示例 |
|------|------|------|
| `@NotNull` | 不能为 null | `@NotNull(message = "ID不能为空")` |
| `@NotBlank` | 字符串不能为空/空白 | `@NotBlank(message = "名称不能为空")` |
| `@NotEmpty` | 集合不能为空 | `@NotEmpty(message = "列表不能为空")` |
| `@Size` | 长度/大小限制 | `@Size(min = 2, max = 20)` |
| `@Min` / `@Max` | 数值范围 | `@Min(0) @Max(100)` |
| `@Pattern` | 正则匹配 | `@Pattern(regexp = "^1[3-9]\\d{9}$")` |
| `@Email` | 邮箱格式 | `@Email(message = "邮箱格式不正确")` |

## 常用字段校验示例

```java
// 手机号
@NotBlank(message = "手机号不能为空")
@Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
private String phone;

// 邮箱
@Email(message = "邮箱格式不正确")
private String email;

// 密码
@NotBlank(message = "密码不能为空")
@Size(min = 6, max = 20, message = "密码长度6-20个字符")
private String password;

// 金额
@NotNull(message = "金额不能为空")
@DecimalMin(value = "0.01", message = "金额必须大于0")
@Digits(integer = 10, fraction = 2, message = "金额格式不正确")
private BigDecimal amount;

// 状态（枚举值）
@NotNull(message = "状态不能为空")
@Min(value = 0, message = "状态值无效")
@Max(value = 1, message = "状态值无效")
private Integer status;

// ID 列表
@NotEmpty(message = "ID列表不能为空")
@Size(max = 100, message = "单次最多操作100条")
private List<Long> ids;
```

---

## 注意事项

1. **必填字段** - 使用 `@NotNull` / `@NotBlank` / `@NotEmpty`
2. **长度限制** - 字符串使用 `@Size`，与数据库字段长度一致
3. **格式校验** - 手机号、邮箱等使用 `@Pattern` 或专用注解
4. **错误消息** - 必须提供中文错误消息
5. **Controller** - 必须使用 `@Validated` 触发校验
