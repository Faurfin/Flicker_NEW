import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # <--- ДОБАВИЛИ ИМПОРТ
from app.api.auth import router as auth_router
from app.db.database import engine, Base
from app.api.users import router as users_router
from fastapi.staticfiles import StaticFiles
# Современный способ выполнять код при старте и выключении сервера
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Логика при запуске
    async with engine.begin() as conn:
        # ДОБАВЛЯЕМ ЭТУ СТРОЧКУ: она удалит старую базу перед созданием новой
        await conn.run_sync(Base.metadata.drop_all) 
        
        # Создаем новую базу со всеми колонками
        await conn.run_sync(Base.metadata.create_all)
    
    yield # Здесь приложение работает
app = FastAPI(title="Backend API", lifespan=lifespan)

# <--- ДОБАВИЛИ НАСТРОЙКИ CORS СЮДА --->
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Разрешает запросы с любых портов (браузера)
    allow_credentials=True,
    allow_methods=["*"],  # Разрешает OPTIONS, POST, GET и т.д.
    allow_headers=["*"],
)

os.makedirs("static/avatars", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")    
# Подключаем наши роуты
app.include_router(auth_router, prefix="/api")
app.include_router(users_router, prefix="/api")

if __name__ == "__main__":
    import uvicorn
    # У тебя стоит reload=True, поэтому сервер сам перезагрузится при сохранении файла!
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)