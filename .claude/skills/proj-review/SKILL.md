---
name: proj-review
description: 代码审查检查清单和流程。用于代码提交前的自检、PR审查、代码质量检查。
---

# 代码审查

## 适用场景

- 代码提交前自检
- Pull Request 审查
- 代码质量检查

---

## 审查流程

```
Step 0: 编译检查 → Step 1: 功能检查 → Step 2: 代码规范 → Step 3: 安全检查 → Step 4: 性能检查 → Step 5: 自动修复 → Step 6: 输出报告
```

---

## Step 0: 编译检查（前置）

执行 `mvn compile` 检查：
- 类名与文件名是否匹配
- 语法错误
- 依赖缺失

如有编译错误，先修复再继续审查。

---

## 审查清单

### 1. 功能检查

- [ ] 功能是否符合需求
- [ ] 边界条件是否处理
- [ ] 异常情况是否处理
- [ ] 是否有遗漏的场景

### 2. 代码规范

- [ ] 命名是否符合规范（参考 CLAUDE.md）
- [ ] 代码格式是否统一
- [ ] 注释是否清晰必要
- [ ] 是否有重复代码
- [ ] 方法是否过长（建议不超过50行）
- [ ] 类是否过大（建议不超过500行）

### 3. 安全检查（安全红线）

**强制规则 - 违反必须修复**：
- [ ] **禁止明文存储密码**（必须 BCrypt）
- [ ] **禁止日志打印敏感信息**（密码、手机号、身份证）
- [ ] **禁止 SQL 拼接**（必须使用 `#{}` 参数化查询）
- [ ] **禁止信任前端传入的用户ID**（必须从 Token 获取）

**其他安全检查**：
- [ ] 是否有 XSS 风险
- [ ] 敏感信息是否脱敏
- [ ] 权限校验是否完整

### 4. 性能检查（性能红线）

**强制规则 - 违反必须修复**：
- [ ] **禁止循环内查询数据库**（N+1 问题）
- [ ] **禁止深度分页**（offset > 10000）
- [ ] **禁止不带条件的全表查询**
- [ ] **禁止单次查询超过 1000 条不分批**

**其他性能检查**：
- [ ] 是否在循环中执行数据库操作
- [ ] 是否有不必要的数据库查询
- [ ] 大数据量是否分页处理（单次 ≤ 1000）
- [ ] 批量操作是否分批执行（每批 ≤ 500）
- [ ] 是否有全表扫描（缺少索引）
- [ ] 是否有内存泄漏风险

### 5. 日志检查

- [ ] 关键操作是否有日志
- [ ] 日志格式是否规范
- [ ] 是否打印了敏感信息
- [ ] 是否在循环中打印日志

### 6. 异常处理

- [ ] 异常是否被正确捕获
- [ ] 异常信息是否有意义
- [ ] 是否有空的 catch 块
- [ ] 事务是否正确回滚

---

## Step 5: 自动修复

对于以下问题，直接修复而非仅报告：

| 问题类型 | 修复方式 |
|----------|----------|
| NPE 风险（Integer/Long 比较） | 改用 `equals()` 或 `Objects.equals()` |
| 类名与文件名不匹配 | 修改类名与文件名一致 |
| 缺少 `@ApiLog` 注解 | 添加注解 |
| 硬编码常量 | 提取为常量或使用 `BaseConstant` |

---

### 7. 测试检查

- [ ] 是否有单元测试
- [ ] 测试覆盖率是否足够
- [ ] 边界条件是否测试

---

## 常见问题

### 命名问题

```java
// ✗ 错误
int a = 1;
String str = "hello";
public void process() {}

// ✓ 正确
int userCount = 1;
String userName = "hello";
public void processOrder() {}
```

### 空指针风险

```java
// ✗ 风险
User user = userMapper.selectById(id);
return user.getName();  // user 可能为 null

// ✓ 正确
User user = userMapper.selectById(id);
if (user == null) {
    throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
}
return user.getName();
```

### SQL 注入风险

```java
// ✗ 危险
@Select("SELECT * FROM user WHERE name = '" + name + "'")

// ✓ 安全
@Select("SELECT * FROM user WHERE name = #{name}")
```

### N+1 查询

```java
// ✗ N+1 问题
List<Order> orders = orderMapper.selectList();
for (Order order : orders) {
    User user = userMapper.selectById(order.getUserId());  // N次查询
}

// ✓ 正确 - 批量查询
List<Order> orders = orderMapper.selectList();
Set<Long> userIds = orders.stream().map(Order::getUserId).collect(toSet());
Map<Long, User> userMap = userMapper.selectBatchIds(userIds)
    .stream().collect(toMap(User::getId, Function.identity()));
```

### 深度分页

```java
// ✗ 深度分页问题
SELECT * FROM order LIMIT 100000, 10;  // 扫描 100010 行

// ✓ 游标分页
SELECT * FROM order WHERE id > #{lastId} ORDER BY id LIMIT 10;
```

### 批量操作

```java
// ✗ 未分批
mapper.insertBatch(largeList);  // 可能超时或内存溢出

// ✓ 分批处理
List<List<Entity>> batches = Lists.partition(largeList, 500);
for (List<Entity> batch : batches) {
    mapper.insertBatch(batch);
}
```

---

## 输出报告

使用模板生成审查报告：[审查报告模板](templates/review-report.md)

---

## 注意事项

1. **客观公正** - 基于规范和最佳实践
2. **具体明确** - 指出具体问题和位置
3. **提供建议** - 不只指出问题，也给出解决方案
4. **区分级别** - 严重问题必须修复，建议可选
