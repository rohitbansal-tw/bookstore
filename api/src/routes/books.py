from typing import List

from fastapi import APIRouter

from src.domain.book_entity import CreateBook, BookEntity
from src.service.book_service import BookService

router = APIRouter()
book_service = BookService()


@router.get(path="/", response_model=List[BookEntity])
def read_book():
    return book_service.get_books()

@router.post(path="/", response_model=BookEntity)
def create_book(book: CreateBook):
    return book_service.add_book(book)
