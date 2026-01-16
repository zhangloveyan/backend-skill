# 数据库迁移规范

## 迁移文件命名

```
V{版本号}__{描述}.sql

示例：
V1.0.0__init_schema.sql
V1.0.1__add_user_phone.sql
V1.1.0__create_order_table.sql
```

---

## 版本号规则

| 格式 | 场景 | 示例 |
|------|------|------|
| V{主}.{次}.{补丁} | 标准版本 | V1.0.0, V1.2.3 |
| V{YYYYMMDD}{序号} | 日期版本 | V20250115001 |

---

## 迁移脚本模板

### 新建表

```sql
-- V1.0.0__create_{table}_table.sql
-- 描述: 创建{描述}表
-- 作者: {author}
-- 日期: {date}

CREATE TABLE IF NOT EXISTS `{table_name}` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    -- 业务字段
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建人',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新人',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `del_flag` TINYINT DEFAULT 0 COMMENT '删除标记(0-正常 1-删除)',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='{描述}';
```

### 添加字段

```sql
-- V1.0.1__add_{table}_{column}.sql
-- 描述: {table}表添加{column}字段
-- 作者: {author}
-- 日期: {date}

ALTER TABLE `{table_name}`
ADD COLUMN `{column_name}` {TYPE} {DEFAULT} COMMENT '{描述}' AFTER `{after_column}`;
```

### 修改字段

```sql
-- V1.0.2__modify_{table}_{column}.sql
-- 描述: 修改{table}表{column}字段
-- 作者: {author}
-- 日期: {date}

ALTER TABLE `{table_name}`
MODIFY COLUMN `{column_name}` {NEW_TYPE} {DEFAULT} COMMENT '{描述}';
```

### 添加索引

```sql
-- V1.0.3__add_index_{table}_{column}.sql
-- 描述: {table}表添加{column}索引
-- 作者: {author}
-- 日期: {date}

CREATE INDEX `idx_{table}_{column}` ON `{table_name}` (`{column_name}`);
```

### 数据迁移

```sql
-- V1.1.0__migrate_{描述}.sql
-- 描述: 数据迁移 - {描述}
-- 作者: {author}
-- 日期: {date}
-- 注意: 此脚本包含数据变更，请在执行前备份

-- 1. 备份原数据（可选）
-- CREATE TABLE `{table}_backup_{date}` AS SELECT * FROM `{table}`;

-- 2. 数据迁移
UPDATE `{table}` SET `{column}` = '{new_value}' WHERE `{condition}`;

-- 3. 验证
-- SELECT COUNT(*) FROM `{table}` WHERE `{condition}`;
```

---

## 迁移原则

1. **只增不删** - 生产环境不删除字段，用 `deprecated_` 前缀标记废弃
2. **向后兼容** - 新字段必须有默认值或允许 NULL
3. **小步迭代** - 大变更拆分为多个小迁移
4. **可回滚** - 提供回滚脚本（复杂变更）

---

## 回滚脚本

```sql
-- R1.0.1__rollback_add_{table}_{column}.sql
-- 描述: 回滚 V1.0.1 - 删除{column}字段
-- 警告: 此操作会丢失数据

ALTER TABLE `{table_name}` DROP COLUMN `{column_name}`;
```

---

## 执行顺序

```
1. 备份数据库
2. 在测试环境验证迁移脚本
3. 停止应用（如需要）
4. 执行迁移脚本
5. 验证数据
6. 启动应用
7. 监控日志
```

---

## 注意事项

1. **大表变更** - 超过 100 万行的表，使用 pt-online-schema-change
2. **锁表风险** - ALTER TABLE 会锁表，选择低峰期执行
3. **字符集** - 统一使用 utf8mb4
4. **事务** - DDL 语句不支持事务，需单独执行
