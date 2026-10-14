# SQL 参考文档

## 表名与字段名：禁止使用 MySQL 关键字

### 规则与适用范围

1. 新增或重命名的表、字段必须使用小写下划线命名，且不得与目标 MySQL 版本的关键字完全同名；检查包含保留字和非保留关键字。
2. 按完整标识符进行大小写不敏感匹配。例如 `order`、`ORDER`、被反引号包裹的 `order` 均不合规；`order_id` 按完整名称检查，不按子串拦截。
3. 使用有业务含义的替代名称：表名 `order` → `sales_order`、`user` → `sys_user`；字段名 `group` → `user_group`、`key` → `config_key`、`condition` → `filter_condition`。这些是命名示例，实际名称仍需校验。
4. MySQL 允许部分关键字作为标识符，本项目采用更严格的命名约束。反引号可保留为统一 SQL 风格，但不能豁免命名检查。
5. 覆盖技术方案、CREATE TABLE、RENAME TABLE / ALTER TABLE 重命名表、ALTER TABLE 新增/重命名字段，以及 SQL、CRUD 和自动生成模式；CRUD 检查 Entity 最终映射的数据库列名（含默认映射）。Java 属性、DTO/API 名称，以及 SQL 语法中的 `ORDER BY`、类型中的 `INT` 等不属于数据库标识符命名检查对象。

### 校验方法

先记录目标 MySQL 精确版本；支持多个版本时分别检查。MySQL 8.0 可在目标实例执行以下只读查询，将列表替换为本次全部新增或重命名的表名、字段名（去除引用符号后，以字符串值填写）：

```sql
SELECT VERSION() AS mysql_version;

SELECT WORD, RESERVED
FROM INFORMATION_SCHEMA.KEYWORDS
WHERE UPPER(WORD) IN (
  UPPER('sales_order'),
  UPPER('order_id'),
  UPPER('config_key')
);
```

- 返回任何行都表示命名冲突，应改名并重新校验；不要添加 `RESERVED = 1` 过滤条件，非保留关键字同样需要避开。
- 完整候选列表返回零行，才表示通过该实例版本的关键字检查；该结果不能替代完整 DDL 语法验证，也不能代表其他 MySQL 版本通过。
- 无法连接实例时，核对对应目标版本的官方关键字清单，记录版本及来源；版本或清单未核实时标记“待核验”，不得将猜测写成通过结果。
- 在技术方案、生成结果或审查报告中记录候选名称、目标版本、校验来源、结果，以及必要的改名映射。升级 MySQL 时重新检查。

官方参考：[MySQL 8.0 关键字与保留字](https://dev.mysql.com/doc/refman/8.0/en/keywords.html)、[INFORMATION_SCHEMA.KEYWORDS](https://dev.mysql.com/doc/refman/8.0/en/information-schema-keywords-table.html)。其他版本应使用对应版本文档。

### 已有数据库兼容处理

发现已有表或字段使用关键字时，先记录冲突和影响，提出迁移方案，未经确认不得直接重命名。兼容已有名称所需的引用不代表新命名通过检查。获准迁移后同步更新 DDL、Entity 的表/字段映射、Mapper SQL、索引引用、测试和文档，避免只改建表脚本。

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
| 普通索引 | `idx_{表名}_{字段}` | `idx_sys_user_phone` |
| 唯一索引 | `uk_{表名}_{字段}` | `uk_sys_user_email` |
| 联合索引 | `idx_{表名}_{字段1}_{字段2}` | `idx_sales_order_user_id_order_status` |

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
