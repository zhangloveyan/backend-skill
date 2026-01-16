# Entity 模板

```java
package com.{company}.{project}.{module}.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * {description}实体
 *
 * @author {author}
 * @since {date}
 */
@Data
@TableName("{table_name}")
@Schema(description = "{description}")
public class {Entity} implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    // ========== 业务字段 ==========

    @Schema(description = "名称")
    private String name;

    @Schema(description = "状态 (1-启用, 0-禁用)")
    private Integer status;

    // ========== 通用字段 ==========

    @Schema(description = "创建人")
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private Date createTime;

    @Schema(description = "更新人")
    private String updateBy;

    @TableField(fill = FieldFill.UPDATE)
    @Schema(description = "更新时间")
    private Date updateTime;

    @TableLogic
    @Schema(description = "删除标记")
    private Integer delFlag;
}
```

## JSON 字段处理

```java
@TableField(typeHandler = JacksonTypeHandler.class)
@Schema(description = "图片列表")
private List<String> images;
```

## 枚举字段处理

```java
/**
 * 状态
 * @see StatusEnum
 */
private StatusEnum status;
```
