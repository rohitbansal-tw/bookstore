from typing import List

from antidote import injectable

from src.db.base import get_db
from src.db.models import Book


@injectable
class BookRepository:
    def __init__(self):
        pass

    def get_books(self) -> List[Book]:
        with get_db() as db:
            return db.query(Book).all()

    def add_book(self, book: Book) -> Book:
        with get_db() as db:
            db.add(book)
            db.commit()
            db.refresh(book)
            return book
