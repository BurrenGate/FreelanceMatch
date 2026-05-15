[Diagram](https://dbdiagram.io/d/FreelanceMatch-69adcc6ea44dc25f8b44fcce)

login: FreelanceMatch

password: piedpiper123


http://localhost:8080/swagger-ui.html

login : bob.johnson2@gmail.com
password : 961cd8d3f2521783015b97fe1a80c721

b.nurdaulet2626@gmail.com


---

## 🆕 Новые функции

### Для клиентов:
1. **Просмотр профиля фрилансера** - `GET /api/freelancers/{id}/profile`
   - Полная информация: имя, email, bio, рейтинг, заработок
   - Список навыков с уровнями
   - Последние отзывы
   - Статистика: завершенные работы, активные проекты

2. **Отклонение предложений** - `POST /api/proposals/{id}/reject`
   - Отклонить предложение фрилансера

3. **Предложения с данными фрилансеров** - `GET /api/proposals/job/{id}/with-freelancer`
   - Просмотр всех предложений с информацией о фрилансерах

### Документация:
- [API Documentation](API_DOCUMENTATION.md) - Описание всех endpoints
- [Quick Start Guide](QUICK_START.md) - Быстрый старт и тестирование
- [Changes Summary](CHANGES_SUMMARY.md) - Полное описание изменений
- [SQL Test Queries](SQL_TEST_QUERIES.sql) - SQL запросы для тестирования


---

## 💬 Система чата

### Функции:
1. **Чат между клиентом и фрилансером** - Привязан к контракту
2. **Текстовые сообщения** - Обмен текстовыми сообщениями
3. **Отправка файлов** - Изображения, видео, аудио, документы
4. **Непрочитанные сообщения** - Отслеживание непрочитанных сообщений
5. **История сообщений** - Пагинация и история всех сообщений

### Endpoints:
- `POST /api/chat/messages` - Отправить сообщение
- `GET /api/chat/conversations` - Список бесед
- `GET /api/chat/conversations/{id}/messages` - Сообщения беседы
- `POST /api/chat/conversations/{id}/read` - Отметить как прочитанное
- `GET /api/chat/unread-count` - Количество непрочитанных

### Документация:
- [Chat Documentation](CHAT_DOCUMENTATION.md) - Полная документация чата
- [MinIO Documentation](MINIO_DOCUMENTATION.md) - Работа с файлами
- [Universal File Upload](UNIVERSAL_FILE_UPLOAD.md) - Загрузка всех типов файлов
- [File Type Fix](FIX_FILE_TYPE_LENGTH.md) - Исправление длины MIME-типов (V48)


---

## 🔄 Отмена контрактов

### Функции:
1. **Запрос на отмену** - Любая сторона может запросить отмену контракта
2. **Подтверждение второй стороны** - Требуется согласие другой стороны
3. **Причина отмены** - Обязательное указание причины
4. **Reopening заказа** - При отмене заказ возвращается в статус OPEN

### Endpoints:
- `GET /api/contracts/{id}/details` - Детали контракта с информацией об отмене
- `POST /api/contracts/{id}/cancel/request` - Запросить отмену
- `POST /api/contracts/{id}/cancel/confirm` - Подтвердить отмену
- `POST /api/contracts/{id}/cancel/reject` - Отклонить запрос на отмену

### Документация:
- [Contract Cancellation Documentation](CONTRACT_CANCELLATION_DOCUMENTATION.md) - Полная документация


---

## 💰 Частичная оплата (Milestones)

### Функции:
1. **Разбивка на этапы** - Контракт можно разбить на несколько этапов
2. **Оплата по этапам** - Клиент оплачивает каждый завершенный этап
3. **Отслеживание прогресса** - Статусы этапов (pending, in_progress, completed, paid)
4. **Сводка по оплатам** - Общая сумма, оплачено, остаток

### Endpoints:
- `POST /api/contracts/{id}/milestones` - Создать этап
- `GET /api/contracts/{id}/milestones` - Список этапов
- `GET /api/contracts/{id}/payment-summary` - Сводка по оплатам
- `PUT /api/contracts/{id}/milestones/{milestoneId}/status` - Обновить статус
- `POST /api/contracts/{id}/milestones/{milestoneId}/pay` - Оплатить этап

### Документация:
- [Milestone Payments Documentation](MILESTONE_PAYMENTS_DOCUMENTATION.md) - Полная документация


---

## 💡 Предложение навыков (Skill Suggestions)

### Функции:
1. **Предложение навыков** - Клиенты и фрилансеры могут предлагать новые навыки
2. **Модерация администратором** - Все предложения требуют одобрения админа
3. **Статусы** - pending, approved, rejected
4. **Комментарии** - Администратор может оставлять комментарии
5. **Статистика** - Отслеживание всех предложений

### Endpoints:
- `POST /api/skill-suggestions` - Предложить навык
- `GET /api/skill-suggestions/my` - Мои предложения
- `GET /api/skill-suggestions/admin` - Все предложения (admin)
- `POST /api/skill-suggestions/{id}/approve` - Одобрить (admin)
- `POST /api/skill-suggestions/{id}/reject` - Отклонить (admin)
- `GET /api/skill-suggestions/admin/statistics` - Статистика (admin)

### Документация:
- [Skill Suggestions Documentation](SKILL_SUGGESTIONS_DOCUMENTATION.md) - Полная документация
- [Skill Suggestions Security](SKILL_SUGGESTIONS_SECURITY.md) - Правила безопасности
