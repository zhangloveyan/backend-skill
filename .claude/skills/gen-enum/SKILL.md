---
name: gen-enum
description: 生成符合规范的枚举类。用于状态字段需要枚举、类型字段需要枚举、需要统一管理常量值。
---

# 生成枚举类

## 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 枚举名 | 是 | 大驼峰 + Enum | `UserStatusEnum` |
| 模块名 | 是 | 所属模块 | `user` |
| 描述 | 是 | 中文描述 | `用户状态` |
| 枚举值 | 是 | code + desc | `1-启用, 0-禁用` |

---

## 枚举模板

```java
package com.{company}.{project}.{module}.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * {description}枚举
 */
@Getter
@AllArgsConstructor
public enum {EnumName} {

    {VALUE1}({code1}, "{desc1}"),
    {VALUE2}({code2}, "{desc2}"),
    ;

    @EnumValue
    private final Integer code;
    private final String desc;

    public static {EnumName} of(Integer code) {
        if (code == null) {
            return null;
        }
        for ({EnumName} item : values()) {
            if (item.getCode().equals(code)) {
                return item;
            }
        }
        return null;
    }
}
```

---

## 常用枚举示例

### 状态枚举

```java
@Getter
@AllArgsConstructor
public enum StatusEnum {
    DISABLE(0, "禁用"),
    ENABLE(1, "启用"),
    ;

    @EnumValue
    private final Integer code;
    private final String desc;
}
```

### 是否枚举

```java
@Getter
@AllArgsConstructor
public enum YesNoEnum {
    NO(0, "否"),
    YES(1, "是"),
    ;

    @EnumValue
    private final Integer code;
    private final String desc;
}
```

### 审核状态枚举

```java
@Getter
@AllArgsConstructor
public enum AuditStatusEnum {
    PENDING(0, "待审核"),
    APPROVED(1, "已通过"),
    REJECTED(2, "已拒绝"),
    ;

    @EnumValue
    private final Integer code;
    private final String desc;
}
```

---

## Entity 中使用枚举

```java
/**
 * 状态
 * @see StatusEnum
 */
private StatusEnum status;
```

---

## 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 枚举类名 | 大驼峰 + Enum | `UserStatusEnum` |
| 枚举值 | 全大写下划线 | `PENDING`, `IN_PROGRESS` |

---

## 注意事项

1. **@EnumValue** - MyBatis-Plus 存储到数据库的值
2. **of 方法** - 提供根据 code 获取枚举的静态方法
3. **null 处理** - of 方法要处理 null 入参
4. **通用枚举** - 放在 common 模块，业务枚举放在对应模块
