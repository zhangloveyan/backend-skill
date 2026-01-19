# {功能名称} - 技术方案文档

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | {日期} | 初始版本 |

---

## 1. 数据库设计

### 1.1 {表名} 表

**表名**：`{table_name}`
**说明**：{表用途说明}

```sql
CREATE TABLE `{table_name}` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',

    -- ========== 业务字段 ==========
    `{field}` {TYPE} {NULL} COMMENT '{描述}',

    -- ========== 通用字段 ==========
    `del_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '删除标记',
    `create_by` VARCHAR(64) NOT NULL COMMENT '创建人',
    `update_by` VARCHAR(64) COMMENT '更新人',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    INDEX `idx_{table}_{field}` (`{field}`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{表注释}';
```

---

## 2. 接口设计

### 2.1 接口列表

#### {端类型} 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/{project}/{端}/v1/{module}` | 列表查询 |
| GET | `/{project}/{端}/v1/{module}/{id}` | 详情 |
| POST | `/{project}/{端}/v1/{module}` | 创建 |
| PUT | `/{project}/{端}/v1/{module}/{id}` | 更新 |
| DELETE | `/{project}/{端}/v1/{module}/{id}` | 删除 |

### 2.2 接口详情

#### 2.2.1 {接口名称}

**接口**：`{METHOD} {PATH}`
**说明**：{接口描述}

**请求参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| {param} | {type} | 是/否 | {说明} |

**响应示例**：

```json
{
  "code": 0,
  "message": "成功",
  "data": {}
}
```

---

## 3. 代码结构

### 3.1 Core 模块

```
com.{company}.{project}.core.{module}/
├── entity/
│   └── {Entity}.java
├── mapper/
│   └── {Entity}Mapper.java
├── service/
│   ├── {Entity}Service.java
│   └── impl/{Entity}ServiceImpl.java
└── enums/
    └── {Xxx}Enum.java
```

### 3.2 Admin 模块

```
com.{company}.{project}.admin/
├── controller/
│   └── {Entity}Controller.java
├── service/
│   ├── {Entity}ManageService.java
│   └── impl/{Entity}ManageServiceImpl.java
└── model/
    ├── request/
    │   ├── {Entity}CreateRequest.java
    │   └── {Entity}UpdateRequest.java
    └── response/
        └── {Entity}Response.java
```

### 3.3 API 模块（如有）

```
com.{company}.{project}.api/
├── controller/
│   └── {Entity}Controller.java
├── service/
│   ├── {Entity}AppService.java
│   └── impl/{Entity}AppServiceImpl.java
└── model/
    ├── request/
    │   └── {Xxx}Request.java
    └── response/
        └── {Xxx}Response.java
```

---

## 4. 枚举定义

| 枚举类 | 枚举值 | 编码 | 描述 |
|--------|--------|------|------|
| {EnumName} | {VALUE} | {code} | {描述} |

---

## 5. 错误码

| 错误码 | 常量名 | 说明 |
|--------|--------|------|
| {code} | {NAME} | {说明} |

---

## 6. 业务规则

1. {规则1}
2. {规则2}
