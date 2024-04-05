from antidote import world, injectable, const


@injectable
class Conf:
    DB_CONNECTION_URL = const.env(default="postgresql://postgres:admin@localhost:5432/bookstore")


db_url = world[Conf.DB_CONNECTION_URL]