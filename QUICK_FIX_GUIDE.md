# 🚀 Быстрое применение исправления file_type

## Проблема
```json
{
  "success": false,
  "message": "ERROR: value too long for type character varying(50)"
}
```

## Решение (3 способа)

### ⚡ Способ 1: Автоматически (рекомендуется)
```bash
# Просто перезапустите приложение - Flyway применит V48 автоматически
docker-compose restart app

# Или используйте скрипт
./apply_file_type_fix.sh
```

### 🔧 Способ 2: Через Maven
```bash
mvn spring-boot:run
# Flyway применит миграцию при старте
```

### 📝 Способ 3: Вручную
```bash
# Подключитесь к базе
docker exec -it $(docker ps -qf "name=db") psql -U user -d freelance

# Выполните миграцию
\i src/main/resources/db/migration/V48__fix_chat_file_type_length.sql
\q
```

## ✅ Проверка
```bash
# Запустите тест
docker exec -i $(docker ps -qf "name=db") psql -U user -d freelance < test_v48_file_type_fix.sql
```

## 📊 Что изменилось
- ❌ Было: `file_type VARCHAR(50)` - не работало для Word/Excel/PowerPoint
- ✅ Стало: `file_type VARCHAR(255)` - работает для всех типов файлов

## 🎯 Теперь работает
```bash
curl -X POST http://localhost:8080/api/chat/messages \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": 1,
    "messageText": "Документ",
    "fileType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  }'
```

## 📚 Документация
- [FIX_FILE_TYPE_LENGTH.md](FIX_FILE_TYPE_LENGTH.md) - Полная документация
- [MIME_TYPES_REFERENCE.sql](MIME_TYPES_REFERENCE.sql) - Справочник MIME-типов

## ⏱️ Время применения
- Автоматически: ~10 секунд (перезапуск приложения)
- Вручную: ~5 секунд (выполнение SQL)

## 🔒 Безопасность
✅ Обратно совместимо
✅ Не затрагивает существующие данные
✅ Не требует downtime (можно применить на работающей системе)
