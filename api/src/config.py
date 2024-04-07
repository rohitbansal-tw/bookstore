import os

from antidote import world, injectable, const

current_working_directory = os.path.dirname(os.path.abspath(__file__))
api_root = os.path.join(current_working_directory, "..")
sqlite_db_url = f"sqlite:///{api_root}/books.db"


@injectable
class Conf:
    DB_CONNECTION_URL = const.env(default=sqlite_db_url)


db_url = world[Conf.DB_CONNECTION_URL]
