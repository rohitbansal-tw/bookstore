from typing import List

from antidote import injectable

from src.repository.base_repo import AbstractRepository
from src.db.models import Book


@injectable
class BookRepository(AbstractRepository):
    def get_books(self) -> List[Book]:
        with self.get_db() as db:
            return db.query(Book).all()

    def add_book(self, book: Book) -> Book:
        with self.get_db() as db:
            db.add(book)
            db.commit()
            db.refresh(book)
            return book
