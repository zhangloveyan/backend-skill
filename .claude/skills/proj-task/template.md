# TASK.md 模板

复制以下模板到 `docs/TASK.md` 使用：

```markdown
# 开发任务

## 当前任务

### {YYYY-MM-DD} {功能名称}

**方案文档：** `docs/方案/{功能名称}.md`

**任务清单：**

- [ ] 创建数据库表
- [ ] 创建 Entity 实体类
- [ ] 创建 Mapper 接口和 XML
- [ ] 创建 Service 接口
- [ ] 创建 Service 实现类
- [ ] 创建 Request DTO
- [ ] 创建 Response DTO
- [ ] 创建 Controller（Web端）
- [ ] 创建 Controller（App端）
- [ ] 编写单元测试
- [ ] 自测验证

**提交记录：**

- `{hash}` feat: {message}

---

## 历史任务

<!-- 已完成的任务归档到这里 -->
```

---

## 任务状态标记

| 标记 | 状态 | 说明 |
|------|------|------|
| `[ ]` | 待处理 | 未开始 |
| `[~]` | 进行中 | 正在开发 |
| `[x]` | 已完成 | 开发完成 |
| `[!]` | 阻塞 | 有问题待解决 |
| `[-]` | 取消 | 不再需要 |

---

## 示例

```markdown
# 开发任务

## 当前任务

### 2025-01-15 建议反馈模块

**方案文档：** `docs/方案/建议反馈.md`

**任务清单：**

- [x] 创建 feedback 表
- [x] 创建 Feedback 实体类
- [x] 创建 FeedbackMapper
- [~] 创建 FeedbackService
- [ ] 创建 FeedbackServiceImpl
- [ ] 创建 Request/Response DTO
- [ ] 创建 FeedbackController（Web端）
- [ ] 创建 FeedbackAppController（App端）
- [ ] 编写单元测试
- [ ] 自测验证

**提交记录：**

- `a1b2c3d` feat: 添加 feedback 表结构
- `e4f5g6h` feat: 添加 Feedback 实体和 Mapper

---

## 历史任务

### 2025-01-10 用户模块

**任务清单：**

- [x] 创建 user 表
- [x] 创建 User 实体类
- [x] 创建 UserMapper
- [x] 创建 UserService
- [x] 创建 UserController
- [x] 编写单元测试
- [x] 自测验证

**提交记录：**

- `h7i8j9k` feat: 完成用户模块开发
```
