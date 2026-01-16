---
name: gen-test
description: 生成单元测试和集成测试代码。用于为Service层生成测试、为Controller层生成测试、提高测试覆盖率。
---

# 生成测试代码

## 适用场景

- 为 Service 层生成单元测试
- 为 Controller 层生成单元测试
- 为完整流程生成集成测试
- 提高测试覆盖率

---

## 测试类型选择

| 类型 | 场景 | 特点 |
|------|------|------|
| 单元测试 | 测试单个方法逻辑 | 快速、Mock 依赖 |
| 集成测试 | 测试完整流程 | 真实数据库、慢 |

**建议：** 核心业务逻辑用单元测试，关键流程用集成测试。

---

## 测试框架

| 框架 | 用途 |
|------|------|
| JUnit 5 | 测试框架 |
| Mockito | Mock 框架 |
| AssertJ | 断言库 |
| SpringBootTest | 集成测试 |

---

## 前置检查

生成测试前，检查目标模块的 `pom.xml` 是否包含测试依赖：

```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
```

如缺失，自动添加到 `pom.xml` 的 `<dependencies>` 中，然后再生成测试代码。

---

## 测试模板

- [Service 测试模板](templates/service-test.md)
- [Controller 测试模板](templates/controller-test.md)

---

## 测试命名规范

```
方法名_场景_预期结果

示例：
- create_Success
- create_DuplicateName_ThrowException
- getDetail_Found
- getDetail_NotFound_ThrowException
- update_Success
- delete_NotFound_ThrowException
```

---

## 测试原则

1. **单一职责** - 每个测试只测一个场景
2. **独立性** - 测试之间互不依赖
3. **可重复** - 多次运行结果一致
4. **自验证** - 测试自动判断通过/失败
5. **及时性** - 与代码同步编写

---

## 测试覆盖要求

| 层级 | 覆盖要求 |
|------|----------|
| Service | 核心业务逻辑 100% |
| Controller | 主要接口 80% |
| Utils | 工具方法 100% |

---

## 注意事项

1. **Mock 外部依赖** - 数据库、Redis、第三方接口
2. **测试边界条件** - null、空集合、边界值
3. **测试异常场景** - 业务异常、系统异常
4. **保持测试简洁** - 避免测试代码过于复杂

---

## 相关模板

- 单元测试模板：见上方 Service/Controller 测试模板
- [集成测试模板](integration-template.md)
