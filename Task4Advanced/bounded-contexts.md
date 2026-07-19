# Bounded Contexts — «Будущее 2.0»

## Контекстная карта

```mermaid
graph TB
    subgraph "Medical"
        PC["Patient Management"]
        CR["Clinical Records"]
        AS["Appointment Scheduling"]
    end

    subgraph "Fintech"
        BP["Billing & Payments"]
        LD["Lending"]
        AM["Account Management"]
    end

    subgraph "AI"
        AD["AI Diagnostics"]
    end

    subgraph "Pharma"
        PS["Pharma Supply Chain"]
    end

    subgraph "Electronics"
        EM["Equipment Manufacturing"]
    end

    subgraph "Platform"
        DM["Data Marketplace"]
        IAM["Identity & Access"]
        LI["Legacy Integration<br/>(ACL)"]
    end

    PC -->|PatientRegistered| CR
    PC -->|PatientRegistered| BP
    PC -->|PatientRegistered| AS

    AS -->|AppointmentCompleted| CR
    AS -->|AppointmentCompleted| BP

    CR -->|DiagnosisRecorded| AD
    CR -->|TreatmentPrescribed| PS
    CR -->|TreatmentPrescribed| BP

    BP -->|PaymentCompleted| LD
    BP -->|PaymentCompleted| AM

    AD -->|DiagnosticCompleted| CR

    PS -->|OrderShipped| EM

    PC -->|DataProductPublished| DM
    CR -->|DataProductPublished| DM
    BP -->|DataProductPublished| DM
    LD -->|DataProductPublished| DM
    AM -->|DataProductPublished| DM
    AD -->|DataProductPublished| DM
    PS -->|DataProductPublished| DM
    EM -->|DataProductPublished| DM

    DM -->|DataProductAccessed| IAM

    LI -.->|CDC / Camel| PC
    LI -.->|CDC / Camel| CR
    LI -.->|CDC / Camel| BP
```

## Описание bounded contexts

| # | Bounded Context | Домен | Ответственность | Ключевой агрегат |
|---|---|---|---|---|
| 1 | Patient Management | Medical | Регистрация и ведение профилей пациентов | Patient |
| 2 | Clinical Records | Medical | Медицинские карты, диагнозы, назначения | MedicalRecord |
| 3 | Appointment Scheduling | Medical | Запись к врачу, расписание | Appointment |
| 4 | Billing & Payments | Fintech | Оплата услуг, обработка транзакций | Payment |
| 5 | Lending | Fintech | Кредитные договоры, займы | LoanAgreement |
| 6 | Account Management | Fintech | Банковские счета, остатки | BankAccount |
| 7 | AI Diagnostics | AI | ИИ-диагностика изображений и данных | AIDiagnosticRequest |
| 8 | Pharma Supply Chain | Pharma | Управление фарм. поставками | PharmaOrder |
| 9 | Equipment Manufacturing | Electronics | Производство мед. оборудования | ProductionBatch |
| 10 | Data Marketplace | Platform | Каталог Data Product, самообслуживание | DataProduct |
| 11 | Identity & Access | Platform | SSO, RBAC, аудит доступа | User |
| 12 | Legacy Integration | Platform | Anti-Corruption Layer для DWH и ESB | — (интеграция) |

## Правила взаимодействия

1. **Нет прямых синхронных вызовов между bounded contexts** — только асинхронные события через Kafka.
2. **Каждый контекст владеет своими данными** — публикует Data Product через Data Marketplace, а не через общую БД.
3. **Clinical Records не экспортирует данные в Data Marketplace** — согласно политике компании, медкарты и истории болезней не используются для аналитики.
4. **Legacy Integration** — единственный контекст, имеющий прямой доступ к DWH и ESB; все остальные контексты взаимодействуют с легаси только через него.
