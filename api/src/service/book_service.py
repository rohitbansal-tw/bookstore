from typing import List

from antidote import inject

from src.domain.book_entity import CreateBook, BookEntity
from src.db.models import Book
from src.repository.book_repo import BookRepository


class BookService:
    def __init__(self):
        pass

    @inject
    def get_books(self, book_repo: BookRepository =inject.me()) -> List[BookEntity]:
        books = book_repo.get_books()
        return [BookEntity.from_db_model(book) for book in books]

    @inject
    def add_book(self, book: CreateBook, book_repo: BookRepository =inject.me()) -> BookEntity:
        book = Book(**book.dict())
        book = book_repo.add_book(book)
        return BookEntity.from_db_model(book)