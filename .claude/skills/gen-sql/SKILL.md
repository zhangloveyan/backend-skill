---
name: gen-sql
description: 生成符合规范的数据库表结构SQL。用于新模块需要建表、已有表需要加字段、查看建表规范。
---

# 生成建表SQL

## 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 表名 | 是 | 小写下划线格式 | `feedback` |
| 表描述 | 是 | 中文描述 | `建议反馈` |
| 业务字段 | 是 | 字段列表 | |

---

## 命名规范

> 参考 CLAUDE.md「数据库命名」章节

| 类型 | 规则 | 示例 |
|------|------|------|
| 表名 | 小写下划线，单数 | `user`, `order_item` |
| 字段名 | 小写下划线 | `user_id`, `create_time` |
| 主键 | `id` | `id BIGINT` |
| 外键 | `{关联表}_id` | `user_id` |
| 索引 | `idx_{表名}_{字段}` | `idx_user_phone` |
| 唯一索引 | `uk_{表名}_{字段}` | `uk_user_email` |

---

## 字段类型参考

| 数据类型 | MySQL 类型 | Java 类型 | 说明 |
|----------|------------|-----------|------|
| 主键/ID | BIGINT | Long | 自增 |
| 短字符串 | VARCHAR(n) | String | n ≤ 255 |
| 长文本 | TEXT | String | 大文本 |
| 整数 | INT | Integer | 常规整数 |
| 小整数 | TINYINT | Integer | 状态、标记 |
| 布尔 | TINYINT(1) | Boolean | 0/1 |
| 小数/金额 | DECIMAL(m,n) | BigDecimal | 精确计算 |
| 日期时间 | DATETIME | Date | 时间戳 |
| JSON | JSON | String/Object | JSON数据 |

---

## 通用字段（必须包含）

```sql
`id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
`create_by` VARCHAR(64) NOT NULL COMMENT '创建人',
`create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
`update_by` VARCHAR(64) COMMENT '更新人',
`update_time` DATETIME COMMENT '更新时间',
`del_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '删除标记',
PRIMARY KEY (`id`)
```

---

## 建表模板

```sql
-- {表描述}
CREATE TABLE `{table_name}` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',

    -- ========== 业务字段 ==========
    `{field1}` {TYPE} {NULL} COMMENT '{描述}',

    -- ========== 通用字段 ==========
    `create_by` VARCHAR(64) NOT NULL COMMENT '创建人',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) COMMENT '更新人',
    `update_time` DATETIME COMMENT '更新时间',
    `del_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '删除标记',

    PRIMARY KEY (`id`),
    INDEX `idx_{table_name}_{field}` (`{field}`),
    INDEX `idx_{table_name}_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='{表描述}';
```

---

## 修改表结构

### 添加字段
```sql
ALTER TABLE `{table_name}`
ADD COLUMN `{field}` {TYPE} {NULL} COMMENT '{描述}' AFTER `{after_field}`;
```

### 添加索引
```sql
ALTER TABLE `{table_name}`
ADD INDEX `idx_{table_name}_{field}` (`{field}`);
```

---

## 注意事项

1. **必填字段** - 使用 `NOT NULL`
2. **默认值** - 状态字段设置合理默认值
3. **字符集** - 统一使用 `utf8mb4`
4. **注释** - 每个字段必须有 COMMENT
5. **索引** - 根据查询场景添加，不要过度索引
