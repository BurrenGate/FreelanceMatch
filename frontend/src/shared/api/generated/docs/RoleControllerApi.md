# RoleControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createRole**](#createrole) | **POST** /api/roles/manage | |
|[**deleteRole**](#deleterole) | **DELETE** /api/roles/manage/{roleId} | |
|[**getAllRoles**](#getallroles) | **GET** /api/roles | |
|[**getManagedRoles**](#getmanagedroles) | **GET** /api/roles/manage | |
|[**getRoleById**](#getrolebyid) | **GET** /api/roles/{id} | |
|[**getRoleByName**](#getrolebyname) | **GET** /api/roles/name/{name} | |
|[**updateRole**](#updaterole) | **PUT** /api/roles/manage/{roleId} | |

# **createRole**
> ApiResponseRoleResponse createRole(roleUpsertRequest)


### Example

```typescript
import {
    RoleControllerApi,
    Configuration,
    RoleUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

let roleUpsertRequest: RoleUpsertRequest; //

const { status, data } = await apiInstance.createRole(
    roleUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **roleUpsertRequest** | **RoleUpsertRequest**|  | |


### Return type

**ApiResponseRoleResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRole**
> ApiResponseVoid deleteRole()


### Example

```typescript
import {
    RoleControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

let roleId: number; // (default to undefined)

const { status, data } = await apiInstance.deleteRole(
    roleId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **roleId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseVoid**

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

# **getAllRoles**
> ApiResponseListRole getAllRoles()


### Example

```typescript
import {
    RoleControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

const { status, data } = await apiInstance.getAllRoles();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListRole**

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

# **getManagedRoles**
> ApiResponseListRoleResponse getManagedRoles()


### Example

```typescript
import {
    RoleControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

const { status, data } = await apiInstance.getManagedRoles();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListRoleResponse**

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

# **getRoleById**
> ApiResponseRole getRoleById()


### Example

```typescript
import {
    RoleControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getRoleById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseRole**

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

# **getRoleByName**
> ApiResponseRole getRoleByName()


### Example

```typescript
import {
    RoleControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

let name: string; // (default to undefined)

const { status, data } = await apiInstance.getRoleByName(
    name
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **name** | [**string**] |  | defaults to undefined|


### Return type

**ApiResponseRole**

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

# **updateRole**
> ApiResponseRoleResponse updateRole(roleUpsertRequest)


### Example

```typescript
import {
    RoleControllerApi,
    Configuration,
    RoleUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new RoleControllerApi(configuration);

let roleId: number; // (default to undefined)
let roleUpsertRequest: RoleUpsertRequest; //

const { status, data } = await apiInstance.updateRole(
    roleId,
    roleUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **roleUpsertRequest** | **RoleUpsertRequest**|  | |
| **roleId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseRoleResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

