from contextlib import contextmanager

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from src.config import db_url


class AbstractRepository:
    def __init__(self):
        engine = create_engine(db_url)
        self.Session = sessionmaker(bind=engine)

    @contextmanager
    def get_db(self):
        session = self.Session()
        try:
            yield session
        finally:
            session.close()