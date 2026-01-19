---
name: proj-analyze-design
description: 技术方案设计与确认（阶段二）。基于已确认的需求，设计数据库、接口、代码结构，生成技术方案文档。
---

# 技术方案设计（阶段二）

> **前置条件**：用户已确认阶段一（/analyze-req）的需求分析文档
> **目标**：设计技术实现方案，明确数据库、接口、代码结构
> **产出**：技术方案文档（用户确认后进入开发阶段）

---

## 执行流程

```
Step 1: 探索现有代码 → Step 2: 设计技术方案 → Step 3: 输出方案文档 → Step 4: 用户确认 → Step 5: 生成任务
```

---

## Step 1: 探索现有代码

在设计方案前，先了解项目现状：

| 探索内容 | 目的 |
|----------|------|
| 相关模块代码 | 了解现有实现方式 |
| 类似功能实现 | 参考已有模式 |
| 公共类和工具 | 复用现有组件 |
| 数据库表结构 | 了解关联关系 |

---

## Step 2: 设计技术方案

### 2.1 数据库设计

**表命名规范**：
- 表名：小写下划线，单数（如 `user`, `order_item`）
- 字段名：小写下划线（如 `user_id`, `create_time`）
- 主键：`id BIGINT AUTO_INCREMENT`
- 外键：`{关联表}_id`
- 索引：`idx_{表名}_{字段}`

**通用字段**（每张业务表必须包含）：
```sql
id BIGINT AUTO_INCREMENT PRIMARY KEY,
del_flag TINYINT(1) DEFAULT 0 COMMENT '删除标记',
create_by VARCHAR(64) COMMENT '创建人',
create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
update_by VARCHAR(64) COMMENT '更新人',
update_time DATETIME COMMENT '更新时间'
```

### 2.2 接口设计

**URL 格式**：
```
/{项目}/{端类型}/v{版本}/{模块}/{资源}
```

**端类型**：
| 端类型 | 说明 | 示例 |
|--------|------|------|
| web | 管理后台 | /toy/web/v1/user |
| api | App/小程序 | /toy/api/v1/device |
| open | 开放接口 | /toy/open/v1/callback |

**RESTful 规范**：
| 操作 | 方法 | 路径 |
|------|------|------|
| 列表/分页 | GET | /{module} |
| 详情 | GET | /{module}/{id} |
| 创建 | POST | /{module} |
| 更新 | PUT | /{module}/{id} |
| 删除 | DELETE | /{module}/{id} |

### 2.3 代码结构

**Core 模块**（业务核心）：
```
com.{company}.{project}.core.{module}/
├── entity/{Entity}.java
├── mapper/{Entity}Mapper.java
├── service/{Entity}Service.java
├── service/impl/{Entity}ServiceImpl.java
└── enums/{Xxx}Enum.java
```

**Admin 模块**（Web后台）：
```
com.{company}.{project}.admin/
├── controller/{Entity}Controller.java
├── service/{Entity}ManageService.java
├── service/impl/{Entity}ManageServiceImpl.java
├── model/request/{Entity}CreateRequest.java
├── model/request/{Entity}UpdateRequest.java
├── model/request/{Entity}QueryRequest.java
└── model/response/{Entity}Response.java
```

**API 模块**（App/小程序）：
```
com.{company}.{project}.api/
├── controller/{Entity}Controller.java
├── service/{Entity}AppService.java
├── service/impl/{Entity}AppServiceImpl.java
├── model/request/{Xxx}Request.java
└── model/response/{Xxx}Response.java
```

---

## Step 3: 输出方案文档

使用模板输出技术方案文档。

**模板文件**：[技术方案模板](templates/design-doc.md)

**保存位置**：`docs/design/{模块}_v{版本}.md`

**注意**：技术方案设计时如发现需求遗漏或变更，需同步更新需求文档。

---

## Step 4: 用户确认

### 4.1 确认话术

输出技术方案后，**必须**使用以下话术请求确认：

```
以上是技术实现方案，请确认：
1. 数据库表结构和字段是否符合预期？
2. 接口设计是否满足需求？
3. 是否需要调整？

确认后我将开始编码开发。
```

### 4.2 用户反馈处理

| 用户反馈 | 处理方式 |
|----------|----------|
| "确认"/"没问题"/"可以" | 调用 `/task` 拆分任务，开始开发 |
| "字段需要调整xxx" | 修改表结构设计，再次确认 |
| "接口需要增加xxx" | 补充接口设计，再次确认 |
| "取消"/"不做了" | 结束流程 |

---

## 注意事项

1. **前置检查** - 确保阶段一需求已确认，否则不能开始
2. **参考现有** - 设计前先看项目已有实现，保持风格一致
3. **命名规范** - 严格遵循 CLAUDE.md 命名规范
4. **不要过度设计** - 按需求来，不主动加功能
5. **确认再开发** - 方案确认前禁止创建/修改任何代码文件

---

## Step 5: 生成任务（用户确认后）

用户确认技术方案后：

1. **保存方案文档**（中等/复杂需求）：`docs/方案/{功能名称}.md`
2. **生成任务清单**：调用 `/task` 创建任务
3. **开始开发**：按顺序 SQL → Entity → Mapper → Service → DTO → Controller
4. **开发完成**：调用 `/review` 自检
