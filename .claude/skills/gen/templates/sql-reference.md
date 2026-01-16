# SQL 参考文档

## 字段类型对照表

| 数据类型 | MySQL 类型 | Java 类型 | 说明 |
|----------|------------|-----------|------|
| 主键/ID | BIGINT | Long | 自增 |
| 短字符串 | VARCHAR(n) | String | n ≤ 255 |
| 长文本 | TEXT | String | 大文本 |
| 整数 | INT | Integer | 常规整数 |
| 长整数 | BIGINT | Long | 大整数 |
| 小整数 | TINYINT | Integer | 状态、标记 |
| 布尔 | TINYINT(1) | Boolean | 0/1 |
| 小数/金额 | DECIMAL(m,n) | BigDecimal | 精确计算 |
| 日期时间 | DATETIME | Date | 时间戳 |
| 日期 | DATE | Date | 仅日期 |
| 时间 | TIME | Date | 仅时间 |
| JSON | JSON | String/Object | JSON数据 |

## 金额字段建议

| 场景 | 类型 | 说明 |
|------|------|------|
| 普通金额 | DECIMAL(10,2) | 最大 99999999.99 |
| 大额金额 | DECIMAL(19,2) | 最大 17位整数 |
| 汇率/比例 | DECIMAL(10,4) | 4位小数 |
| 积分/数量 | INT / BIGINT | 整数 |

## 字符串长度建议

| 场景 | 长度 |
|------|------|
| 用户名 | VARCHAR(50) |
| 手机号 | VARCHAR(20) |
| 邮箱 | VARCHAR(100) |
| 密码（加密后） | VARCHAR(100) |
| 标题 | VARCHAR(200) |
| 简介/描述 | VARCHAR(500) |
| URL | VARCHAR(500) |
| 长文本 | TEXT |

## 索引规范

### 命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 普通索引 | `idx_{表名}_{字段}` | `idx_user_phone` |
| 唯一索引 | `uk_{表名}_{字段}` | `uk_user_email` |
| 联合索引 | `idx_{表名}_{字段1}_{字段2}` | `idx_order_user_status` |

### 索引原则

1. **选择性高的字段** - 区分度高的字段适合建索引
2. **查询条件字段** - WHERE 条件中的字段
3. **排序字段** - ORDER BY 的字段
4. **联合索引顺序** - 高选择性字段在前
5. **避免过度索引** - 索引会影响写入性能

## 常用 SQL 模板

### 添加字段

```sql
ALTER TABLE `{table_name}`
ADD COLUMN `{field}` {TYPE} {NULL} COMMENT '{描述}' AFTER `{after_field}`;
```

### 修改字段

```sql
ALTER TABLE `{table_name}`
MODIFY COLUMN `{field}` {NEW_TYPE} {NULL} COMMENT '{描述}';
```

### 添加索引

```sql
ALTER TABLE `{table_name}`
ADD INDEX `idx_{table_name}_{field}` (`{field}`);
```

### 添加唯一索引

```sql
ALTER TABLE `{table_name}`
ADD UNIQUE INDEX `uk_{table_name}_{field}` (`{field}`);
```

### 删除索引

```sql
ALTER TABLE `{table_name}`
DROP INDEX `idx_{table_name}_{field}`;
```
