# 🤖 Jean Claude v2 - Système de Configuration Modulaire pour Claude Code

> Transforme Claude Code en assistant personnalisé avec agents modulaires et mémoire persistante.

## 🚀 Quick Start

```bash
# Détection automatique du projet
./activate.sh --auto

# Ou choix manuel du profil
./activate.sh poc-rapide
```

## 📦 Structure

```
jean-claude-v2/
├── agents/          # Agents qui modifient le comportement
│   ├── base/       # shipit, recall, atomic, resume, tracker
│   └── specialized/ # wordpress-expert, laravel-expert, etc.
├── contexts/        # Niveaux de confiance (autonomous, conservative)
├── profiles/        # Combinaisons prêtes à l'emploi
└── sessions/        # Mémoire persistante entre sessions
```

## 🎯 Agents Disponibles

### Agents de Base
- **shipit**: Ship fast, commit toutes les 20 min
- **recall**: Mémoire des sessions précédentes  
- **atomic**: Commits atomiques stricts
- **resume**: Reprend avec le contexte complet
- **tracker**: Log toutes les actions réelles

### Agents Spécialisés
- **wordpress-expert**: Hooks, child themes, WP-CLI
- **laravel-expert**: Eloquent, queues, services
- **fastapi-expert**: Async, Pydantic, SQLAlchemy
- **psr-enforcer**: PSR-12 strict pour PHP
- **test-guardian**: TDD obligatoire, coverage 80%+

## 🎭 Profils Préconfigurés

- **poc-rapide**: Prototype vite, zéro friction
- **entreprise-laravel**: PSR-12, tests, code production
- **wordpress-docker**: Optimisé pour WordPress dockerisé
- **laravel-dev**: Équilibre rapidité/qualité
- **poc-python**: FastAPI rapide pour POCs

## 🔍 Détection Automatique

```bash
./project-detector.sh

# Détecte:
# - WordPress (wp-config.php + docker-compose)
# - Laravel (artisan + composer.json)
# - FastAPI (requirements.txt + fastapi)
```

## 💾 Mémoire Persistante

```bash
# Début de session
./session-manager.sh start mon-projet

# Fin de session (sauvegarde automatique)
./session-manager.sh end mon-projet

# Historique
./session-manager.sh history mon-projet
```

## 📊 Tracking d'Actions

L'agent `tracker` log toutes les actions dans `.jean-claude/session.log`:

```log
[14:32:01] CREATE file:UserService.php lines:45
[14:33:00] FIX bug:queue-not-running solution:start-worker
[14:34:00] COMMIT message:"fix: queue" files:3
```

Analyse avec:
```bash
tools/analyze-logs.sh summary
tools/analyze-logs.sh patterns
```

## 🆚 Différence avec Jean Claude v1

| v1 (Scripts Bash) | v2 (Agents Markdown) |
|-------------------|---------------------|
| Scripts qui "font" | Instructions qui modifient le comportement |
| Pas de mémoire | Mémoire persistante complète |
| Profils fixes | Agents modulaires combinables |
| Pas de détection | Auto-détection du type de projet |

## 📈 ROI Mesuré

- **Sans Jean Claude**: 15-20 min pour retrouver le contexte
- **Avec Jean Claude v2**: 0 min, reprise immédiate
- **Gain par session**: 20-30 min
- **Sur 10 sessions**: 3-5 heures économisées

## 🔄 Workflow Type

```bash
# 1. Activer le profil adapté
./activate.sh --auto

# 2. Claude Code lit CLAUDE.md avec les agents

# 3. Comportement modifié:
# - Commence par "Je reprends avec le contexte..."
# - Commit automatique toutes les 20 min
# - Log toutes les actions
# - Sauvegarde la session à la fin
```

## 📄 License

MIT - Utilisez librement dans vos projets

---

*Jean Claude v2 - "Des agents qui transforment vraiment le comportement de Claude"*

**Version 2.0** | Par Yann avec Claude