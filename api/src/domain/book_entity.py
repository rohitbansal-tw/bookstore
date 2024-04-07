from pydantic import BaseModel, ConfigDict

from src.db.models import Book


class CreateBook(BaseModel):
    title: str
    author: str
    year: int


class BookEntity(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    author: str
    year: int

    @staticmethod
    def from_db_model(book: Book):
        return BookEntity.model_validate(book)
