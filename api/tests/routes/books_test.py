from unittest import mock

from antidote import world

from src.repository.book_repo import BookRepository
from tests.routes.base_test import BaseTestCase


class TestBooks(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.mock_book_repo = mock.Mock()

    def test_create_book(self):
        with world.test.clone() as overrides:
            overrides[BookRepository] = self.mock_book_repo
            assert world[BookRepository] == self.mock_book_repo

            self.mock_book_repo.add_book.return_value = mock.Mock(
                id=1, title="Book title", author="Book author", year=2021
            )
            response = self.client.post(
                "/books",
                json={"title": "Book title", "author": "Book author", "year": 2021},
            )

        assert self.mock_book_repo.add_book.call_count == 1
        assert response.status_code == 200
        assert response.json() == {
            "id": 1,
            "title": "Book title",
            "author": "Book author",
            "year": 2021,
        }

    def test_get_books(self):
        with world.test.clone() as overrides:
            overrides[BookRepository] = self.mock_book_repo
            assert world[BookRepository] == self.mock_book_repo

            self.mock_book_repo.get_books.return_value = [
                mock.Mock(
                    id=1, title="Book title 1", author="Book author 1", year=2021
                ),
                mock.Mock(
                    id=2, title="Book title 2", author="Book author 2", year=2022
                ),
            ]
            response = self.client.get("/books")

        assert self.mock_book_repo.get_books.call_count == 1
        assert response.status_code == 200
        assert response.json() == [
            {"id": 1, "title": "Book title 1", "author": "Book author 1", "year": 2021},
            {"id": 2, "title": "Book title 2", "author": "Book author 2", "year": 2022},
        ]
