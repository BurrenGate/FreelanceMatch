# Chat System Documentation

## 📝 Обзор

Система чата между клиентами и фрилансерами с поддержкой текстовых сообщений и файлов (изображения, видео, аудио, документы).

## 🗄️ База данных

### Таблицы:

**chat_conversations** - Беседы между пользователями
- `id` - ID беседы
- `contract_id` - ID контракта (опционально)
- `client_id` - ID клиента
- `freelancer_id` - ID фрилансера
- `last_message_at` - Время последнего сообщения
- `created_at` - Время создания

**chat_messages** - Сообщения в беседах
- `id` - ID сообщения
- `conversation_id` - ID беседы
- `sender_id` - ID отправителя
- `message_text` - Текст сообщения
- `file_object_name` - Имя файла в MinIO
- `file_url` - URL файла
- `file_type` - Тип файла (image, video, audio, document)
- `file_size` - Размер файла в байтах
- `is_read` - Прочитано ли сообщение
- `created_at` - Время отправки

### PL/pgSQL Функции:

1. `chat_management.get_or_create_conversation()` - Получить или создать беседу
2. `chat_management.send_message()` - Отправить сообщение
3. `chat_management.get_conversation_messages()` - Получить сообщения беседы
4. `chat_management.get_user_conversations()` - Получить все беседы пользователя
5. `chat_management.mark_messages_as_read()` - Отметить сообщения как прочитанные
6. `chat_management.get_unread_count()` - Получить количество непрочитанных сообщений

---

## 🔌 API Endpoints

### 1. Отправить сообщение
**POST** `/api/chat/messages`

**Request Body:**
```json
{
  "conversationId": 1,
  "contractId": 5,
  "recipientId": 10,
  "messageText": "Hello! How is the project going?",
  "fileObjectName": "chat/images/uuid.jpg",
  "fileUrl": "http://localhost:9000/...",
  "fileType": "image",
  "fileSize": 1024000
}
```

**Поля:**
- `conversationId` - ID существующей беседы (опционально, если null - создается новая)
- `contractId` - ID контракта (обязательно для новой беседы)
- `recipientId` - ID получателя (обязательно для новой беседы)
- `messageText` - Текст сообщения (опционально, если есть файл)
- `fileObjectName` - Имя файла в MinIO (опционально)
- `fileUrl` - URL файла (опционально)
- `fileType` - Тип файла (опционально)
- `fileSize` - Размер файла (опционально)

**Response:**
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "messageId": 123
  }
}
```

---

### 2. Получить список бесед
**GET** `/api/chat/conversations`

**Response:**
```json
{
  "success": true,
  "message": "Retrieved 3 conversation(s)",
  "data": [
    {
      "conversationId": 1,
      "contractId": 5,
      "otherUserId": 10,
      "otherUserName": "John Doe",
      "otherUserAvatar": "avatars/uuid.jpg",
      "lastMessageText": "Thanks for the update!",
      "lastMessageAt": "2024-01-20T15:30:00",
      "unreadCount": 2,
      "createdAt": "2024-01-15T10:00:00"
    }
  ]
}
```

---

### 3. Получить сообщения беседы
**GET** `/api/chat/conversations/{conversationId}/messages?limit=50&offset=0`

**Parameters:**
- `limit` - Количество сообщений (по умолчанию 50)
- `offset` - Смещение для пагинации (по умолчанию 0)

**Response:**
```json
{
  "success": true,
  "message": "Retrieved 25 message(s)",
  "data": [
    {
      "messageId": 123,
      "senderId": 5,
      "senderName": "Jane Smith",
      "messageText": "Here is the design mockup",
      "fileObjectName": "chat/images/uuid.jpg",
      "fileUrl": "http://localhost:9000/...",
      "fileType": "image",
      "fileSize": 1024000,
      "isRead": true,
      "createdAt": "2024-01-20T15:30:00"
    }
  ]
}
```

---

### 4. Отметить сообщения как прочитанные
**POST** `/api/chat/conversations/{conversationId}/read`

**Response:**
```json
{
  "success": true,
  "message": "5 message(s) marked as read",
  "data": {
    "markedCount": 5
  }
}
```

---

### 5. Получить количество непрочитанных сообщений
**GET** `/api/chat/unread-count`

**Response:**
```json
{
  "success": true,
  "message": "Unread count retrieved",
  "data": {
    "unreadCount": 12
  }
}
```

---

## 🔄 Типичный workflow

### Сценарий 1: Отправка текстового сообщения

```bash
# 1. Отправить сообщение
curl -X POST http://localhost:8080/api/chat/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": 1,
    "messageText": "Hello! How are you?"
  }'
```

### Сценарий 2: Отправка сообщения с изображением

```bash
# 1. Загрузить изображение
curl -X POST http://localhost:8080/api/files/upload/image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@photo.jpg"

# Response:
# {
#   "data": {
#     "objectName": "chat/images/uuid.jpg",
#     "fileUrl": "http://...",
#     "fileType": "image",
#     "size": 1024000
#   }
# }

# 2. Отправить сообщение с файлом
curl -X POST http://localhost:8080/api/chat/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": 1,
    "messageText": "Check out this design!",
    "fileObjectName": "chat/images/uuid.jpg",
    "fileUrl": "http://...",
    "fileType": "image",
    "fileSize": 1024000
  }'
```

### Сценарий 3: Создание новой беседы

```bash
# Отправить первое сообщение (беседа создастся автоматически)
curl -X POST http://localhost:8080/api/chat/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contractId": 5,
    "recipientId": 10,
    "messageText": "Hi! I have a question about the project."
  }'
```

### Сценарий 4: Просмотр бесед и сообщений

```bash
# 1. Получить список бесед
curl -X GET http://localhost:8080/api/chat/conversations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 2. Получить сообщения конкретной беседы
curl -X GET http://localhost:8080/api/chat/conversations/1/messages?limit=50&offset=0 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 3. Отметить сообщения как прочитанные
curl -X POST http://localhost:8080/api/chat/conversations/1/read \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🎨 Frontend интеграция

### Пример React компонента для чата:

```javascript
// Получить список бесед
const fetchConversations = async () => {
  const response = await fetch('/api/chat/conversations', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const data = await response.json();
  setConversations(data.data);
};

// Получить сообщения беседы
const fetchMessages = async (conversationId) => {
  const response = await fetch(
    `/api/chat/conversations/${conversationId}/messages?limit=50&offset=0`,
    { headers: { 'Authorization': `Bearer ${token}` } }
  );
  const data = await response.json();
  setMessages(data.data);
};

// Отправить сообщение
const sendMessage = async (conversationId, text, file) => {
  let fileData = null;
  
  // Если есть файл, сначала загрузить его
  if (file) {
    const formData = new FormData();
    formData.append('file', file);
    
    const uploadResponse = await fetch('/api/files/upload/image', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` },
      body: formData
    });
    const uploadData = await uploadResponse.json();
    fileData = uploadData.data;
  }
  
  // Отправить сообщение
  const response = await fetch('/api/chat/messages', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      conversationId,
      messageText: text,
      fileObjectName: fileData?.objectName,
      fileUrl: fileData?.fileUrl,
      fileType: fileData?.category,
      fileSize: fileData?.size
    })
  });
  
  return response.json();
};

// Polling для новых сообщений (каждые 5 секунд)
useEffect(() => {
  const interval = setInterval(() => {
    if (currentConversationId) {
      fetchMessages(currentConversationId);
    }
  }, 5000);
  
  return () => clearInterval(interval);
}, [currentConversationId]);
```

---

## 🔐 Безопасность

- Все endpoints требуют JWT аутентификации
- Пользователь может видеть только свои беседы
- Пользователь может отправлять сообщения только в беседах, где он участник
- Валидация: сообщение должно содержать текст или файл

---

## 📊 Ограничения

- Максимум 50 сообщений за один запрос (пагинация)
- Сообщения сортируются по времени создания (новые сверху)
- Беседа привязана к контракту (один контракт = одна беседа)

---

## 🚀 Следующие улучшения (опционально)

1. WebSocket для real-time сообщений
2. Уведомления о новых сообщениях
3. Typing indicators (индикатор печати)
4. Редактирование/удаление сообщений
5. Поиск по сообщениям
6. Групповые чаты
