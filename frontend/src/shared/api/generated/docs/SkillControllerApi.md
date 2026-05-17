# SkillControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createManagedSkill**](#createmanagedskill) | **POST** /api/skills/manage | |
|[**createSkill**](#createskill) | **POST** /api/skills | |
|[**deleteManagedSkill**](#deletemanagedskill) | **DELETE** /api/skills/manage/{id} | |
|[**deleteSkill**](#deleteskill) | **DELETE** /api/skills/{id} | |
|[**getAllSkills**](#getallskills) | **GET** /api/skills | |
|[**getManagedSkillById**](#getmanagedskillbyid) | **GET** /api/skills/manage/{id} | |
|[**getManagedSkills**](#getmanagedskills) | **GET** /api/skills/manage | |
|[**getSkillById**](#getskillbyid) | **GET** /api/skills/{id} | |
|[**getSkillsByCategory**](#getskillsbycategory) | **GET** /api/skills/category/{category} | |
|[**updateManagedSkill**](#updatemanagedskill) | **PUT** /api/skills/manage/{id} | |
|[**updateSkill**](#updateskill) | **PUT** /api/skills/{id} | |

# **createManagedSkill**
> ApiResponseSkillResponse createManagedSkill(skillUpsertRequest)


### Example

```typescript
import {
    SkillControllerApi,
    Configuration,
    SkillUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let skillUpsertRequest: SkillUpsertRequest; //

const { status, data } = await apiInstance.createManagedSkill(
    skillUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **skillUpsertRequest** | **SkillUpsertRequest**|  | |


### Return type

**ApiResponseSkillResponse**

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

# **createSkill**
> ApiResponseSkill createSkill(skill)


### Example

```typescript
import {
    SkillControllerApi,
    Configuration,
    Skill
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let skill: Skill; //

const { status, data } = await apiInstance.createSkill(
    skill
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **skill** | **Skill**|  | |


### Return type

**ApiResponseSkill**

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

# **deleteManagedSkill**
> ApiResponseVoid deleteManagedSkill()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteManagedSkill(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


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

# **deleteSkill**
> ApiResponseVoid deleteSkill()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteSkill(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


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

# **getAllSkills**
> ApiResponseListSkill getAllSkills()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

const { status, data } = await apiInstance.getAllSkills();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListSkill**

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

# **getManagedSkillById**
> ApiResponseSkillResponse getManagedSkillById()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getManagedSkillById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseSkillResponse**

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

# **getManagedSkills**
> ApiResponseListSkillResponse getManagedSkills()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let category: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getManagedSkills(
    category
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **category** | [**string**] |  | (optional) defaults to undefined|


### Return type

**ApiResponseListSkillResponse**

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

# **getSkillById**
> ApiResponseSkill getSkillById()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getSkillById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseSkill**

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

# **getSkillsByCategory**
> ApiResponseListSkill getSkillsByCategory()


### Example

```typescript
import {
    SkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let category: string; // (default to undefined)

const { status, data } = await apiInstance.getSkillsByCategory(
    category
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **category** | [**string**] |  | defaults to undefined|


### Return type

**ApiResponseListSkill**

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

# **updateManagedSkill**
> ApiResponseSkillResponse updateManagedSkill(skillUpsertRequest)


### Example

```typescript
import {
    SkillControllerApi,
    Configuration,
    SkillUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)
let skillUpsertRequest: SkillUpsertRequest; //

const { status, data } = await apiInstance.updateManagedSkill(
    id,
    skillUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **skillUpsertRequest** | **SkillUpsertRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseSkillResponse**

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

# **updateSkill**
> ApiResponseSkill updateSkill(skill)


### Example

```typescript
import {
    SkillControllerApi,
    Configuration,
    Skill
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillControllerApi(configuration);

let id: number; // (default to undefined)
let skill: Skill; //

const { status, data } = await apiInstance.updateSkill(
    id,
    skill
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **skill** | **Skill**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseSkill**

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

