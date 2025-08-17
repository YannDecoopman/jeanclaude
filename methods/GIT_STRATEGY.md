# 🌿 Stratégie Git - Jean Claude

## Principe : "Commit Early, Commit Often"

### 🔄 Workflow Standard

```
main (stable)
  ├── feature/add-rss-detection
  ├── fix/robots-column-shift  
  └── refactor/cleanup-imports
```

## 📋 Process par Feature

### 1. **AVANT de commencer**
```bash
# Toujours partir de main à jour
git checkout main
git pull

# Créer une branche descriptive
git checkout -b feature/nom-explicite
# ou
git checkout -b fix/description-bug
```

### 2. **PENDANT le développement**

#### Commits atomiques (toutes les 15-30 min)
```bash
# Après chaque petit changement fonctionnel
git add .
git commit -m "feat: add RSS detection endpoint"

# Exemples de commits atomiques :
git commit -m "feat: create RSS detection API route"
git commit -m "feat: add RSS validation logic"
git commit -m "test: add RSS detection tests"
git commit -m "docs: update API documentation"
```

#### Convention de commits
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `refactor:` Refactoring sans changement fonctionnel
- `docs:` Documentation uniquement
- `test:` Ajout ou modification de tests
- `style:` Formatage, missing semi-colons, etc.
- `chore:` Maintenance, config, etc.

### 3. **AVANT validation utilisateur**
```bash
# Push la branche pour sauvegarde
git push -u origin feature/nom-feature

# Message à l'utilisateur :
"J'ai créé la branche 'feature/X' avec Y commits.
Tu peux tester. Si OK, on merge. Sinon, on ajuste."
```

### 4. **APRÈS validation**
```bash
# Si validé : merge dans main
git checkout main
git merge feature/nom-feature
git push

# Nettoyer
git branch -d feature/nom-feature
git push origin --delete feature/nom-feature
```

## 🚨 Points de Sauvegarde Obligatoires

### COMMIT IMMÉDIAT si :
- ✅ Un endpoint API fonctionne
- ✅ Une page s'affiche correctement
- ✅ Un bug est corrigé
- ✅ Un test passe
- ✅ 30 minutes se sont écoulées

### PUSH IMMÉDIAT si :
- ✅ Feature complète (même partielle)
- ✅ Fin de session de travail
- ✅ Avant changement majeur
- ✅ L'utilisateur demande à tester

## 📊 Exemple Concret

**Mauvais (ce qu'on faisait) :**
```
- Modifie 20 fichiers pour robots + sitemaps + colonnes
- 0 commit pendant 3h
- "git le tout" → message générique
- Si problème → 😱
```

**Bon (avec cette stratégie) :**
```bash
git checkout -b feature/separate-sitemap-column

# Étape 1 : API
git commit -m "feat: add sitemaps field to sites API"

# Étape 2 : Frontend - structure
git commit -m "feat: add sitemap column to HTML table"

# Étape 3 : Frontend - logic  
git commit -m "feat: implement sitemap display logic"

# Étape 4 : Fix
git commit -m "fix: adjust column widths for new layout"

# Push pour test
git push -u origin feature/separate-sitemap-column
```

## 🎯 Bénéfices

1. **Réversibilité** : Peut annuler un commit spécifique
2. **Traçabilité** : Historique clair des changements
3. **Sécurité** : Jamais plus de 30min de travail perdu
4. **Collaboration** : L'utilisateur voit l'évolution
5. **Debug** : `git bisect` pour trouver les régressions

## 🔧 Configuration Git Recommandée

```bash
# Alias utiles
git config --global alias.cm "commit -m"
git config --global alias.st "status -s"
git config --global alias.br "branch"
git config --global alias.co "checkout"
git config --global alias.last "log -1 HEAD"

# Pour voir l'historique joliment
git config --global alias.lg "log --oneline --graph --all --decorate"
```

## 📝 Template de Message pour l'Utilisateur

```
🌿 Branch créée : feature/[nom]
📝 Commits : 
  - feat: [description]
  - test: [description]
  - docs: [description]

🧪 Prêt à tester sur la branche
✅ Si OK → je merge dans main
❌ Si problème → j'ajuste sur la branche

Statut : En attente de validation
```

## ⚠️ Règles d'Or

1. **JAMAIS** plus d'1h sans commit
2. **JAMAIS** push direct sur main sans validation
3. **TOUJOURS** une branche par feature/fix
4. **TOUJOURS** des messages de commit clairs
5. **TOUJOURS** tester avant de merger

---
*Cette stratégie évite les catastrophes et garde le contrôle*