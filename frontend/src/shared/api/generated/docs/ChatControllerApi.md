# ChatControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getAvailableChatPartners**](#getavailablechatpartners) | **GET** /api/chat/partners | |
|[**getConversationMessages**](#getconversationmessages) | **GET** /api/chat/conversations/{conversationId}/messages | |
|[**getUnreadCount**](#getunreadcount) | **GET** /api/chat/unread-count | |
|[**getUserConversations**](#getuserconversations) | **GET** /api/chat/conversations | |
|[**markMessagesAsRead**](#markmessagesasread) | **POST** /api/chat/conversations/{conversationId}/read | |
|[**sendMessage**](#sendmessage) | **POST** /api/chat/messages | |

# **getAvailableChatPartners**
> ApiResponseListChatPartnerDTO getAvailableChatPartners()


### Example

```typescript
import {
    ChatControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

const { status, data } = await apiInstance.getAvailableChatPartners();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListChatPartnerDTO**

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

# **getConversationMessages**
> ApiResponseListChatMessageDTO getConversationMessages()


### Example

```typescript
import {
    ChatControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

let conversationId: number; // (default to undefined)
let limit: number; // (optional) (default to 50)
let offset: number; // (optional) (default to 0)

const { status, data } = await apiInstance.getConversationMessages(
    conversationId,
    limit,
    offset
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **conversationId** | [**number**] |  | defaults to undefined|
| **limit** | [**number**] |  | (optional) defaults to 50|
| **offset** | [**number**] |  | (optional) defaults to 0|


### Return type

**ApiResponseListChatMessageDTO**

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

# **getUnreadCount**
> ApiResponseMapStringInteger getUnreadCount()


### Example

```typescript
import {
    ChatControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

const { status, data } = await apiInstance.getUnreadCount();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseMapStringInteger**

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

# **getUserConversations**
> ApiResponseListChatConversationDTO getUserConversations()


### Example

```typescript
import {
    ChatControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

const { status, data } = await apiInstance.getUserConversations();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListChatConversationDTO**

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

# **markMessagesAsRead**
> ApiResponseMapStringInteger markMessagesAsRead()


### Example

```typescript
import {
    ChatControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

let conversationId: number; // (default to undefined)

const { status, data } = await apiInstance.markMessagesAsRead(
    conversationId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **conversationId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringInteger**

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

# **sendMessage**
> ApiResponseMapStringLong sendMessage(sendMessageRequest)


### Example

```typescript
import {
    ChatControllerApi,
    Configuration,
    SendMessageRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ChatControllerApi(configuration);

let sendMessageRequest: SendMessageRequest; //

const { status, data } = await apiInstance.sendMessage(
    sendMessageRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **sendMessageRequest** | **SendMessageRequest**|  | |


### Return type

**ApiResponseMapStringLong**

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

