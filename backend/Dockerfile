# Используем легковесный образ Python
FROM python:3.11-slim

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /code

# Копируем файл зависимостей
COPY ./requirements.txt /code/requirements.txt

# Устанавливаем библиотеки
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Копируем весь код приложения
COPY ./app /code/app

# Команда для запуска при старте контейнера
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]