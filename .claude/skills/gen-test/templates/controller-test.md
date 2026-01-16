# Controller 测试模板

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
