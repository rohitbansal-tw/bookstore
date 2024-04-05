from contextlib import contextmanager

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session, DeclarativeBase

from src.config import db_url


@contextmanager
def get_db() -> Session:
    db = SessionFact()
    try:
        yield db
    finally:
        db.close()


class Base(DeclarativeBase):
    pass


engine = create_engine(db_url)
SessionFact = sessionmaker(autocommit=False, autoflush=False, bind=engine)
