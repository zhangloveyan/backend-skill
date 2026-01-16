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

## Service 测试模板

```java
package com.{company}.{project}.{module}.service;

import com.{company}.{project}.{module}.entity.{Entity};
import com.{company}.{project}.{module}.mapper.{Entity}Mapper;
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.service.impl.{Entity}ServiceImpl;
import com.{company}.{project}.common.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("{description}服务测试")
class {Entity}ServiceTest {

    @Mock
    private {Entity}Mapper {entity}Mapper;

    @InjectMocks
    private {Entity}ServiceImpl {entity}Service;

    private {Entity} {entity};
    private {Entity}CreateRequest createRequest;

    @BeforeEach
    void setUp() {
        {entity} = new {Entity}();
        {entity}.setId(1L);
        // 设置其他属性

        createRequest = new {Entity}CreateRequest();
        // 设置请求属性
    }

    @Test
    @DisplayName("创建成功")
    void create_Success() {
        // Given
        when({entity}Mapper.insert(any())).thenReturn(1);

        // When
        Long id = {entity}Service.create(createRequest);

        // Then
        assertThat(id).isNotNull();
        verify({entity}Mapper).insert(any());
    }

    @Test
    @DisplayName("根据ID查询 - 存在")
    void getDetail_Found() {
        // Given
        when({entity}Mapper.selectById(1L)).thenReturn({entity});

        // When
        var response = {entity}Service.getDetail(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("根据ID查询 - 不存在")
    void getDetail_NotFound() {
        // Given
        when({entity}Mapper.selectById(1L)).thenReturn(null);

        // When & Then
        assertThatThrownBy(() -> {entity}Service.getDetail(1L))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    @DisplayName("更新成功")
    void update_Success() {
        // Given
        when({entity}Mapper.selectById(1L)).thenReturn({entity});
        when({entity}Mapper.updateById(any())).thenReturn(1);

        // When
        {entity}Service.update(1L, new {Entity}UpdateRequest());

        // Then
        verify({entity}Mapper).updateById(any());
    }

    @Test
    @DisplayName("删除成功")
    void delete_Success() {
        // Given
        when({entity}Mapper.selectById(1L)).thenReturn({entity});
        when({entity}Mapper.deleteById(1L)).thenReturn(1);

        // When
        {entity}Service.deleteById(1L);

        // Then
        verify({entity}Mapper).deleteById(1L);
    }
}
```

---

## Controller 测试模板

```java
package com.{company}.{project}.admin.controller;

import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import com.{company}.{project}.{module}.service.{Entity}Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest({Entity}Controller.class)
@DisplayName("{description}控制器测试")
class {Entity}ControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private {Entity}Service {entity}Service;

    @Test
    @DisplayName("获取详情")
    void getDetail() throws Exception {
        // Given
        {Entity}Response response = new {Entity}Response();
        response.setId(1L);
        when({entity}Service.getDetail(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/{project}/web/v1/{module}/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    @DisplayName("创建")
    void create() throws Exception {
        // Given
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        when({entity}Service.create(any())).thenReturn(1L);

        // When & Then
        mockMvc.perform(post("/{project}/web/v1/{module}")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").value(1));
    }
}
```

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
