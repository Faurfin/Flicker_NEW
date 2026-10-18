# Фликер

Социальная сеть нового типа: без лайков и «виртуальных гонок» — только реальные друзья, голосовые комнаты и живые реакции. Пользователь входит по номеру телефона, заполняет профиль с интересами и находит людей со схожими увлечениями; приглашения раздаются по персональной ссылке и QR-коду.

![Flutter](https://img.shields.io/badge/Flutter-Dart%203.12-02569B?logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-Python%203.11-009688?logo=fastapi&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)
![Платформы](https://img.shields.io/badge/Android%20%7C%20iOS%20%7C%20Web-mobile-3DDC84?logo=android&logoColor=white)

## 📒 Содержание

- [О проекте](#-о-проекте)
  - [Боль](#-боль)
  - [Решение](#-решение)
  - [Стек](#-стек)
  - [Дизайн](#-дизайн)
  - [Экраны приложения](#-экраны-приложения)
- [Использование](#-использование)
  - [Установка](#-установка)
  - [Команды](#-команды)
  - [API](#-api)
- [Разработка](#-разработка)
  - [Требования](#-требования)
  - [Окружение разработки](#-окружение-разработки)
  - [Структура файлов](#-структура-файлов)
  - [Сборка](#-сборка)
  - [Развёртывание](#-развёртывание)
  - [Известные ограничения](#-известные-ограничения)
- [Сообщество](#-сообщество)
  - [Как помочь](#-как-помочь)
  - [Ветки](#-ветки)
  - [Правила](#-правила)
- [FAQ](#-faq)
- [Ресурсы](#-ресурсы)
- [Галерея](#-галерея)
- [Благодарности](#-благодарности)
- [Лицензия](#-лицензия)

## 🔰 О проекте

«Фликер» — клиент-серверная система из двух частей:

- **мобильное приложение** (Flutter, Android/iOS/Web) — онбординг, вход по телефону с OTP-кодом, заполнение профиля (имя, аватар, интересы, источник), лента друзей, поиск людей, приглашения по ссылке и QR-коду;
- **API** (FastAPI + PostgreSQL + Redis) — выпуск OTP-кодов, регистрация и профили пользователей, рекомендации по пересечению интересов и поиск по имени.

### 🧭 Боль

- Классические соцсети заточены под лайки и метрики популярности, а не под живое общение.
- Найти близких по интересам людей среди «шума» ленты сложно.
- Обмен контактами в мессенджерах неудобен: нет единой ссылки-визитки.

### 💡 Решение

1. **Вход без пароля.** Пользователь вводит номер телефона, получает 5-значный код (пока — в лог сервиса), вводит его и попадает в приложение. Код живёт 3 минуты в Redis.
2. **Профиль.** Новый пользователь проходит онбординг: имя и аватар, ровно 3 интереса из каталога, источник «как вы о нас узнали».
3. **Поиск и рекомендации.** Поиск по имени (ILIKE) и рекомендации по пересечению интересов с возможностью скрыть человека навсегда.
4. **Приглашения.** У каждого — персональная ссылка `fliker://app/profile/{username}` и QR-код, который можно сохранить в галерею или отправить.

### 🧱 Стек

| Слой | Технологии |
|------|------------|
| Клиент | Flutter, Dart SDK `^3.12.0`: dio, http, shared_preferences, flutter_svg, image_picker, pinput, qr, qr_flutter, share_plus, image_gallery_saver_plus |
| API | FastAPI, uvicorn, SQLAlchemy 2 (async) + asyncpg, pydantic v2, pydantic-settings, redis |
| Данные | PostgreSQL 15 (схема создаётся автоматически через `Base.metadata.create_all`), Redis 7 (одноразовые коды) |
| Инфраструктура | Docker Compose (db + redis + web + caddy), Caddy как reverse-proxy с HTTPS на `api.web-flicker.online` |
| Эксперимент | `backend/go_app/` — отдельный Gin-сервис на Go с моковым профилем (порт 8080) |

### 🎨 Дизайн

- **Тёмная тема** — фон `#0A0A0A`, акцент «лайм» `#C7F431` (Brand/900), поля ввода `#161616`, неактивные элементы `#27272A`, серый текст `#A1A1AA` / `#8E8E93`.
- **Стекло** — навигация и карточки используют `BackdropFilter` (blur 10) поверх полупрозрачного `#1C1C1C` (50%), скругления 12–16.
- **Иконки** — локальные SVG из `assets/icons/` с перекраской через `ColorFilter`; интернет при запуске не нужен.
- Палитра и URL API пока **дублируются в каждом экране** — вынос в тему и конфиг запланирован (см. [Известные ограничения](#-известные-ограничения)).

### 📱 Экраны приложения

| Место | Экран | Файл | Состояние |
|-------|-------|------|-----------|
| Первый запуск | `OnboardingScreen` | `lib/onboarding_screen.dart` | 3 слайда, ставит `isFirstLaunch=false` |
| Вход | `LoginScreen` | `lib/features/auth/ui/login_screen.dart` | Реальная отправка кода, маска `+7 (###) ###-##-##` |
| Код | `VerifyCodeScreen` | `lib/features/auth/ui/verify_code_screen.dart` | 5 ячеек кода, таймер 50 с, повторная отправка |
| Профиль | `ProfileSetupScreen` | `lib/features/auth/ui/profile_setup_screen.dart` | 3 шага: имя+аватар, 3 интереса, источник |
| Главная | `MainScreen` | `lib/features/home/ui/main_screen.dart` | Стеклянная нижняя навигация, пустое состояние ленты |
| Поиск | `SearchScreen` | `lib/features/home/ui/search_screen.dart` | Живой поиск по API, карточка приглашения |
| QR | `QrScreen` | `lib/features/home/ui/qr_screen.dart` | Персональный QR: копировать / сохранить / поделиться |
| Чужой профиль | `AlienProfileScreen` | `lib/features/profile/ui/alien_profile_screen.dart` | Статичный макет с моковыми данными |

Устаревшие экраны `otp_screen.dart` и `registration_screens.dart` остались от предыдущей итерации и не подключены к `main.dart` (см. [ARCHITECTURE.md](./ARCHITECTURE.md)).

## ⚡ Использование

### 🔌 Установка

**1. База данных и Redis**

```bash
cd backend
docker compose up -d db redis   # PostgreSQL на localhost:5455, Redis на localhost:6379
```

**2. API**

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate            # Windows (PowerShell)
pip install -r requirements.txt
uvicorn app.main:app --reload     # http://localhost:8000
```

Схема БД (таблицы `users` и `hidden_recommendations`) создаётся автоматически при старте через `Base.metadata.create_all`. Переменные окружения: `DB_HOST` и `REDIS_HOST` (по умолчанию `127.0.0.1`); логин/пароль/имя БД заданы в `app/core/config.py`.

> ⚠️ Compose выставляет PostgreSQL на порт **5455**, а `DATABASE_URL` в коде жёстко использует **5432** — при локальном запуске `uvicorn` против compose-БД задайте порт в строке подключения или запускайте `web` в контейнере.

**3. Мобильное приложение**

```bash
cd frontend
flutter pub get
flutter run
```

Адрес API захардкожен в `frontend/lib/core/api/api_client.dart` и в экранах:

```dart
static const String baseUrl = 'https://api.web-flicker.online/api';
```

Для локальной разработки замените хост на IP машины в той же сети, что и телефон (`localhost` с физического устройства не подойдёт).

### 📦 Команды

| Действие | Команда |
|----------|---------|
| Поднять БД и Redis | `cd backend && docker compose up -d db redis` |
| Поднять весь стек в Docker | `cd backend && docker compose up -d` (API на `localhost:8000`) |
| Запустить API локально | `cd backend && uvicorn app.main:app --reload` |
| Проверить живость API | `curl http://localhost:8000/docs` |
| Поставить зависимости клиента | `cd frontend && flutter pub get` |
| Запустить клиент | `cd frontend && flutter run` |
| Статический анализ клиента | `cd frontend && flutter analyze` |
| Собрать APK | `cd frontend && flutter build apk --release` |
| Экспериментальный Go-сервис | `cd backend/go_app && go run main.go` (порт 8080) |

### 📡 API

| Метод | Путь | Авторизация | Назначение |
|-------|------|-------------|------------|
| `POST` | `/api/auth/send-code` | — | Отправить одноразовый код на номер (код — в лог сервиса) |
| `POST` | `/api/auth/verify-code` | — | Проверить код; создать пользователя при первом входе |
| `POST` | `/api/auth/update-profile` | — | Заполнить профиль: имя, интересы, источник, аватар (base64) |
| `GET` | `/api/users/recommendations` | `?phone_number=` | До 5 человек с общими интересами, без скрытых |
| `POST` | `/api/users/hide-recommendation` | `?phone_number=` | Навсегда скрыть пользователя из рекомендаций |
| `GET` | `/api/users/me` | `?phone_number=` | Свой профиль: username, avatar, пригласительная ссылка |
| `GET` | `/api/users/search` | `?q=&phone_number=` | Поиск по имени (ILIKE), до 20 результатов |
| `GET` | `/api/users/{id}/profile` | — | Моковый профиль (отдельный Gin-сервис, порт 8080) |

**Вход**

```jsonc
// POST /api/auth/send-code
{ "phone_number": "+79991234567" }
// → 200 { "message": "Код отправлен" }

// POST /api/auth/verify-code
{ "phone_number": "+79991234567", "code": "48213" }
// → 200 { "access_token": "token_for_user_1", "is_new_user": true, "message": "Успешно" }
```

SMS-провайдер не подключён: 5-значный код печатается в лог сервиса, хранится в Redis 3 минуты (`sms:{phone}`), после проверки удаляется. Токен пока фейковый (`token_for_user_{id}`) и нигде не проверяется — см. [Известные ограничения](#-известные-ограничения).

**Профиль**

```jsonc
// POST /api/auth/update-profile
{
  "phone_number": "+79991234567",
  "name": "Максим",
  "interests": ["CS2", "Футбол", "Кино"],
  "discovery_source": "TikTok/Reels",
  "avatar_base64": "..."   // необязательно; сохраняется в static/avatars/
}
```

**Поиск и профиль**

```jsonc
// GET /api/users/search?q=макс&phone_number=%2B79991234567
// → [ { "id": 2, "username": "Максим", "avatar": "...", "followers_count": 24 } ]

// GET /api/users/me?phone_number=%2B79991234567
// → { "id": "1", "username": "user_1", "avatar": "https://i.pravatar.cc/150",
//     "link": "fliker://app/profile/user_1" }
```

Идентификация пользователя везде идёт **по номеру телефона в query-параметре** — любой может подставить чужой номер. Это временное решение до появления настоящей JWT-авторизации.

## 🔧 Разработка

### 📝 Требования

| Инструмент | Версия | Зачем |
|------------|--------|-------|
| Docker | любой актуальный | PostgreSQL, Redis, Caddy |
| Python | 3.11+ | Запуск API |
| Flutter SDK | с Dart `^3.12.0` | Сборка клиента |
| Go | 1.21+ | Только для эксперимента `backend/go_app/` |

В корне репозитория лежит каталог `flutter/` — это **полный чек-аут Flutter SDK** (инструмент), а не код проекта; править его не нужно.

### 🔩 Окружение разработки

1. Перейдите в нужную часть репозитория: `frontend/` — клиент, `backend/` — API.
2. Переменные окружения API:

| Переменная | Значение по умолчанию | Назначение |
|------------|----------------------|------------|
| `DB_HOST` | `127.0.0.1` | Хост PostgreSQL |
| `REDIS_HOST` | `127.0.0.1` | Хост Redis |
| `DB_USER` / `DB_PASS` / `DB_NAME` | `backend_user` / `backend_password` / `backend_db` | Учётные данные (в `config.py`, не из ENV) |

3. Установите зависимости клиента: `cd frontend && flutter pub get`.

### 📁 Структура файлов

```
Flicker_NEW/
├── frontend/              # Flutter-клиент (package frontend)
│   ├── assets/            # иконки (SVG/PNG), картинки онбординга
│   ├── lib/               # исходники UI и сервисов
│   ├── test/              # тесты (widget_test.dart пока не проходит)
│   └── web/               # заготовка web-таргета
├── backend/               # FastAPI (app/) + эксперимент на Go (go_app/)
│   ├── app/               # main, api, core, db, schemas, services
│   ├── go_app/            # Gin-сервис с моковым профилем
│   ├── Dockerfile / docker-compose.yml / Caddyfile
│   └── requirements.txt
├── flutter/               # Flutter SDK (инструмент, не трогаем)
└── README.md / ARCHITECTURE.md / AGENTS.md
```

| № | Файл | Назначение |
|---|------|------------|
| 1 | [frontend/lib/main.dart](./frontend/lib/main.dart) | Точка входа, `FlickerApp`, маршрут онбординг/вход |
| 2 | [frontend/lib/core/api/api_client.dart](./frontend/lib/core/api/api_client.dart) | Dio-клиент: baseUrl, таймауты, заголовки |
| 3 | [frontend/lib/features/auth/ui/login_screen.dart](./frontend/lib/features/auth/ui/login_screen.dart) | Вход по номеру телефона |
| 4 | [frontend/lib/features/auth/ui/verify_code_screen.dart](./frontend/lib/features/auth/ui/verify_code_screen.dart) | Проверка OTP-кода |
| 5 | [frontend/lib/features/auth/ui/profile_setup_screen.dart](./frontend/lib/features/auth/ui/profile_setup_screen.dart) | Онбординг профиля (3 шага) |
| 6 | [frontend/lib/features/home/ui/main_screen.dart](./frontend/lib/features/home/ui/main_screen.dart) | Главный экран и навигация |
| 7 | [frontend/lib/features/home/ui/search_screen.dart](./frontend/lib/features/home/ui/search_screen.dart) | Поиск людей и приглашения |
| 8 | [frontend/lib/features/home/ui/qr_screen.dart](./frontend/lib/features/home/ui/qr_screen.dart) | QR-код профиля |
| 9 | [backend/app/main.py](./backend/app/main.py) | Приложение FastAPI, CORS, статика, роутеры |
| 10 | [backend/app/services/auth_service.py](./backend/app/services/auth_service.py) | OTP-коды, регистрация, профиль |
| 11 | [backend/app/api/users.py](./backend/app/api/users.py) | Рекомендации, поиск, профиль |
| 12 | [backend/app/db/models.py](./backend/app/db/models.py) | Модели SQLAlchemy |
| 13 | [ARCHITECTURE.md](./ARCHITECTURE.md) | Полная карта модулей и публичных сущностей |

### 🔨 Сборка

**API**

```bash
cd backend
python -m compileall app         # проверка синтаксиса
# запуск: uvicorn app.main:app --reload
```

**Клиент**

```bash
cd frontend
flutter analyze
flutter test                     # test/widget_test.dart пока не проходит — см. ограничения
flutter build apk --release      # или: flutter build web
```

### 🚀 Развёртывание

Весь стек поднимается одним compose-файлом:

```bash
cd backend
docker compose up -d             # db + redis + web + caddy
```

| Сервис | Порт хоста | Особенности |
|--------|-----------|-------------|
| `web` | `8000` | FastAPI из `Dockerfile` (`python:3.11-slim`, uvicorn), ENV `DB_HOST=db`, `REDIS_HOST=redis` |
| `db` | `5455 → 5432` | `postgres:15-alpine`, том `postgres_data`, БД `backend_db` |
| `redis` | `6379` | `redis:7-alpine` |
| `caddy` | `80`, `443` | Reverse-proxy `api.web-flicker.online` → `web:8000`, авто-HTTPS |

Перед публикацией в прод обязательно замените учётные данные БД (сейчас лежат в `docker-compose.yml` и в дефолтах `config.py`) и введите настоящую JWT-авторизацию: сейчас токен фейковый, а личность определяется по номеру телефона в query.

### ⚠️ Известные ограничения

- **Авторизация небезопасна и недоделана**: `access_token` — строка `token_for_user_{id}` без подписи; ни один эндпоинт токен не проверяет; личность передаётся номером телефона в query-параметре — чужой профиль можно прочитать и изменить, зная номер.
- **`POST /api/auth/update-profile` падает**: `auth_service.py` присваивает `user.is_new_user = False`, но колонки `is_new_user` в модели `User` нет → `AttributeError` и 500.
- Адрес API захардкожен в `api_client.dart` и ещё в семи файлах экранов (`login_screen`, `verify_code_screen`, `profile_setup_screen`, `search_screen`, `qr_screen`, `otp_screen`, `registration_screens`).
- `ApiClient` (Dio) почти не используется: экраны ходят через `package:http` напрямую; `features/auth/data/auth_repository.dart` не подключён.
- `test/widget_test.dart` не собирается: тест ссылается на `MyApp` и счётчик, а в `main.dart` — `FlickerApp`.
- `otp_screen.dart` и `registration_screens.dart` — мёртвый код предыдущей итерации (дублируют `features/auth/`), из `main.dart` не вызываются.
- `backend/app/main.py` монтирует `/static` дважды; путь сохранения аватарок строится от текущей рабочей директории, а не от `STATIC_DIR`.
- CORS настроен как `allow_origins=["*"]` вместе с `allow_credentials=True` — для прода так нельзя.
- SQLAlchemy-движок создан с `echo=True` — в лог уходит весь SQL.
- В поиске и профиле — заглушки: `followers_count` всегда 24 (колонки нет), аватары-плейсхолдеры `via.placeholder.com` и `i.pravatar.cc`; `/me` возвращает пригласительную ссылку `fliker://app/profile/...`, которую клиент пока не обрабатывает.
- Эндпоинт `GET /api/users/recommendations` готов на бэкенде, но ни один экран его ещё не использует.
- `backend/go_app/` — эксперимент: Gin-сервис с одним моковым эндпоинтом и пустым Dockerfile; в compose не входит.
- Разнобой названия: UI пишет «Фликер», QR-шеринг — «Fliker», package в `pubspec.yaml` — `frontend`, деплой — `web-flicker.online`.
- Нет корневого `.gitignore` и лицензии; миграций нет — схема создаётся `create_all` и умеет только добавлять новые таблицы.

## 🌸 Сообщество

Проект развивается как внутренний MVP. Правки приветствуются через pull request к ветке разработки.

### 🔥 Как помочь

1. **Сообщить о проблеме** — опишите шаги воспроизведения, устройство и версию приложения.
2. **Предложить функцию** — коротко опишите сценарий и ожидаемый результат.
3. **Прислать pull request** — одна задача на один PR, минимальный diff, обновлённые документы, если менялся контракт API.

### 🌵 Ветки

Рекомендуемая схема:

1. **`stage`** — ветка разработки, все изменения идут сюда.
2. **`master`** — стабильная ветка, обновляется из `stage` по готовности.
3. Постоянных веток больше не создаётся: под задачу берётся feature-ветка (`feat-НАЗВАНИЕ`), после проверки она вливается в `stage`.

### ❗ Правила

Обязательные правила для людей и ИИ-агентов вынесены в [AGENTS.md](./AGENTS.md): чеклист перед новой функцией, границы модулей, требования к стилю и порядок обновления документации.

## ❓ FAQ

**Где взять код из SMS?**
SMS-шлюза нет: код печатается в лог сервиса (`[+79991234567] ---> СМС КОД: 48213`). Живёт 3 минуты, после проверки удаляется.

**Почему `update-profile` возвращает 500?**
Известный баг: сервис пишет несуществующее поле `is_new_user` на модель `User`. См. [Известные ограничения](#-известные-ограничения).

**Локальный API не подключается к БД.**
Compose выставляет PostgreSQL на порт 5455, а строка подключения в коде использует 5432. Запускайте API в контейнере или поправьте порт в `DATABASE_URL`.

**Как поменять адрес API в приложении?**
Пока он захардкожен в `lib/core/api/api_client.dart` и в экранах (`https://api.web-flicker.online`). Для локальной отладки замените на `http://<IP-машины>:8000/api` во всех местах.

**Почему у всех 24 подписчика?**
`followers_count` — заглушка: колонки в БД нет, эндпоинт подставляет 24.

**Что делает Go-сервис в `backend/go_app`?**
Это эксперимент-дублёр: отдаёт моковый профиль `GET /api/users/{id}/profile` на порту 8080. Продакшн-логика живёт в FastAPI.

## 📄 Ресурсы

- [Flutter](https://docs.flutter.dev/) — документация фреймворка
- [FastAPI](https://fastapi.tiangolo.com/) — веб-фреймворк и OpenAPI-документация (`/docs`)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/) — async ORM
- [asyncpg](https://github.com/MagicStack/asyncpg) — драйвер PostgreSQL
- [redis-py](https://redis-py.readthedocs.io/) — клиент Redis
- [pydantic v2](https://docs.pydantic.dev/) — валидация схем
- [Caddy](https://caddyserver.com/docs/) — reverse-proxy и авто-HTTPS
- [Gin](https://gin-gonic.com/) — веб-фреймворк Go (эксперимент)

## 📷 Галерея

Скриншоты в репозитории пока не добавлены; для быстрого превью интерфейса запустите приложение командой `flutter run`.

## 🌟 Благодарности

Проект стоит на открытых библиотеках: Flutter, FastAPI, SQLAlchemy, PostgreSQL, Redis, Caddy и Gin. Иконки и иллюстрации лежат в `frontend/assets/` и используются внутри проекта.

## 🔒 Лицензия

Файл лицензии в репозитории отсутствует — лицензия не определена. До её появления код считается «все права защищены».
