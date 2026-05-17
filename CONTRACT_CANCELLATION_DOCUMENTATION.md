# Contract Cancellation Documentation

## 📝 Обзор

Система отмены контрактов с подтверждением второй стороны. Любая сторона (клиент или фрилансер) может запросить отмену контракта, но для выполнения отмены требуется подтверждение от другой стороны.

## 🔄 Процесс отмены контракта

### Шаг 1: Запрос на отмену
Одна из сторон (клиент или фрилансер) отправляет запрос на отмену контракта с указанием причины.

### Шаг 2: Подтверждение или отклонение
Другая сторона может:
- **Подтвердить** отмену → контракт отменяется, заказ возвращается в статус OPEN
- **Отклонить** запрос → контракт остается активным

## 🗄️ База данных

### Новые поля в таблице contracts:
- `cancellation_requested_by` - ID пользователя, запросившего отмену
- `cancellation_requested_at` - Время запроса отмены
- `cancellation_reason` - Причина отмены

### PL/pgSQL Функции:

1. **request_contract_cancellation** - Запросить отмену контракта
2. **confirm_contract_cancellation** - Подтвердить отмену контракта
3. **reject_cancellation_request** - Отклонить запрос на отмену
4. **get_contract_details** - Получить детали контракта с информацией об отмене

---

## 🔌 API Endpoints

### 1. Получить детали контракта
**GET** `/api/contracts/{contractId}/details`

Возвращает полную информацию о контракте, включая статус запроса на отмену.

**Response:**
```json
{
  "success": true,
  "message": "Contract details retrieved successfully",
  "data": {
    "contractId": 5,
    "jobId": 10,
    "jobTitle": "Build REST API",
    "freelancerId": 15,
    "freelancerName": "John Doe",
    "clientId": 20,
    "clientName": "Jane Smith",
    "totalAmount": 5000.00,
    "status": "active",
    "cancellationRequestedBy": 15,
    "cancellationRequesterName": "John Doe",
    "cancellationRequestedAt": "2024-01-20T10:30:00",
    "cancellationReason": "Client changed requirements significantly",
    "createdAt": "2024-01-15T09:00:00"
  }
}
```

---

### 2. Запросить отмену контракта
**POST** `/api/contracts/{contractId}/cancel/request`

**Request Body:**
```json
{
  "reason": "Client changed requirements significantly"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cancellation request sent. Waiting for confirmation from the other party.",
  "data": {
    "status": "PENDING_CONFIRMATION"
  }
}
```

**Ограничения:**
- Контракт должен быть в статусе `active`
- Пользователь должен быть участником контракта (клиент или фрилансер)
- Причина обязательна

---

### 3. Подтвердить отмену контракта
**POST** `/api/contracts/{contractId}/cancel/confirm`

Подтверждает запрос на отмену от другой стороны.

**Response:**
```json
{
  "success": true,
  "message": "Contract cancelled successfully. Job has been reopened.",
  "data": {
    "status": "CANCELLED"
  }
}
```

**Что происходит:**
1. Контракт меняет статус на `cancelled`
2. Заказ возвращается в статус `OPEN`
3. Все pending предложения для этого заказа отклоняются

**Ограничения:**
- Должен существовать запрос на отмену
- Подтверждать может только другая сторона (не тот, кто запросил)
- Пользователь должен быть участником контракта

---

### 4. Отклонить запрос на отмену
**POST** `/api/contracts/{contractId}/cancel/reject`

Отклоняет запрос на отмену от другой стороны.

**Response:**
```json
{
  "success": true,
  "message": "Cancellation request rejected. Contract remains active.",
  "data": {
    "status": "REQUEST_REJECTED"
  }
}
```

**Что происходит:**
1. Запрос на отмену удаляется
2. Контракт остается активным
3. Поля `cancellation_requested_by`, `cancellation_requested_at`, `cancellation_reason` очищаются

**Ограничения:**
- Должен существовать запрос на отмену
- Отклонять может только другая сторона (не тот, кто запросил)
- Пользователь должен быть участником контракта

---

## 🎯 Сценарии использования

### Сценарий 1: Фрилансер запрашивает отмену

```bash
# 1. Фрилансер запрашивает отмену
curl -X POST http://localhost:8080/api/contracts/5/cancel/request \
  -H "Authorization: Bearer FREELANCER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Client is not responding to messages"
  }'

# 2. Клиент проверяет детали контракта
curl -X GET http://localhost:8080/api/contracts/5/details \
  -H "Authorization: Bearer CLIENT_TOKEN"

# Response показывает:
# "cancellationRequestedBy": 15 (freelancer ID)
# "cancellationReason": "Client is not responding to messages"

# 3a. Клиент подтверждает отмену
curl -X POST http://localhost:8080/api/contracts/5/cancel/confirm \
  -H "Authorization: Bearer CLIENT_TOKEN"

# ИЛИ

# 3b. Клиент отклоняет запрос
curl -X POST http://localhost:8080/api/contracts/5/cancel/reject \
  -H "Authorization: Bearer CLIENT_TOKEN"
```

---

### Сценарий 2: Клиент запрашивает отмену

```bash
# 1. Клиент запрашивает отмену
curl -X POST http://localhost:8080/api/contracts/5/cancel/request \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Project requirements changed"
  }'

# 2. Фрилансер проверяет детали контракта
curl -X GET http://localhost:8080/api/contracts/5/details \
  -H "Authorization: Bearer FREELANCER_TOKEN"

# 3. Фрилансер подтверждает или отклоняет
curl -X POST http://localhost:8080/api/contracts/5/cancel/confirm \
  -H "Authorization: Bearer FREELANCER_TOKEN"
```

---

## 🎨 Frontend интеграция

### Пример React компонента:

```javascript
// Получить детали контракта
const fetchContractDetails = async (contractId) => {
  const response = await fetch(`/api/contracts/${contractId}/details`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const data = await response.json();
  return data.data;
};

// Запросить отмену
const requestCancellation = async (contractId, reason) => {
  const response = await fetch(`/api/contracts/${contractId}/cancel/request`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ reason })
  });
  return response.json();
};

// Подтвердить отмену
const confirmCancellation = async (contractId) => {
  const response = await fetch(`/api/contracts/${contractId}/cancel/confirm`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};

// Отклонить запрос
const rejectCancellation = async (contractId) => {
  const response = await fetch(`/api/contracts/${contractId}/cancel/reject`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};

// UI компонент
const ContractCard = ({ contract }) => {
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [cancelReason, setCancelReason] = useState('');
  
  const hasPendingCancellation = contract.cancellationRequestedBy !== null;
  const isRequester = contract.cancellationRequestedBy === currentUserId;
  
  return (
    <div className="contract-card">
      <h3>{contract.jobTitle}</h3>
      <p>Status: {contract.status}</p>
      
      {hasPendingCancellation && (
        <div className="cancellation-alert">
          <p>⚠️ Cancellation requested by {contract.cancellationRequesterName}</p>
          <p>Reason: {contract.cancellationReason}</p>
          
          {!isRequester && (
            <div>
              <button onClick={() => confirmCancellation(contract.contractId)}>
                Confirm Cancellation
              </button>
              <button onClick={() => rejectCancellation(contract.contractId)}>
                Reject Request
              </button>
            </div>
          )}
          
          {isRequester && (
            <p>Waiting for confirmation from the other party...</p>
          )}
        </div>
      )}
      
      {!hasPendingCancellation && contract.status === 'active' && (
        <button onClick={() => setShowCancelModal(true)}>
          Request Cancellation
        </button>
      )}
      
      {showCancelModal && (
        <Modal>
          <h3>Request Contract Cancellation</h3>
          <textarea
            placeholder="Please provide a reason for cancellation"
            value={cancelReason}
            onChange={(e) => setCancelReason(e.target.value)}
          />
          <button onClick={() => {
            requestCancellation(contract.contractId, cancelReason);
            setShowCancelModal(false);
          }}>
            Submit Request
          </button>
        </Modal>
      )}
    </div>
  );
};
```

---

## 🔐 Безопасность

- Все endpoints требуют JWT аутентификации
- Пользователь должен быть участником контракта (клиент или фрилансер)
- Нельзя подтвердить/отклонить свой собственный запрос
- Только активные контракты могут быть отменены

---

## ⚠️ Важные моменты

1. **Двухэтапный процесс**: Отмена требует согласия обеих сторон
2. **Причина обязательна**: При запросе отмены нужно указать причину
3. **Заказ reopens**: При подтверждении отмены заказ возвращается в статус OPEN
4. **Нельзя отменить дважды**: Если запрос отклонен, нужно создать новый запрос

---

## 📊 Статусы

| Статус | Описание |
|--------|----------|
| `PENDING_CONFIRMATION` | Запрос отправлен, ожидает подтверждения |
| `CANCELLED` | Контракт отменен |
| `REQUEST_REJECTED` | Запрос на отмену отклонен |

---

## 🧪 Тестирование

```bash
# 1. Создать контракт (через принятие предложения)
curl -X POST http://localhost:8080/api/proposals/67/accept \
  -H "Authorization: Bearer CLIENT_TOKEN"

# 2. Запросить отмену
curl -X POST http://localhost:8080/api/contracts/5/cancel/request \
  -H "Authorization: Bearer FREELANCER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Test cancellation"}'

# 3. Проверить детали
curl -X GET http://localhost:8080/api/contracts/5/details \
  -H "Authorization: Bearer CLIENT_TOKEN"

# 4. Подтвердить отмену
curl -X POST http://localhost:8080/api/contracts/5/cancel/confirm \
  -H "Authorization: Bearer CLIENT_TOKEN"

# 5. Проверить, что заказ вернулся в OPEN
curl -X GET http://localhost:8080/api/jobs/10 \
  -H "Authorization: Bearer TOKEN"
```
