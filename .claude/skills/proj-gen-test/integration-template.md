# 集成测试模板

## 适用场景

- 测试完整的请求-响应流程
- 测试数据库交互
- 测试多个组件协作
- 测试事务行为

---

## Service 集成测试

```java
package com.{company}.{project}.{module}.service;

import com.{company}.{project}.{module}.entity.{Entity};
import com.{company}.{project}.{module}.mapper.{Entity}Mapper;
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import com.{company}.{project}.common.exception.BusinessException;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional  // 测试后自动回滚
@DisplayName("{description}服务集成测试")
class {Entity}ServiceIntegrationTest {

    @Autowired
    private {Entity}Service {entity}Service;

    @Autowired
    private {Entity}Mapper {entity}Mapper;

    @Test
    @DisplayName("创建并查询")
    void createAndQuery() {
        // Given
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        request.setName("测试数据");

        // When
        Long id = {entity}Service.create(request);

        // Then
        assertThat(id).isNotNull();

        {Entity}Response response = {entity}Service.getDetail(id);
        assertThat(response.getName()).isEqualTo("测试数据");
    }

    @Test
    @DisplayName("更新数据")
    void update() {
        // Given - 先创建
        {Entity}CreateRequest createRequest = new {Entity}CreateRequest();
        createRequest.setName("原始名称");
        Long id = {entity}Service.create(createRequest);

        // When - 更新
        {Entity}UpdateRequest updateRequest = new {Entity}UpdateRequest();
        updateRequest.setName("新名称");
        {entity}Service.update(id, updateRequest);

        // Then
        {Entity}Response response = {entity}Service.getDetail(id);
        assertThat(response.getName()).isEqualTo("新名称");
    }

    @Test
    @DisplayName("删除数据")
    void delete() {
        // Given
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        request.setName("待删除");
        Long id = {entity}Service.create(request);

        // When
        {entity}Service.deleteById(id);

        // Then
        assertThatThrownBy(() -> {entity}Service.getDetail(id))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    @DisplayName("分页查询")
    void pageQuery() {
        // Given - 创建多条数据
        for (int i = 0; i < 15; i++) {
            {Entity}CreateRequest request = new {Entity}CreateRequest();
            request.setName("测试" + i);
            {entity}Service.create(request);
        }

        // When
        {Entity}QueryRequest queryRequest = new {Entity}QueryRequest();
        queryRequest.setPageNo(1);
        queryRequest.setPageSize(10);
        var page = {entity}Service.pageQuery(queryRequest);

        // Then
        assertThat(page.getRecords()).hasSize(10);
        assertThat(page.getTotal()).isGreaterThanOrEqualTo(15);
    }
}
```

---

## Controller 集成测试

```java
package com.{company}.{project}.admin.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.{company}.{project}.{module}.model.request.*;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@DisplayName("{description}接口集成测试")
class {Entity}ControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static final String BASE_URL = "/{project}/web/v1/{module}";

    @Test
    @DisplayName("创建 - 成功")
    void create_Success() throws Exception {
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        request.setName("测试数据");

        mockMvc.perform(post(BASE_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isNumber());
    }

    @Test
    @DisplayName("创建 - 参数校验失败")
    void create_ValidationFail() throws Exception {
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        // name 为空，触发校验

        mockMvc.perform(post(BASE_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(90001));
    }

    @Test
    @DisplayName("查询详情 - 存在")
    void getDetail_Found() throws Exception {
        // Given - 先创建
        {Entity}CreateRequest request = new {Entity}CreateRequest();
        request.setName("测试");

        MvcResult createResult = mockMvc.perform(post(BASE_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andReturn();

        Long id = objectMapper.readTree(createResult.getResponse().getContentAsString())
                .get("data").asLong();

        // When & Then
        mockMvc.perform(get(BASE_URL + "/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.name").value("测试"));
    }

    @Test
    @DisplayName("查询详情 - 不存在")
    void getDetail_NotFound() throws Exception {
        mockMvc.perform(get(BASE_URL + "/999999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(90008));  // DATA_NOT_EXIST
    }

    @Test
    @DisplayName("分页查询")
    void page() throws Exception {
        mockMvc.perform(get(BASE_URL)
                        .param("pageNo", "1")
                        .param("pageSize", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.records").isArray());
    }
}
```

---

## 测试配置

### application-test.yml

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=MySQL;DB_CLOSE_DELAY=-1
    driver-class-name: org.h2.Driver
    username: sa
    password:
  h2:
    console:
      enabled: false
  sql:
    init:
      mode: always

mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

### 测试数据准备

```java
@BeforeEach
void setUp() {
    // 清理测试数据
    {entity}Mapper.delete(null);

    // 准备基础数据
    {Entity} entity = new {Entity}();
    entity.setName("基础数据");
    {entity}Mapper.insert(entity);
}
```

---

## 注意事项

1. **使用 @Transactional** - 测试后自动回滚，保持数据库干净
2. **使用 test profile** - 隔离测试环境配置
3. **使用 H2 内存数据库** - 快速、隔离
4. **测试真实场景** - 包括成功和失败路径
