# 🔧 Исправление: Длина поля file_type в чате

## Проблема
При отправке файлов с длинными MIME-типами возникала ошибка:
```
ERROR: value too long for type character varying(50)
```

### Причина
Поле `chat_messages.file_type` было ограничено 50 символами, но некоторые MIME-типы длиннее:
- `application/vnd.openxmlformats-officedocument.wordprocessingml.document` (73 символа) - Word
- `application/vnd.openxmlformats-officedocument.presentationml.presentation` (74 символа) - PowerPoint
- `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` (66 символов) - Excel

## Решение

### Миграция V48
Файл: `V48__fix_chat_file_type_length.sql`

**Изменения:**
1. ✅ Увеличена длина колонки `file_type` с VARCHAR(50) до VARCHAR(255)
2. ✅ Обновлена функция `chat_management.send_message()` - параметр `p_file_type VARCHAR(255)`
3. ✅ Обновлена функция `chat_management.get_conversation_messages()` - возвращаемый тип `file_type VARCHAR(255)`

### Применение исправления

#### Автоматически (через Flyway)
```bash
# Перезапустите приложение - Flyway применит миграцию автоматически
docker-compose restart app
# или
mvn spring-boot:run
```

#### Вручную (если нужно)
```bash
# Подключитесь к базе данных
psql -U user -d freelance

# Выполните миграцию
\i src/main/resources/db/migration/V48__fix_chat_file_type_length.sql
```

### Проверка исправления
```bash
# Запустите тестовый скрипт
psql -U user -d freelance -f test_v48_file_type_fix.sql
```

## Поддерживаемые типы файлов

После исправления поддерживаются все стандартные MIME-типы:

### Документы
- ✅ `application/pdf` - PDF
- ✅ `application/msword` - Word (.doc)
- ✅ `application/vnd.openxmlformats-officedocument.wordprocessingml.document` - Word (.docx)
- ✅ `application/vnd.ms-excel` - Excel (.xls)
- ✅ `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` - Excel (.xlsx)
- ✅ `application/vnd.ms-powerpoint` - PowerPoint (.ppt)
- ✅ `application/vnd.openxmlformats-officedocument.presentationml.presentation` - PowerPoint (.pptx)

### Изображения
- ✅ `image/jpeg`, `image/jpg` - JPEG
- ✅ `image/png` - PNG
- ✅ `image/gif` - GIF
- ✅ `image/webp` - WebP
- ✅ `image/svg+xml` - SVG

### Видео
- ✅ `video/mp4` - MP4
- ✅ `video/webm` - WebM
- ✅ `video/quicktime` - MOV

### Аудио
- ✅ `audio/mpeg` - MP3
- ✅ `audio/wav` - WAV
- ✅ `audio/ogg` - OGG

### Архивы
- ✅ `application/zip` - ZIP
- ✅ `application/x-rar-compressed` - RAR
- ✅ `application/x-7z-compressed` - 7Z

## Технические детали

### Структура таблицы (после миграции)
```sql
CREATE TABLE chat_messages (
    id                BIGSERIAL PRIMARY KEY,
    conversation_id   BIGINT NOT NULL,
    sender_id         BIGINT NOT NULL,
    message_text      TEXT,
    file_object_name  VARCHAR(500),
    file_url          VARCHAR(1000),
    file_type         VARCHAR(255),  -- ← Увеличено с 50 до 255
    file_size         BIGINT,
    is_read           BOOLEAN DEFAULT FALSE,
    created_at        TIMESTAMP DEFAULT NOW()
);
```

### Функция отправки сообщения
```sql
CREATE OR REPLACE FUNCTION chat_management.send_message(
    p_conversation_id BIGINT,
    p_sender_id BIGINT,
    p_message_text TEXT,
    p_file_object_name VARCHAR(500) DEFAULT NULL,
    p_file_url VARCHAR(1000) DEFAULT NULL,
    p_file_type VARCHAR(255) DEFAULT NULL,  -- ← Обновлено
    p_file_size BIGINT DEFAULT NULL
)
RETURNS BIGINT
```

## Обратная совместимость
✅ Миграция полностью обратно совместима
✅ Существующие данные не затрагиваются
✅ Короткие MIME-типы продолжают работать

## Тестирование

### Пример использования API
```bash
# Отправка файла с длинным MIME-типом
curl -X POST http://localhost:8080/api/chat/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": 1,
    "messageText": "Отправляю документ",
    "fileObjectName": "report.docx",
    "fileUrl": "http://localhost:9000/freelancematch/report.docx",
    "fileType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "fileSize": 1024000
  }'
```

### Ожидаемый результат
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "messageId": 123,
    "conversationId": 1,
    "senderId": 5,
    "messageText": "Отправляю документ",
    "fileType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "createdAt": "2024-01-15T10:30:00"
  }
}
```

## Статус
✅ **Исправлено в версии V48**
✅ Протестировано
✅ Готово к продакшену
