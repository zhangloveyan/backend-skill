# Service 测试模板

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
