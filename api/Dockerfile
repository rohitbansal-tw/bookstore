# Use the official Python 3.11 image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY pyproject.toml poetry.lock /app/

# Install Poetry
RUN pip install poetry

# Disable virtualenv creation
RUN poetry config virtualenvs.create false

# Install Poetry and project dependencies
RUN poetry install --no-interaction --no-root

# Copy the rest of the application code to the working directory
COPY . .

EXPOSE 8000

# Run the application
CMD ["poetry", "run", "main"]
