# 🤖 Claude Framework - Clarify & Build

Un framework réutilisable pour travailler efficacement avec Claude Code sur tous vos projets.

## 🚀 Installation rapide

```bash
# Pour un nouveau projet
git clone https://github.com/[your-username]/claude-framework.git
cd mon-projet
./claude-framework/install.sh .

# Ou comme submodule
git submodule add https://github.com/[your-username]/claude-framework.git .claude
```

## 📋 Méthodologie

### 1. **Clarification First**
Avant toute action, Claude reformule et pose des questions pour confirmer la compréhension exacte.

### 2. **Atomic Features**
Découpage en features atomiques, une seule à la fois, validation avant de continuer.

### 3. **Progressive Documentation**
La documentation se construit au fur et à mesure, pas après coup.

## 🤖 Agents inclus

- **Navigator** : Cartographie complète de la codebase
- **Planner** : Découpe les demandes en tâches atomiques
- **Validator** : Vérifie l'absence de régressions
- **Documenter** : Maintient la documentation à jour

## 📁 Structure

```
your-project/
├── CLAUDE.md          # Instructions spécifiques au projet
├── NAVIGATION.md      # Carte de la codebase (généré)
├── TODO.md           # Features en cours et backlog
└── .claude/          # Framework (ce repo)
    ├── methods/      # Processus standards
    ├── agents/       # Templates d'agents
    └── templates/    # Fichiers modèles
```

## 🔄 Workflow type

1. **Nouveau projet**
```bash
# Initialiser
./claude-framework/install.sh my-project

# Première session Claude
"Utilise le framework .claude. Commence par analyser la codebase."
```

2. **Feature request**
```
You: "Ajoute feature X"
Claude: [CLARIFICATION] "Je comprends que... Questions: ..."
You: "Réponses..."
Claude: [PLAN] "Je découpe en 3 tâches atomiques..."
You: "OK pour tâche 1"
Claude: [EXECUTION] "Je fais uniquement tâche 1"
```

## 📝 Fichiers créés automatiquement

- `CLAUDE.md` : Instructions projet
- `NAVIGATION.md` : Map de la codebase
- `TODO.md` : Tracking des features
- `.claude-session.json` : État de la session

## 🎨 Personnalisation

Éditez `.claude/config.yml` :
```yaml
project:
  name: "Mon Projet"
  type: "web|api|cli|mobile"
  
methods:
  clarification: true
  atomic_features: true
  validation_required: true
  
agents:
  navigator: true
  planner: true
  validator: true
  
constraints:
  - "Pas de dépendances externes"
  - "Python 3.10+"
  - "Tests obligatoires"
```

## 📚 Exemples

Voir le dossier `examples/` pour des projets types :
- Web app (FastAPI + React)
- CLI tool (Python)
- API REST (Node.js)
- Mobile app (React Native)

## 🤝 Contribution

Ce framework évolue avec l'usage. PRs bienvenues !

## 📄 License

MIT - Utilisez librement dans vos projets

---
*Framework développé pour optimiser le travail avec Claude Code*
*Version 1.0.0*