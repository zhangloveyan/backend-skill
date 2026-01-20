---
name: proj-refactor
description: 代码重构指南和常见重构模式。用于改善代码质量、消除代码坏味道、优化代码结构。
---

# 代码重构

## 适用场景

- 代码质量改善
- 消除代码坏味道
- 优化代码结构
- 提高可维护性

---

## 重构流程

```
Step 0: 校验任务文档 → Step 1: 识别问题 → Step 2: 确定范围 → Step 3: 编写测试 → Step 4: 小步重构 → Step 5: 验证
```

---

## Step 0: 校验任务文档

- 确认全流程任务文档存在
- 若缺失，先创建任务文档骨架并补齐流程状态与上下文快照
- 在上下文快照记录“重构中”与一句话范围说明

---

## 重构原则

1. **小步前进** - 每次只做一个小改动
2. **保持功能** - 重构不改变外部行为
3. **测试保障** - 有测试覆盖再重构
4. **及时提交** - 每个小步骤后提交

**同步任务文档**：
- 产物清单记录相关测试/报告路径（如有）
- 更新下一步指令为“验证/继续开发”

---

## 常见代码坏味道

### 1. 过长方法

**问题：** 方法超过 50 行

**重构方法：** 提取方法

```java
// ✗ 重构前
public void processOrder(Order order) {
    // 50+ 行代码...
}

// ✓ 重构后
public void processOrder(Order order) {
    validateOrder(order);
    calculatePrice(order);
    saveOrder(order);
    sendNotification(order);
}
```

### 2. 过大类

**问题：** 类超过 500 行，职责过多

**重构方法：** 提取类

```java
// ✗ 重构前
public class UserService {
    // 用户管理 + 订单管理 + 支付管理...
}

// ✓ 重构后
public class UserService { /* 用户管理 */ }
public class OrderService { /* 订单管理 */ }
public class PaymentService { /* 支付管理 */ }
```

### 3. 重复代码

**问题：** 相同代码出现多处

**重构方法：** 提取公共方法

```java
// ✗ 重构前
public void methodA() {
    // 重复代码块
}
public void methodB() {
    // 重复代码块
}

// ✓ 重构后
private void commonMethod() {
    // 公共代码块
}
public void methodA() {
    commonMethod();
}
public void methodB() {
    commonMethod();
}
```

### 4. 过长参数列表

**问题：** 方法参数超过 4 个

**重构方法：** 引入参数对象

```java
// ✗ 重构前
public void createUser(String name, String phone, String email,
                       String address, Integer age, Integer status) {}

// ✓ 重构后
public void createUser(UserCreateRequest request) {}
```

### 5. 魔法值

**问题：** 硬编码的数字或字符串

**重构方法：** 提取常量或枚举

```java
// ✗ 重构前
if (status == 1) { }
if (type.equals("VIP")) { }

// ✓ 重构后
if (status == StatusEnum.ENABLE.getCode()) { }
if (type.equals(UserType.VIP)) { }
```

### 6. 过深嵌套

**问题：** if/for 嵌套超过 3 层

**重构方法：** 提前返回、提取方法

```java
// ✗ 重构前
public void process(User user) {
    if (user != null) {
        if (user.isEnabled()) {
            if (user.hasPermission()) {
                // 业务逻辑
            }
        }
    }
}

// ✓ 重构后
public void process(User user) {
    if (user == null) return;
    if (!user.isEnabled()) return;
    if (!user.hasPermission()) return;
    // 业务逻辑
}
```

### 7. 注释过多

**问题：** 用注释解释复杂代码

**重构方法：** 让代码自解释

```java
// ✗ 重构前
// 检查用户是否有效
if (u != null && u.getS() == 1 && u.getD() == 0) { }

// ✓ 重构后
if (user.isValid()) { }

// User 类中
public boolean isValid() {
    return this.status == StatusEnum.ENABLE && this.delFlag == 0;
}
```

---

## 重构检查清单

- [ ] 是否有测试覆盖
- [ ] 重构后功能是否正常
- [ ] 代码是否更清晰
- [ ] 是否引入新问题
- [ ] 是否需要更新文档

---

## 注意事项

1. **不要同时重构和加功能** - 分开进行
2. **有测试再重构** - 没有测试先补测试
3. **小步提交** - 便于回滚
4. **保持克制** - 只重构必要的部分
5. **任务文档同步** - 维护流程状态、产物清单、上下文快照、下一步指令
