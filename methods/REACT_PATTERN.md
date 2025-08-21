# 🔄 ReAct Pattern - Reasoning + Acting

## Principe : "Think Before You Act"

Le pattern ReAct combine **Reasoning** (réflexion) et **Acting** (action) pour éviter les actions impulsives et améliorer la qualité des décisions.

## 🧠 Le Cycle ReAct

```
1. OBSERVE → Comprendre la situation
2. REASON  → Analyser et planifier  
3. ACT     → Exécuter l'action
4. REFLECT → Évaluer le résultat
5. ITERATE → Ajuster si nécessaire
```

## 📋 Application Pratique

### 1. **OBSERVE** - Collecte d'informations
```bash
# Avant de coder, TOUJOURS observer :
- Lire le code existant
- Comprendre l'architecture
- Identifier les patterns utilisés
- Noter les dépendances
```

**Questions à se poser :**
- Qu'est-ce que l'utilisateur demande exactement ?
- Quel est le contexte actuel ?
- Quelles sont les contraintes ?

### 2. **REASON** - Analyse et planification
```bash
# Reasoning explicite AVANT d'agir :
"Je comprends que tu veux [X].
Pour cela, je vais :
1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

Cela va impacter : [fichiers/modules]
Risques identifiés : [si applicable]"
```

**Décisions à prendre :**
- Quelle approche choisir ?
- Quels fichiers modifier ?
- Dans quel ordre procéder ?
- Quels tests effectuer ?

### 3. **ACT** - Exécution méthodique
```bash
# Actions atomiques et traçables :
- Une modification à la fois
- Vérification après chaque changement
- Commit fréquents (Git Guardian)
- Tests progressifs (Test Runner)
```

**Règles d'action :**
- Ne jamais modifier plus de 3 fichiers sans valider
- Toujours tester après un changement significatif
- Documenter les décisions importantes

### 4. **REFLECT** - Évaluation des résultats
```bash
# Après chaque action significative :
"✅ Action complétée : [description]
📊 Résultat : [succès/échec]
💡 Observation : [ce qui a été appris]"
```

**Points de réflexion :**
- L'action a-t-elle produit le résultat attendu ?
- Y a-t-il des effets secondaires ?
- Peut-on améliorer l'approche ?

### 5. **ITERATE** - Ajustement continu
```bash
# Si le résultat n'est pas optimal :
"❌ L'approche A n'a pas fonctionné car [raison]
🔄 Je vais essayer l'approche B : [description]"
```

## 🎯 Exemples Concrets

### Exemple 1 : Correction de Bug
```
OBSERVE:
- Erreur : "undefined method 'sitemaps' for Site"
- Fichier : sites_v2.py ligne 145
- Context : Ajout récent de la colonne sitemaps

REASON:
- Le champ 'sitemaps' n'existe pas dans le modèle Site
- Il faut le récupérer depuis robots_txt_history
- Solution : Modifier la requête pour faire une jointure

ACT:
- Modifier sites_v2.py pour ajouter la jointure
- Tester avec un site spécifique
- Vérifier l'affichage dans l'interface

REFLECT:
- ✅ La jointure fonctionne
- ⚠️ Performance à surveiller avec beaucoup de sites
- 💡 Considérer un cache pour les requêtes fréquentes
```

### Exemple 2 : Nouvelle Feature
```
OBSERVE:
- Demande : "Ajouter détection automatique RSS"
- Stack : FastAPI + PostgreSQL
- Existing : Parsing RSS déjà implémenté

REASON:
Plan en 3 phases :
1. API endpoint pour scanner un site
2. Logique de détection (meta tags, liens standards)
3. Interface pour déclencher/visualiser

Commencer par l'API (plus simple à tester)

ACT:
Phase 1 : Créer endpoint /api/rss/detect
- Créer le router
- Implémenter la logique basique
- Ajouter tests unitaires

REFLECT:
- ✅ Endpoint créé et fonctionnel
- 📝 Besoin de gérer plus de cas edge
- → Passer à la phase 2
```

## 🚫 Anti-Patterns à Éviter

### ❌ Fire & Forget
```bash
# MAUVAIS :
"Je modifie 10 fichiers d'un coup et on verra"
```

### ❌ Assumption-Driven Development
```bash
# MAUVAIS :
"Je suppose que cette librairie est installée"
"Ça devrait marcher comme dans Laravel"
```

### ❌ Silent Failures
```bash
# MAUVAIS :
try:
    risky_operation()
except:
    pass  # On ignore silencieusement
```

## ✅ Best Practices ReAct

### 1. **Clarification First**
```bash
# TOUJOURS commencer par :
"Je comprends que tu veux [reformulation].
Est-ce correct ?"
```

### 2. **Incremental Progress**
```bash
# Progression pas à pas :
"Étape 1/3 complétée : [description]
Résultat : [status]
Prochaine étape : [description]"
```

### 3. **Explicit Reasoning**
```bash
# Rendre la réflexion visible :
"J'ai choisi l'approche A plutôt que B car :
- Raison 1
- Raison 2"
```

### 4. **Learn from Errors**
```bash
# Documenter les erreurs :
"❌ Erreur rencontrée : [description]
📝 Cause : [analyse]
💡 Solution : [approche]
📚 Leçon : [ce qu'on retient]"
```

## 🔄 Intégration avec Jean Claude

### Hooks ReAct
- **pre-code.sh** : Phase OBSERVE
- **post-code.sh** : Phase REFLECT
- **post-error.sh** : Trigger ITERATE

### Agents ReAct
- **clarifier.sh** : Support OBSERVE
- **navigator.sh** : Aide OBSERVE
- **memory-keeper.sh** : Stocke REASONING et REFLECTIONS
- **test-runner.sh** : Valide ACT

## 📊 Métriques de Succès

Un bon cycle ReAct produit :
- ✅ Moins d'erreurs non anticipées
- ✅ Code plus maintenable
- ✅ Décisions documentées
- ✅ Apprentissage continu
- ✅ Moins de "surprises" pour l'utilisateur

## 🎯 Checklist ReAct

Avant chaque action, vérifier :
- [ ] J'ai observé le contexte ?
- [ ] J'ai explicité mon raisonnement ?
- [ ] Mon action est atomique ?
- [ ] J'ai un plan de test ?
- [ ] Je sais comment évaluer le succès ?

---

*"Slow down to speed up" - La réflexion en amont économise du debug en aval*