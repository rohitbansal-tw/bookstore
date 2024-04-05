from antidote import world, injectable, const


@injectable
class Conf:
    DB_CONNECTION_URL = const.env(default="sqlite:///./books.db")


db_url = world[Conf.DB_CONNECTION_URL]
