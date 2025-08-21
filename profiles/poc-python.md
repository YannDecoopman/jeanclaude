# Profil: POC Python/FastAPI

## Objectif
POCs rapides et APIs performantes avec FastAPI. Focus sur "ça marche" avant "c'est parfait".

## Configuration Active

### 🧠 Agents Actifs
1. **resume** (mémoire entre sessions)
2. **fastapi-expert** (expertise FastAPI/Python)
3. **shipit** (ship fast)

### 🔓 Trust Level
**autonomous**

### ⚡ Structure Minimale POC

```
project/
├── main.py           # Tout dans un fichier pour commencer
├── requirements.txt
├── .env
└── README.md
```

### 🚀 FastAPI Quick Start

#### App Minimale
```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    name: str
    price: float

@app.get("/")
def read_root():
    return {"status": "running"}

@app.post("/items/")
def create_item(item: Item):
    return {"item": item, "total": item.price * 1.2}

# Run: uvicorn main:app --reload
```

#### Database Simple (SQLite)
```python
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)

Base.metadata.create_all(bind=engine)
```

### 📝 Patterns POC

#### CRUD Rapide
```python
@app.post("/users/")
def create_user(email: str):
    db = SessionLocal()
    user = User(email=email)
    db.add(user)
    db.commit()
    return {"id": user.id, "email": user.email}

@app.get("/users/")
def list_users():
    db = SessionLocal()
    return db.query(User).all()
```

#### Auth Basique
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials

security = HTTPBasic()

def verify_credentials(credentials: HTTPBasicCredentials = Depends(security)):
    if credentials.username != "admin" or credentials.password != "secret":
        raise HTTPException(status_code=401)
    return credentials.username

@app.get("/protected")
def protected_route(username: str = Depends(verify_credentials)):
    return {"message": f"Hello {username}"}
```

### 🛠 Commandes Essentielles

```bash
# Dev server
uvicorn main:app --reload --port 8000

# Requirements
pip freeze > requirements.txt

# Tests rapides
python -m pytest

# Format code
black .
isort .
```

### ✅ Focus POC
- Validation automatique avec Pydantic
- Documentation auto sur /docs
- Pas de structure complexe au début
- SQLite pour DB rapide
- Pas d'async si pas nécessaire

### 🚫 Ne pas perdre de temps sur
- Architecture parfaite
- Tests exhaustifs
- Optimisations prématurées
- Docker au début
- CI/CD complexe

## Activation Mentale
Quand ce profil est actif, je pense:
- "main.py avec tout dedans pour commencer"
- "Pydantic pour validation gratuite"
- "/docs pour tester l'API"
- "SQLite suffisant pour POC"
- "Refacto quand ça marche"