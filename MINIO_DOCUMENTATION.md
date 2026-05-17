# MinIO File Storage - Документация

## 🗂️ Обзор

Проект использует MinIO для хранения файлов (изображения, видео, аудио, документы).

## 🚀 Запуск

MinIO запускается автоматически через Docker Compose:

```bash
docker-compose up -d
```

**Доступ к MinIO Web UI:**
- URL: http://localhost:9001
- Login: `minioadmin`
- Password: `minioadmin`

## 📁 Структура хранилища

```
freelancematch/
├── avatars/              # Аватары пользователей
├── chat/
│   ├── images/          # Изображения в чате
│   ├── videos/          # Видео в чате
│   ├── audio/           # Аудио файлы в чате
│   └── documents/       # Документы в чате
```

## 🔌 API Endpoints

### 1. Загрузка изображения
**POST** `/api/files/upload/image`

**Request:**
- Content-Type: `multipart/form-data`
- Parameter: `file` (MultipartFile)

**Ограничения:**
- Тип: только изображения (image/*)
- Размер: максимум 10MB

**Response:**
```json
{
  "success": true,
  "message": "Image uploaded successfully",
  "data": {
    "fileName": "photo.jpg",
    "fileUrl": "http://localhost:9000/freelancematch/chat/images/uuid.jpg?...",
    "objectName": "chat/images/uuid.jpg",
    "contentType": "image/jpeg",
    "size": 1024000,
    "category": "image"
  }
}
```

---

### 2. Загрузка видео
**POST** `/api/files/upload/video`

**Ограничения:**
- Тип: только видео (video/*)
- Размер: максимум 100MB

---

### 3. Загрузка аудио
**POST** `/api/files/upload/audio`

**Ограничения:**
- Тип: только аудио (audio/*)
- Размер: максимум 20MB

---

### 4. Загрузка документа
**POST** `/api/files/upload/document`

**Ограничения:**
- Тип: PDF, Word, Excel, Text
- Размер: максимум 20MB

---

### 5. Загрузка аватара
**POST** `/api/files/upload/avatar`

**Ограничения:**
- Тип: только изображения (image/*)
- Размер: максимум 10MB
- Сохраняется в папку `avatars/`

---

### 6. Скачать файл
**GET** `/api/files/download/{objectName}`

**Пример:**
```
GET /api/files/download/chat/images/uuid.jpg
```

---

### 7. Получить URL файла
**GET** `/api/files/url/{objectName}`

**Response:**
```json
{
  "success": true,
  "message": "File URL generated successfully",
  "data": "http://localhost:9000/freelancematch/chat/images/uuid.jpg?..."
}
```

URL действителен 7 дней.

---

### 8. Удалить файл
**DELETE** `/api/files/{objectName}`

**Пример:**
```
DELETE /api/files/chat/images/uuid.jpg
```

---

## 🧪 Тестирование с curl

### Загрузка изображения:
```bash
curl -X POST http://localhost:8080/api/files/upload/image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/image.jpg"
```

### Загрузка видео:
```bash
curl -X POST http://localhost:8080/api/files/upload/video \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/video.mp4"
```

### Получить URL файла:
```bash
curl -X GET http://localhost:8080/api/files/url/chat/images/uuid.jpg \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## ⚙️ Конфигурация

**application.properties:**
```properties
# MinIO Configuration
minio.endpoint=http://localhost:9000
minio.access-key=minioadmin
minio.secret-key=minioadmin
minio.bucket-name=freelancematch

# File Upload Configuration
spring.servlet.multipart.enabled=true
spring.servlet.multipart.max-file-size=50MB
spring.servlet.multipart.max-request-size=50MB
```

---

## 📊 Лимиты размеров файлов

| Тип файла | Максимальный размер |
|-----------|---------------------|
| Изображения | 10 MB |
| Видео | 100 MB |
| Аудио | 20 MB |
| Документы | 20 MB |
| Аватары | 10 MB |

---

## 🔐 Безопасность

- Все endpoints требуют JWT аутентификации
- Валидация типов файлов
- Проверка размеров файлов
- Уникальные имена файлов (UUID)

---

## 🎯 Использование в чате

Для следующего этапа (чат между клиентом и фрилансером):

1. Пользователь загружает файл через соответствующий endpoint
2. Получает `objectName` и `fileUrl` в ответе
3. Сохраняет `objectName` в таблице сообщений чата
4. Отображает файл используя `fileUrl`

**Пример структуры сообщения в чате:**
```json
{
  "messageId": 123,
  "senderId": 5,
  "receiverId": 10,
  "messageText": "Вот файл проекта",
  "fileObjectName": "chat/documents/uuid.pdf",
  "fileUrl": "http://...",
  "fileType": "document",
  "timestamp": "2024-01-20T10:30:00"
}
```

---

## 🛠️ Методы FileStorageService

```java
// Загрузка файла
String uploadFile(MultipartFile file, String folder)

// Получить URL файла (действителен 7 дней)
String getFileUrl(String objectName)

// Скачать файл
InputStream downloadFile(String objectName)

// Удалить файл
void deleteFile(String objectName)

// Проверить существование файла
boolean fileExists(String objectName)

// Получить метаданные файла
StatObjectResponse getFileMetadata(String objectName)

// Валидация типа файла
boolean isValidFileType(MultipartFile file, String... allowedTypes)

// Определить категорию файла
String getFileCategory(String contentType)
```

---

## 📝 Следующие шаги

1. ✅ MinIO настроен и работает
2. ✅ Сервис для работы с файлами создан
3. ✅ API endpoints для загрузки/скачивания файлов
4. 🔜 Создание таблиц для чата в БД
5. 🔜 Реализация чата между клиентом и фрилансером
6. 🔜 WebSocket для real-time сообщений
