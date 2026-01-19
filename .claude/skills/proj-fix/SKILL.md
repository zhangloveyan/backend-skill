---
name: proj-fix
description: 快速定位和修复Bug，简化流程。用于线上/测试环境发现Bug、功能异常需要修复。
---

# Bug修复

## 触发词

- "有个 Bug"
- "报错了"
- "功能不正常"
- "修复一下"

---

## 执行流程

```
Step 1: 问题收集 → Step 2: 问题定位 → Step 3: 修复方案 → Step 4: 代码修复 → Step 5: 验证
```

---

## Step 1: 问题收集

```markdown
## Bug 信息

**问题描述：** {用户描述的问题}
**复现步骤：** {如何复现}
**期望行为：** {正确的行为}
**实际行为：** {当前错误的行为}
**错误信息：** {报错日志}
```

---

## Step 2: 问题定位

**常见错误类型：**

| 错误类型 | 可能原因 | 排查方向 |
|----------|----------|----------|
| NullPointerException | 空指针 | 检查对象是否为 null |
| SQLException | 数据库错误 | 检查 SQL、字段、连接 |
| BusinessException | 业务校验失败 | 检查业务逻辑 |
| 参数校验失败 | 入参不合法 | 检查 DTO 校验注解 |
| 404 | 接口不存在 | 检查路径、Controller |
| 500 | 服务器内部错误 | 查看详细日志 |

---

## Step 3: 修复方案

```markdown
## 修复方案

**修复方式：** {如何修复}
**修改文件：** {需要修改的文件}
**注意事项：** {风险点}
```

---

## Step 4: 代码修复

**修复原则：**
- 最小改动原则 - 只改必要的代码
- 不要顺手重构 - 专注于修复 Bug
- 保持代码风格一致

---

## Step 5: 验证

```markdown
## 验证清单

- [ ] 问题是否已修复
- [ ] 原有功能是否正常
- [ ] 是否引入新问题
```

---

## 常见修复示例

### 空指针异常

```java
// 修复前
public UserResponse getDetail(Long id) {
    User user = this.getById(id);
    return convertToResponse(user);  // user 可能为 null
}

// 修复后
public UserResponse getDetail(Long id) {
    User user = this.getById(id);
    if (user == null) {
        throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
    }
    return convertToResponse(user);
}
```

---

## Git 提交规范

```
fix: {简要描述问题}

- 问题原因：{原因}
- 修复方式：{方式}
```

---

## 注意事项

1. **先定位后修复** - 不要盲目改代码
2. **最小改动** - 只改必要的部分
3. **充分测试** - 修复后要验证
4. **记录问题** - 重要 Bug 记录到文档
5. **举一反三** - 检查是否有类似问题
