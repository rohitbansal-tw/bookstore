from fastapi import FastAPI
from src.routes.books import router
import uvicorn

app = FastAPI()

app.include_router(router, prefix="/books", tags=["books"])


def start():
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
