# Leçons Apprises - Base de Connaissances

## WordPress / Docker

### Erreurs Fréquentes
| Date | Problème | Solution | Tags |
|------|----------|----------|------|
| - | Permissions Docker volumes | `chmod -R 777` temporaire, puis ajuster | #docker #permissions |
| - | Conflits jQuery/Gutenberg | Enqueue scripts avec deps correctes | #wordpress #js |
| - | White screen après plugin update | Désactiver via wp-cli dans container | #wordpress #debug |

### Bonnes Pratiques
- Toujours `wp_nonce` pour les forms custom
- `WP_Query` avec `no_found_rows => true` si pas de pagination
- Préférer `get_template_part()` aux includes directs

## Laravel

### Erreurs Fréquentes
| Date | Problème | Solution | Tags |
|------|----------|----------|------|
| - | Migration rollback impossible | Toujours tester rollback en local | #laravel #migration |
| - | N+1 queries | Eager loading avec `with()` | #laravel #performance |
| - | Cache .env changes | `php artisan config:clear` | #laravel #config |

### Patterns Qui Marchent
- Repository pattern pour tests unitaires
- Form Requests pour validation
- Jobs pour tâches lourdes
- Resources pour API responses

## Python / FastAPI

### Setup Rapide
```python
# Structure minimale qui marche
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "ok"}

# uvicorn main:app --reload
```

### Pièges Connus
- Pydantic v1 vs v2 incompatibilités
- Async def vs def : choisir selon le besoin
- CORS : configure dès le début pour éviter surprises

## Docker

### Commandes Utiles
```bash
# Nettoyer tout
docker system prune -a

# Logs en temps réel
docker-compose logs -f [service]

# Exec dans container WordPress
docker-compose exec wordpress bash
```

## Git

### Workflow Qui Marche
1. Branch par feature
2. Commits atomiques
3. Rebase interactif avant merge
4. Tags pour les déploiements

## Conventions CTO (À Respecter)

### PHP (PSR-12)
- Namespace obligatoire
- Type hints partout
- Pas de `else` après `return`

### CSS
- BEM strict: `.block__element--modifier`
- Variables CSS pour couleurs
- Mobile-first

### Git
- Conventional commits: `type(scope): message`
- Branches: `feature/`, `fix/`, `hotfix/`
- Pas de commit direct sur main

## Optimisations Performance

### WordPress
- Object cache (Redis)
- Lazy load images
- Minify CSS/JS en production
- CDN pour assets

### Laravel
- Queue pour emails
- Cache routes en production
- Horizon pour monitoring queues
- Telescope seulement en local

## Raccourcis Productivité
- WordPress: TablePress pour tables complexes
- Laravel: `php artisan make:model -mfsc` (tout d'un coup)
- Docker: aliases bash pour commandes fréquentes
- VS Code: snippets pour boilerplate

---
*Document vivant - Mis à jour à chaque session*