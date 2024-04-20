from fastapi import FastAPI, APIRouter
from src.routes.books import router
import uvicorn

app = FastAPI()

default_router = APIRouter()


@default_router.get("/", tags=["root"])
def read_root():
    return {"message": "Welcome to your book store!"}


app.include_router(router, prefix="/books", tags=["books"])
app.include_router(default_router)


def start():
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
