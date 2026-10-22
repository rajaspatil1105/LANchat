# 💬 SimpleChat

A real-time client–server chat application built for the **Data Communications**
course. It demonstrates a complete REST + WebSocket architecture running entirely
on localhost.

| Layer | Technology |
|---|---|
| Frontend | Streamlit (port **8501**) |
| Backend | FastAPI + Uvicorn (port **8000**) |
| Database | SQLite (`backend/chat_db.sqlite`) |
| Auth | bcrypt password hashing + JWT |

## Features

- 🔐 **Register & login** — passwords hashed with bcrypt, never stored in plaintext
- 🪪 **JWT authentication** — every protected route requires a Bearer token
- 💬 **Chat** — send messages, newest at the bottom, persists across refreshes
- 🔄 **Polling** — the message panel auto-refreshes every 2 seconds
- ⚡ **WebSockets** — `/ws/{username}` pushes new messages in real time
- 🔍 **Search** — free-text search over message content (SQL-injection-safe)
- 👥 **Group chats** — create and join named groups
- 📎 **File / image sharing** — upload files; images render inline
- 🔔 **Push notifications** — toast pop-ups when others send messages

## Setup

```powershell
# 1. From the simplechat/ folder, create a virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1        # Windows PowerShell
# source .venv/bin/activate          # macOS / Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create your .env (a working one is already included for localhost)
#    To regenerate the secret key:
#    python -c "import secrets; print(secrets.token_hex(32))"
```

## Run

Open **two terminals**, both in the `simplechat/` folder.

**Terminal 1 — backend:**
```powershell
uvicorn backend.main:app --reload --port 8000
```

**Terminal 2 — frontend:**
```powershell
streamlit run frontend/app.py
```

Then open <http://localhost:8501> in your browser:

1. **Register** a new account.
2. **Log in** — you receive a JWT stored in the Streamlit session.
3. **Chat** in the public channel, create a group, search, or share a file.

The interactive API docs are available at <http://localhost:8000/docs>.

## Project structure

```
simplechat/
├── backend/
│   ├── main.py        FastAPI app — routes, CORS, file upload, WebSocket
│   ├── database.py    SQLite connection + all parameterized CRUD queries
│   ├── auth.py        bcrypt hashing + JWT create/validate
│   ├── models.py      Pydantic request/response schemas
│   ├── chat_db.sqlite (auto-generated on first run)
│   └── uploads/       (auto-generated; stored shared files)
├── frontend/
│   └── app.py         Streamlit UI — login, chat, polling, search, groups, files
├── docs/              Spec + project-management documents
├── .env               SECRET_KEY and config (git-ignored)
├── requirements.txt
└── README.md
```

## Deployment (optional — external server)

The app can be deployed as **two web services** (backend + frontend). A
ready-to-use [`render.yaml`](render.yaml) blueprint is included for
[Render.com](https://render.com):

1. Push this repo to GitHub.
2. In Render: **New → Blueprint** → select the repo → it reads `render.yaml`.
3. After the first deploy, set the two cross-service URLs:
   - backend env `ALLOWED_ORIGINS` = `https://<your-frontend>.onrender.com`
   - frontend env `SIMPLECHAT_API_URL` = `https://<your-backend>.onrender.com`

`SECRET_KEY` is generated automatically by Render; CORS origins and the API URL
are both environment-driven, so no code changes are needed to deploy.

> Note: SQLite on a free dyno is ephemeral — the database resets when the
> service restarts. That is fine for a course demo; for persistence, attach a
> disk or switch the `DATABASE_URL` to a managed database.

## Architecture notes

- The frontend **never** touches SQLite — it only calls the backend over HTTP/JSON
  with an `Authorization: Bearer <token>` header.
- All SQL lives in `database.py` and uses parameterized queries (`?`), so the
  search endpoint is safe from SQL injection.
- CORS is configured for `http://localhost:8501` so the Streamlit origin can call
  the API.
- Realtime: the WebSocket endpoint broadcasts every new message; the Streamlit UI
  uses 2-second polling (a fragment with `run_every`) as its practical refresh
  mechanism, since Streamlit reruns its script on every interaction.
