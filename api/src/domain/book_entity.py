from pydantic import BaseModel

from src.db.models import Book


class CreateBook(BaseModel):
    title: str
    author: str
    year: int


class BookEntity(BaseModel):
    id: int
    title: str
    author: str
    year: int

    @staticmethod
    def from_db_model(book: Book):
        return BookEntity(id=book.id, title=book.title, author=book.author, year=book.year)