# 🤖 Jean Claude Framework v2.3 - ReAct, Learn, Communicate & Trust

Un framework intelligent pour maximiser l'efficacité de Claude Code avec agents autonomes, hooks, système de mémoire, contexte minimaliste, communication JSON optionnelle et gestion de confiance adaptative.

## 🚀 Installation rapide

```bash
# Clone et installation
git clone https://github.com/YannDecoopman/jeanclaude.git
cd mon-projet
./jeanclaude/install.sh .

# Ou comme submodule Git
git submodule add https://github.com/YannDecoopman/jeanclaude.git .jeanclaude-framework
./.jeanclaude-framework/install.sh .
```

## 🆕 Nouveautés v2.3

### 🤝 **Système de Confiance Adaptative**
Trois niveaux de confiance pour contrôler l'autonomie :

```bash
# Mode conservateur (toujours demander)
source .jeanclaude/lib/trust-manager.sh
set_trust_level "conservative"

# Mode smart (auto-procéder pour opérations sûres, 6s délai)
set_trust_level "smart" 6

# Mode autonome (auto-procéder sauf destructions)
set_trust_level "autonomous" 6
```

### ⏱️ **Auto-Proceed avec Délai Configurable**
```bash
# Opération avec auto-proceed
⏱️  Editing README.md in current task
   Auto-proceeding in 6 seconds (press Ctrl+C to cancel)...
   6... 5... 4... 3... 2... 1...
   ✅ Proceeding...
```

## 🆕 Nouveautés v2.2

### 📊 **Standardisation I/O Optionnelle**
Tous les agents supportent maintenant le flag `--json` pour une sortie structurée :

```bash
# Sortie texte (défaut)
./agents/navigator.sh discover
> 🧭 Discovering structure...
> Found 42 files in 3 directories

# Sortie JSON (pour chaînage d'agents)
./agents/navigator.sh discover --json
{
  "agent": "navigator",
  "status": "success",
  "data": {
    "files": 42,
    "directories": 3
  }
}
```

### 🔄 **Communication Inter-Agents**
```bash
# Chaînage d'agents avec JSON
NAV_OUTPUT=$(./agents/navigator.sh discover --json)
FILES=$(echo "$NAV_OUTPUT" | jq -r '.data.files')
./agents/test-runner.sh smoke --json | jq '.data.passed'
```

## 🆕 Nouveautés v2.1

### 🎯 **Système de Contexte Minimaliste**
Chaque agent ne reçoit QUE le contexte nécessaire :
- **Navigator** : Chemin projet + patterns fichiers (1KB)
- **Git Guardian** : État Git + historique commits (2KB)
- **Test Runner** : Framework + derniers résultats (5KB)
- **Clarifier** : Demande user + historique (3KB)
- **Memory Keeper** : Accès complet (exception)

### 📊 **Context Manager**
```bash
# Contexte à 3 niveaux
.jeanclaude/context/
├── minimal.json     # Strict minimum (< 500 bytes)
├── shared.json      # Partagé entre agents (< 1KB)
└── agents/          # Spécifique par agent
    ├── navigator.json
    └── git-guardian.json
```

## 🏗️ Architecture v2.3

### 🤝 **Trust Manager**
- **trust-manager.sh** - Gestion des niveaux de confiance
- **AUTONOMY.md** - Documentation du système de confiance  
- **config/trust.json** - Configuration persistante

## 🏗️ Architecture v2.1

### 🤖 **Agents Autonomes**
- **navigator.sh** - Découverte et cartographie du code
- **clarifier.sh** - Reformulation et validation des demandes
- **git-guardian.sh** - Commits automatiques toutes les 30 min
- **test-runner.sh** - Tests progressifs (smoke → unit → integration)
- **memory-keeper.sh** - Gestion mémoire court/long terme

### 🪝 **Hooks de Workflow**
- **pre-code.sh** - Avant d'écrire (clarification, navigation)
- **post-code.sh** - Après écriture (tests, sauvegarde)
- **pre-commit.sh** - Validation avant commit (secrets, lint)
- **post-error.sh** - Gestion des erreurs (logging, analyse)
- **session-end.sh** - Fin de session (analyse, backup)

### 📋 **Méthodes Documentées**
- **REACT_PATTERN.md** - Cycle Observe→Reason→Act→Reflect
- **CLARIFICATION.md** - Process de clarification systématique
- **GIT_STRATEGY.md** - Commits atomiques et branches feature

### 🧠 **Système de Mémoire**
```
.jeanclaude/
├── memory/
│   ├── session/    # Mémoire court terme (session courante)
│   └── project/    # Mémoire long terme (patterns, pitfalls)
├── logs/           # Observabilité structurée
└── backups/        # Sauvegardes automatiques
```

## 📁 Structure après installation

```
your-project/
├── CLAUDE.md                    # Instructions spécifiques au projet
├── .jeanclaude/                 # Framework installé
│   ├── agents/                  # 5 agents autonomes (v2.3 avec trust)
│   ├── hooks/                   # 5 hooks de workflow
│   ├── lib/                     # Bibliothèques partagées
│   │   ├── context-manager.sh  # Gestion contexte minimal
│   │   ├── output-formatter.sh # Support JSON optionnel
│   │   └── trust-manager.sh    # Gestion confiance v2.3
│   ├── methods/                 # Méthodologies ReAct
│   │   ├── REACT_PATTERN.md
│   │   ├── CLARIFICATION.md
│   │   └── AUTONOMY.md         # NEW: Trust system
│   ├── config/
│   │   ├── config.json         # Configuration générale
│   │   └── trust.json          # Configuration confiance
│   ├── memory/                  # Système de mémoire
│   │   ├── session/            # Session courante
│   │   └── project/            # Apprentissages long terme
│   └── logs/                   # Logs structurés
│       └── trust-decisions.log # Décisions de confiance
```

## 🔄 Workflow ReAct

### 1. **OBSERVE** - Comprendre
```bash
# L'agent navigator découvre la structure
.jeanclaude/agents/navigator.sh discover
```

### 2. **REASON** - Planifier
```bash
# L'agent clarifier reformule et valide
.jeanclaude/agents/clarifier.sh "Add RSS detection feature"
```

### 3. **ACT** - Exécuter
```bash
# Git guardian crée une branche
.jeanclaude/agents/git-guardian.sh branch feature/rss-detection

# Code implementation...

# Tests progressifs
.jeanclaude/agents/test-runner.sh smoke
```

### 4. **REFLECT** - Évaluer
```bash
# Memory keeper sauvegarde les apprentissages
.jeanclaude/agents/memory-keeper.sh learn

# Session analysis
.jeanclaude/agents/memory-keeper.sh analyze
```

## 💡 Utilisation avec Claude

### Première session
```
"Utilise le framework Jean Claude installé dans .jeanclaude/
Commence par analyser le projet avec l'agent navigator."
```

### Feature development
```
You: "Ajoute la détection automatique des flux RSS"

Claude: [CLARIFIER] "Je comprends que tu veux détecter automatiquement 
les flux RSS des sites. Cela implique :
1. Scanner les balises <link> dans le HTML
2. Vérifier les URLs standards (/rss, /feed)
3. Valider les flux trouvés
C'est correct ?"

You: "Oui, go"

Claude: [GIT-GUARDIAN] Création branche feature/rss-detection
Claude: [NAVIGATOR] Analyse de la structure existante...
Claude: [ACT] Implémentation phase 1...
Claude: [TEST-RUNNER] Tests smoke passés ✅
Claude: [MEMORY-KEEPER] Pattern sauvegardé pour réutilisation
```

## 🎯 Fonctionnalités Clés

### Auto-commit intelligent
```bash
# Le Git Guardian commit automatiquement après 30 min
# ou après 10 fichiers modifiés
.jeanclaude/agents/git-guardian.sh auto
```

### Tests progressifs
```bash
# Smoke tests (rapides)
.jeanclaude/agents/test-runner.sh smoke

# Tests complets avec coverage
.jeanclaude/agents/test-runner.sh full
```

### Mémoire persistante
```bash
# Rappeler le contexte d'une session précédente
.jeanclaude/agents/memory-keeper.sh recall "rss"

# Analyser les patterns de succès/échec
.jeanclaude/agents/memory-keeper.sh analyze
```

## 📊 Observabilité

Les logs structurés permettent de suivre :
- Décisions prises (`.jeanclaude/memory/session/decisions.log`)
- Erreurs rencontrées (`.jeanclaude/memory/session/errors.log`)
- Actions des agents (`.jeanclaude/logs/agents.log`)

## 🛠️ Configuration

### Configuration générale `.jeanclaude/config.json` :
```json
{
  "version": "2.3",
  "features": {
    "agents": true,
    "hooks": true,
    "memory": true,
    "react_pattern": true,
    "trust_system": true,
    "json_output": true
  },
  "settings": {
    "auto_commit_interval": 1800,
    "memory_retention_days": 7,
    "log_level": "info"
  }
}
```

### Configuration confiance `.jeanclaude/config/trust.json` :
```json
{
  "trust_level": "smart",
  "auto_delay": 6,
  "operations": {
    "safe": ["read", "analyze", "test"],
    "moderate": ["edit", "commit", "install"],
    "dangerous": ["delete", "deploy", "force"]
  }
}
```

## 📚 Templates inclus

- **agent.template.sh** - Créer vos propres agents
- **feature-plan.template.md** - Planifier une feature complète
- **test-suite.template.py** - Structure de tests progressive

## 🚀 Commandes utiles

```bash
# Status complet du projet
.jeanclaude/agents/git-guardian.sh status

# Navigation rapide
.jeanclaude/agents/navigator.sh map

# Fin de session propre
.jeanclaude/hooks/session-end.sh
```

## 🤝 Contribution

Le framework évolue avec l'usage. PRs bienvenues sur :
https://github.com/YannDecoopman/jeanclaude

## 🔜 Fonctionnalités Trust System v2.3

### Configuration interactive
```bash
# Configurer le niveau de confiance
source .jeanclaude/lib/trust-manager.sh
configure_trust

# Vérifier le niveau actuel
describe_trust_level
```

### Exemples d'utilisation
```bash
# Mode smart (défaut) : auto-proceed pour tâches courantes
./agents/test-runner.sh smoke
# ⏱️ Auto-proceed après 6 secondes...

# Opération dangereuse : toujours demander
rm -rf old_backup/
# ⚠️ Confirmation requise, même en mode autonome
```

## 📈 Roadmap v3

- [ ] Intégration avec GitHub Actions
- [ ] Dashboard web pour visualiser la mémoire
- [ ] Agents spécialisés (security, performance)
- [ ] Export des patterns en best practices

## 📄 License

MIT - Utilisez librement dans vos projets

---

*Jean Claude Framework - "Think before you code"*

*Développé par Yann avec Claude pour optimiser le pair programming IA*

**Version 2.3** | [Documentation](https://github.com/YannDecoopman/jeanclaude) | [Issues](https://github.com/YannDecoopman/jeanclaude/issues)