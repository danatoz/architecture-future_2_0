# Ключевые агрегаты

## Patient (Patient Management)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `patientId: UUID` |
| **Границы** | Вся информация о пациенте: имя, дата рождения, контакты, страховка, статус |
| **Инварианты** | Пациент должен быть старше 0 лет; email уникален в пределах системы; страховка должна быть валидна на текущую дату |
| **Ключевые события** | `PatientRegistered`, `PatientUpdated`, `PatientMerged` |

---

## MedicalRecord (Clinical Records)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `recordId: UUID` |
| **Границы** | Одна запись приёма/диагноза: диагноз, назначения, прикреплённые файлы (исследования), врач, дата |
| **Инварианты** | Запись всегда привязана к пациенту и врачу; диагноз обязателен; запись не может быть изменена после подписания (append-only) |
| **Ключевые события** | `DiagnosisRecorded`, `TreatmentPrescribed`, `MedicalRecordUpdated` |
| **Примечание** | Данные этого агрегата **не публикуются** в Data Marketplace согласно политике компании |

---

## Appointment (Appointment Scheduling)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `appointmentId: UUID` |
| **Границы** | Запись на приём: пациент, врач, время, тип приёма, статус |
| **Инварианты** | Нельзя записать двух пациентов на одно время к одному врачу; статусы: `Scheduled → Completed / Cancelled` (без возврата) |
| **Ключевые события** | `AppointmentScheduled`, `AppointmentCompleted`, `AppointmentCancelled` |

---

## Payment (Billing & Payments)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `paymentId: UUID` |
| **Границы** | Транзакция оплаты: сумма, валюта, метод, статус, ссылки на invoice/appointment/loan |
| **Инварианты** | Сумма платежа не может быть отрицательной; статусная модель: `Pending → Completed / Failed / Refunded` |
| **Ключевые события** | `PaymentInitiated`, `PaymentCompleted`, `PaymentFailed`, `PaymentRefunded` |

---

## LoanAgreement (Lending)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `loanId: UUID` |
| **Границы** | Кредитный договор: сумма, срок, процентная ставка, график платежей, статус |
| **Инварианты** | Сумма кредита должна быть > 0; одобрение требует верификации KYC и кредитного скоринга; статусная модель: `Draft → Submitted → Approved → Disbursed → Active → Closed / Defaulted` |
| **Ключевые события** | `LoanApplicationSubmitted`, `LoanApproved`, `LoanDisbursed`, `LoanRepaymentReceived`, `LoanDefaulted` |

---

## BankAccount (Account Management)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `accountId: UUID` |
| **Границы** | Банковский счёт: владелец, тип, валюта, баланс, статус |
| **Инварианты** | Баланс не может быть отрицательным (для расчётных счетов); статус: `Active / Frozen / Closed` |
| **Ключевые события** | `AccountOpened`, `AccountClosed`, `DepositMade`, `WithdrawalProcessed` |

---

## AIDiagnosticRequest (AI Diagnostics)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `requestId: UUID` |
| **Границы** | Запрос на ИИ-диагностику: ссылка на исследование (изображение/данные), модель, результат, confidence score |
| **Инварианты** | Результат не может быть изменён после выдачи; модель обязана быть валидной и зарегистрированной в Model Registry |
| **Ключевые события** | `DiagnosticRequested`, `DiagnosticCompleted`, `DiagnosticFailed` |

---

## PharmaOrder (Pharma Supply Chain)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `orderId: UUID` |
| **Границы** | Заказ поставки: товар, количество, поставщик, цена, дата поставки, статус |
| **Инварианты** | Количество > 0; цена ≥ 0; статусная модель: `Draft → Placed → Shipped → Received / Cancelled` |
| **Ключевые события** | `OrderPlaced`, `OrderShipped`, `OrderReceived`, `InventoryLow` |

---

## ProductionBatch (Equipment Manufacturing)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `batchId: UUID` |
| **Границы** | Производственная партия: продукт, количество, дата выпуска, результаты контроля качества |
| **Инварианты** | Количество в партии > 0; контроль качества обязателен перед выпуском; статус: `Planned → InProgress → QualityCheck → Completed / Failed` |
| **Ключевые события** | `ProductionStarted`, `BatchCompleted`, `QualityCheckPassed`, `QualityCheckFailed` |

---

## DataProduct (Data Marketplace)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `productId: UUID` |
| **Границы** | Data Product: владелец (домен), описание схемы, политика доступа, SLA, статус |
| **Инварианты** | Каждый Data Product принадлежит ровно одному домену; схема должна быть зарегистрирована в Schema Registry; статус: `Draft → Published → Deprecated → Retired` |
| **Ключевые события** | `DataProductPublished`, `DataProductDeprecated`, `DataProductRetired` |

---

## User (Identity & Access)

| Свойство | Значение |
|---|---|
| **Идентификатор** | `userId: UUID` |
| **Границы** | Учётная запись пользователя: логин, роли, разрешения по доменам, профиль |
| **Инварианты** | Email уникален; пользователь должен иметь хотя бы одну роль; роли иерархичны (нельзя назначить роль без вышестоящего разрешения) |
| **Ключевые события** | `UserCreated`, `RoleAssigned`, `PermissionRevoked` |
