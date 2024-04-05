# Bookstore API

This is a simple API for a bookstore. It allows you to create, read, update, and delete books. The application is 
using [Poetry](https://python-poetry.org/) for dependency management. 

NOTE: All of the below commands should be run from the `api` directory.
```commandline
cd api
```

## Install poetry and dependencies

To install Poetry, run the following command:
```commandline
pip install poetry
```

After installing Poetry, navigate to the project directory and run the following command to install the dependencies:
```commandline
poetry install
```

To update the dependencies, run the following command:
```commandline
poetry update
```

To see the configured environment details, run the following command:
```commandline
poetry env info
```

## Setup database using alembic migrations

The application uses [Alembic](https://alembic.sqlalchemy.org/en/latest/) for database migrations. It is a 
lightweight database migration tool for SQLAlchemy.

### SQLite
By default, the application uses SQLite as the database. The database file `books.db` is created in the `api` directory.

Note: SQLite sometimes has issues with unable to find the database file/tables. If you encounter any issues, please use
Postgres as the database.

### Postgres
If you like to use postgres. Start postgres locally and update the database URL in the [src/config.py](src/config.py) 
to point to your database. The database URL format should be as follows:

```command
postgresql://<username>:<password>@<host>:<port>/<database>
```

## Running the migrations
The models are defined in the [src/models.py](src/db/models.py) file. These models are used to create the migrations.

To run the migrations, execute the following command:
```commandline
poetry run alembic upgrade head
```

## Update database using alembic migrations

Add/Update database models in the [src/models.py](src/db/models.py) file. The changes will be applied to the database using
Alembic migrations.

To create a new migration, run the following command:
```commandline
poetry run alembic revision --autogenerate -m "migration message"
```

Execute the following command to apply the changes to the database:
```commandline
poetry run alembic upgrade head
```

## Running the application

To run the application, execute the following command:
```commandline
poetry run main
```

The application will start running on `http://localhost:8000`.

Swagger documentation is available at `http://localhost:8000/docs`.

## Running the tests

To run the tests, execute the following command:
```commandline
poetry run pytest
```