# Database Manager Skill

 универсальный инструмент управления базами данных с поддержкой MySQL, PostgreSQL, MongoDB, Redis.

## Возможности

- **MySQL/PostgreSQL**: запросы, дампы, таблицы, индексы, пользователи
- **MongoDB**: коллекции, документы, индексы, агрегации
- **Redis**: ключи, строки, списки, хэши, кэш управление

## Команды

```bash
# Версия и справка
db --version
db --help

# MySQL команды
db mysql list                  # Список баз данных
db mysql tables <db>           # Список таблиц
db mysql query <db> "<sql>"   # Выполнить запрос
db mysql dump <db>             # Экспорт базы данных
db mysql users                 # Список пользователей
db mysql size <db>             # Размер базы данных
db mysql processlist           # Текущие процессы

# PostgreSQL команды
db postgres list              # Список баз данных
db postgres tables <db>       # Список таблиц
db postgres query <db> "<sql>" # Выполнить запрос
db postgres dump <db>         # Экспорт базы данных
db postgres size <db>         # Размер базы данных
db postgres connections       # Активные соединения

# MongoDB команды
db mongo list                 # Список баз данных
db mongo collections <db>     # Список коллекций
db mongo find <db>.<col>      # Найти документы
db mongo insert <db>.<col> <json>  # Вставить документ
db mongo count <db>.<col>     # Количество документов
db mongo indexes <db>.<col>   # Индексы коллекции

# Redis команды
db redis keys <pattern>       # Найти ключи
db redis get <key>           # Получить значение
db redis set <key> <value>   # Установить значение
db redis del <key>           # Удалить ключ
db redis info                 # Информация о сервере
db redis flush                # Очистить все ключи
db redis ttl <key>            # TTL ключа

# Общие команды
db backup <type> <target>    # Создать бэкап
db restore <type> <backup>   # Восстановить из бэкапа
db health <type>             # Проверить здоровье БД
```

## Примеры

```bash
# Подключение к MySQL и список таблиц
db mysql tables myapp

# Выполнить запрос
db mysql query myapp "SELECT * FROM users LIMIT 10"

# Найти ключи в Redis
db redis keys "user:*"

# Проверить здоровье PostgreSQL
db health postgres
```

## Требования

- MySQL: `mysql` клиент
- PostgreSQL: `psql` клиент  
- MongoDB: `mongosh` или `mongo` клиент
- Redis: `redis-cli`

## Для резюме

Этот навык демонстрирует:
- Управление базами данных (MySQL, PostgreSQL, MongoDB, Redis)
- Навыки DevOps и администрирования
- Написание скриптов на Bash
- Резервное копирование и восстановление
- Мониторинг и оптимизация
