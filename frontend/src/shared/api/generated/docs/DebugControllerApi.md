# DebugControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**checkFunction**](#checkfunction) | **GET** /api/debug/check-function | |
|[**checkSchema**](#checkschema) | **GET** /api/debug/check-schema | |
|[**flywayStatus**](#flywaystatus) | **GET** /api/debug/flyway-status | |

# **checkFunction**
> { [key: string]: any; } checkFunction()


### Example

```typescript
import {
    DebugControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DebugControllerApi(configuration);

const { status, data } = await apiInstance.checkFunction();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**{ [key: string]: any; }**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **checkSchema**
> { [key: string]: any; } checkSchema()


### Example

```typescript
import {
    DebugControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DebugControllerApi(configuration);

const { status, data } = await apiInstance.checkSchema();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**{ [key: string]: any; }**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flywayStatus**
> Array<{ [key: string]: any; }> flywayStatus()


### Example

```typescript
import {
    DebugControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DebugControllerApi(configuration);

const { status, data } = await apiInstance.flywayStatus();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**Array<{ [key: string]: any; }>**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

