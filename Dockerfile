# [FEATURE] Docker image for SimpleChat (OPTIONAL deploy path).
#
# This image bundles BOTH the FastAPI backend and the Streamlit frontend so a
# single image can run either service; docker-compose.yml runs two containers
# from it (one backend, one frontend). The localhost default (uvicorn +
# streamlit run, see docs/deployment.md) is unaffected by this file — Docker is
# purely additive and adds no external service dependency.
FROM python:3.11-slim

WORKDIR /app

# System deps kept minimal; bcrypt/cryptography ship wheels for slim.
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Backend listens on 8000, frontend on 8501. The actual command is chosen per
# service in docker-compose.yml.
EXPOSE 8000 8501

# Default command runs the backend; the frontend service overrides this.
CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
