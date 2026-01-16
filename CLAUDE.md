# 项目开发规范

> 本文件定义项目核心规范、开发流程和 Skill 使用指南。

## 文档版本

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-15 | 初始版本 |

---

## 1. 项目信息

```yaml
项目名称: {project-name}
基础包名: com.{company}.{project}
```

如果已有项目开发，则通过读取目录文件确定 project-name、company、project 等信息。

如果是新项目，则需要用户输入 project-name、company、project 等信息。

### 1.1 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| JDK | OpenJDK / Temurin | 17+ |
| 框架 | Spring Boot | 3.x |
| ORM | MyBatis-Plus | 3.5.x |
| 数据库 | MySQL | 8.0+ |
| 缓存 | Redis | 7.0+ |
| API文档 | Knife4j | 4.x |

### 1.2 模块结构

```
{project}/
├── {project}-common/    # 通用模块
├── {project}-core/      # 业务核心
├── {project}-admin/     # 管理后台 (Web端)
└── {project}-api/       # 对外接口 (App端)
```

### 1.3 包结构

```
com.{company}.{project}.{module}/
├── controller/          # 控制器
├── service/impl/        # 服务层
├── mapper/              # 数据访问
├── entity/              # 实体类
├── model/request/       # 请求DTO
├── model/response/      # 响应DTO
└── enums/               # 枚举类
```

---

## 2. 命名规范

### 2.1 Java 命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 类名 | 大驼峰 | `UserService` |
| 方法名 | 小驼峰 | `getUserById` |
| 变量名 | 小驼峰 | `userId` |
| 常量名 | 大写下划线 | `MAX_PAGE_SIZE` |

### 2.2 类命名约定

| 类型 | 格式 |
|------|------|
| 实体类 | `{Entity}` |
| Mapper | `{Entity}Mapper` |
| Service | `{Entity}Service` / `{Entity}ServiceImpl` |
| Controller | `{Entity}Controller` |
| 请求DTO | `{Entity}CreateRequest` / `{Entity}UpdateRequest` / `{Entity}QueryRequest` |
| 响应DTO | `{Entity}Response` |

### 2.3 数据库命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 表名 | 小写下划线，单数 | `user`, `order_item` |
| 字段名 | 小写下划线 | `user_id`, `create_time` |
| 主键 | `id` | `id BIGINT` |
| 外键 | `{关联表}_id` | `user_id` |
| 索引 | `idx_{表名}_{字段}` | `idx_user_phone` |

### 2.4 通用字段

每张业务表必须包含：`id`, `create_by`, `create_time`, `update_by`, `update_time`, `del_flag`

---

## 3. 接口规范

> 详细示例见 `/gen-api`，请求/响应规范见 `/common`

### 3.1 URL 格式

```
/{项目}/{端类型}/v{版本}/{模块}/{资源}
```

端类型：`web`(管理后台) | `api`(App) | `open`(开放) | `callback`(回调) | `internal`(内部)

### 3.2 RESTful CRUD

| 操作 | 方法 | 路径 |
|------|------|------|
| 列表/分页 | GET | `/{module}` |
| 详情 | GET | `/{module}/{id}` |
| 创建 | POST | `/{module}` |
| 更新 | PUT | `/{module}/{id}` |
| 删除 | DELETE | `/{module}/{id}` |

### 3.3 响应格式

```json
{"code": 0, "message": "成功", "data": {}, "timestamp": 1704067200000}
```

### 3.4 错误码分段

| 范围 | 模块 | 示例 |
|------|------|------|
| 0 | 成功 | - |
| 10000-10999 | 认证授权 | 10001 未登录、10002 Token过期 |
| 11000-11999 | 权限控制 | 11001 无权限 |
| 20000-20999 | 用户模块 | 20001 用户不存在 |
| 21000-21999 | 订单模块 | 21001 订单不存在 |
| 22000-22999 | 商品模块 | 22001 商品已下架 |
| 23000-23999 | 支付模块 | 23001 余额不足 |
| 90000-99999 | 系统错误 | 90001 系统繁忙 |

> 新模块按 +1000 递增分配

### 3.5 分页参数

| 参数 | 类型 | 默认值 | 限制 |
|------|------|--------|------|
| pageNo | int | 1 | >= 1 |
| pageSize | int | 10 | 1-100 |

### 3.6 时间格式

| 场景 | 格式 | 示例 |
|------|------|------|
| 日期时间 | `yyyy-MM-dd HH:mm:ss` | 2024-01-15 14:30:00 |
| 仅日期 | `yyyy-MM-dd` | 2024-01-15 |
| 仅时间 | `HH:mm:ss` | 14:30:00 |
| 时间戳 | 毫秒级 long | 1704067200000 |

---

## 4. 开发流程

### 4.1 完整流程

```
需求输入 → 需求分析 → 需求澄清 → 方案设计 → 方案确认
    ↓
任务拆分 → 代码开发 → 自检 → 代码审查 → 完成
```

### 4.2 需求规模判断

| 规模 | 特征 | 流程 |
|------|------|------|
| 简单 | 改字段、加接口、修Bug | 直接开发 |
| 中等 | 新模块、新功能 | 简化流程 |
| 复杂 | 跨模块、架构调整 | 完整流程 |

注：不管规模程度，最终都需要用户确认后开发，禁止不确认直接开发。

---

## 5. 禁止事项

### 5.1 安全红线

- 禁止明文存储密码（必须使用 BCrypt）
- 禁止日志打印敏感信息（密码、手机号、身份证、银行卡）
- 禁止 SQL 字符串拼接（必须使用参数化查询 `#{}`）
- 禁止信任前端传入的用户ID（必须从 Token 获取）
- 禁止未校验的用户输入直接入库（必须使用 @Validated）

### 5.2 性能红线

- 禁止循环内查询数据库（N+1 问题，必须批量查询或 JOIN）
- 禁止深度分页（offset > 10000，必须使用游标分页）
- 禁止不带条件的全表查询
- 禁止单次查询超过 1000 条不分批处理

### 5.3 代码禁忌

- 禁止在循环中打印日志
- 禁止使用 `System.out.println`
- 禁止捕获异常后不处理（空 catch）
- 禁止硬编码魔法值（必须使用常量或枚举）
- 禁止方法超过 50 行不拆分
- 禁止类超过 500 行不拆分

### 5.4 Git 禁忌

- 禁止提交敏感文件（.env、密钥、credentials）
- 禁止直接 push 到 master/main
- 禁止 `--force` 推送

---

## 6. 事务规范

### 6.1 使用场景

| 场景 | 是否需要事务 |
|------|-------------|
| 单表写操作 | 否（MyBatis-Plus 自动处理） |
| 多表写操作 | 是 |
| 先查后改 | 是（需保证一致性时） |
| 纯查询 | 否 |

### 6.2 注解使用

```java
// 标准用法
@Transactional(rollbackFor = Exception.class)
public void bindUserRole(Long userId, List<Long> roleIds) { ... }

// 只读事务（查询多表需一致性快照）
@Transactional(readOnly = true)
public UserDetailResponse getDetail(Long id) { ... }
```

### 6.3 禁止事项

- 禁止在 Controller 层使用 `@Transactional`
- 禁止事务方法内调用同类的另一个事务方法（事务失效）
- 禁止事务内进行 RPC/HTTP 调用
- 禁止大事务（事务方法超过 20 行需拆分）

---

## 7. 缓存规范

### 7.1 Key 命名

```
{项目}:{模块}:{业务}:{标识}
```

示例：`toy:user:info:123`、`toy:order:detail:456`

### 7.2 过期时间

| 数据类型 | 过期时间 | 常量 |
|----------|----------|------|
| 热点数据 | 1小时 | `Constants.CACHE_1_HOUR` |
| 普通数据 | 24小时 | `Constants.CACHE_1_DAY` |
| 配置数据 | 7天 | `Constants.CACHE_7_DAY` |
| 验证码 | 5分钟 | `Constants.CACHE_5_MIN` |

### 7.3 缓存策略

```java
// 查询：先缓存后数据库
public User getById(Long id) {
    String key = RedisKeys.USER_INFO + id;
    User user = redisUtils.get(key, User.class);
    if (user == null) {
        user = userMapper.selectById(id);
        if (user != null) {
            redisUtils.set(key, user, Constants.CACHE_1_HOUR);
        }
    }
    return user;
}

// 更新：先数据库后删缓存
public void update(User user) {
    userMapper.updateById(user);
    redisUtils.delete(RedisKeys.USER_INFO + user.getId());
}
```

### 7.4 防护措施

| 问题 | 解决方案 |
|------|----------|
| 缓存穿透 | 空值缓存（短过期）或布隆过滤器 |
| 缓存击穿 | 分布式锁或永不过期+异步更新 |
| 缓存雪崩 | 过期时间加随机值 |

---

## 8. 并发控制

### 8.1 乐观锁（推荐）

```java
// Entity 添加版本字段
@Version
private Integer version;

// 更新时自动检查版本
userMapper.updateById(user);  // WHERE version = ?
```

适用：冲突概率低、读多写少

### 8.2 悲观锁

```java
// Mapper 方法
@Select("SELECT * FROM user WHERE id = #{id} FOR UPDATE")
User selectForUpdate(Long id);
```

适用：冲突概率高、必须成功

### 8.3 分布式锁

```java
String lockKey = RedisKeys.LOCK_ORDER + orderId;
boolean locked = redisUtils.tryLock(lockKey, 10, TimeUnit.SECONDS);
if (!locked) {
    throw new BusinessException(ErrorCode.SYSTEM_BUSY);
}
try {
    // 业务逻辑
} finally {
    redisUtils.unlock(lockKey);
}
```

---

## 9. 异步处理

### 9.1 使用场景

- 发送通知（短信、邮件、推送）
- 日志记录
- 数据同步
- 非核心业务

### 9.2 注解使用

```java
@Async("taskExecutor")
public void sendNotification(Long userId, String message) {
    // 异步执行，不阻塞主流程
}
```

### 9.3 禁止事项

- 禁止异步方法内操作主流程数据（数据可能未提交）
- 禁止异步方法抛出异常不处理
- 禁止在同类内调用异步方法（失效）

---

## 10. 文件上传

### 10.1 限制规范

| 类型 | 大小限制 | 允许格式 |
|------|----------|----------|
| 图片 | 5MB | jpg, jpeg, png, gif, webp |
| 文档 | 20MB | pdf, doc, docx, xls, xlsx |
| 视频 | 100MB | mp4, avi, mov |
| 头像 | 2MB | jpg, jpeg, png |

### 10.2 安全校验

```java
// 1. 校验文件类型（不能只看后缀）
String contentType = file.getContentType();
AssertUtils.isTrue(ALLOWED_TYPES.contains(contentType), ErrorCode.PARAM_ERROR, "文件类型不支持");

// 2. 校验文件大小
AssertUtils.isTrue(file.getSize() <= MAX_SIZE, ErrorCode.PARAM_ERROR, "文件大小超限");

// 3. 重命名文件（防止路径遍历）
String fileName = UUID.randomUUID() + getExtension(file.getOriginalFilename());
```

### 10.3 存储路径

```
/{年}/{月}/{日}/{uuid}.{ext}
```

示例：`/2024/01/15/a1b2c3d4.jpg`

---

## 11. 日志规范

```java
log.info("[类名.方法名] 操作描述, 参数={}", value);
```

| 级别 | 场景 |
|------|------|
| ERROR | 系统错误、影响业务的异常 |
| WARN | 潜在问题、可恢复异常 |
| INFO | 关键业务流程、重要操作 |
| DEBUG | 调试信息 |

---

## 12. Git 提交规范

```
<type>: <subject>
```

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复Bug |
| docs | 文档变更 |
| style | 代码格式 |
| refactor | 重构 |
| test | 测试 |
| chore | 构建/工具 |

---

## 13. Skill 索引

### 13.1 Skill 清单

| Skill | 场景 | 说明 |
|-------|------|------|
| `/analyze` | 新功能开发 | 需求分析、方案设计 |
| `/change` | 需求变更 | 开发中需求调整 |
| `/resume` | 继续开发 | 中断后恢复进度 |
| `/task` | 任务管理 | 创建、更新、查看任务 |
| `/fix` | 修复Bug | 快速定位和修复 |
| `/review` | 代码审查 | 提交前自检 |
| `/gen-sql` | 建表 | 生成表结构SQL |
| `/gen-crud` | 新模块 | 生成完整CRUD代码 |
| `/gen-api` | 加接口 | 已有模块追加接口 |
| `/gen-enum` | 加枚举 | 生成枚举类 |
| `/gen-test` | 写测试 | 生成单元/集成测试 |
| `/refactor` | 重构 | 代码优化指南 |
| `/deploy` | 部署 | 生成部署配置 |
| `/common` | 公共类 | 查看R、ErrorCode等 |

### 13.2 调用顺序

**新模块开发：** `/analyze` → `/task` → `/gen-sql` → `/gen-crud` → `/gen-test` → `/review`

**新增接口：** `/analyze`(简化) → `/gen-api` → `/review`

**修复Bug：** `/fix` → `/gen-test`(补测试) → `/review`
