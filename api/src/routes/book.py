from fastapi import APIRouter

from src.models.book import Book

router = APIRouter()


@router.get("/", response_model=Book)
def read_book():
    return Book(id=1, title="Book Title", author="Book Author", year=2021)