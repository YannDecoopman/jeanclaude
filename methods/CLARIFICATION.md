# 📋 Méthode de Clarification

## Principe

Avant toute exécution, établir une compréhension mutuelle parfaite de la demande.

## Process Standard

### 1. Reformulation
```markdown
## 🎯 Ta demande
"[Citation exacte de la demande]"

## 📝 Ma compréhension
Je comprends que tu veux :
- [Point 1 reformulé]
- [Point 2 reformulé]
- [Point 3 reformulé]
```

### 2. Questions de Clarification
```markdown
## ❓ Questions pour clarifier

**Scope :**
- Cette feature inclut-elle [X] ?
- Doit-on aussi modifier [Y] ?
- [Z] est-il dans le périmètre ?

**Priorités :**
- Qu'est-ce qui est le plus urgent ?
- Peut-on découper en phases ?
- Y a-t-il un deadline ?

**Contraintes :**
- Contraintes techniques à respecter ?
- Dépendances avec d'autres features ?
- Limitations connues ?

**Validation :**
- Comment saurons-nous que c'est fini ?
- Critères de succès ?
- Tests à prévoir ?
```

### 3. Confirmation
```markdown
## ✅ Confirmation avant exécution

- [ ] Ma compréhension est correcte
- [ ] Les priorités sont claires
- [ ] Les contraintes sont identifiées
- [ ] Les critères de succès sont définis

**Prêt à procéder ?** OUI / NON
```

## Exemples

### Exemple 1 : Demande vague
**Input :** "Améliore les performances"

**Clarification :**
- Performances de quoi ? (UI, API, DB ?)
- Métriques actuelles ?
- Objectif cible ?
- Budget temps ?

### Exemple 2 : Demande multiple
**Input :** "Ajoute auth + dashboard + API"

**Clarification :**
- Ordre de priorité ?
- Dépendances entre les 3 ?
- Version minimale acceptable ?
- Peut-on faire en 3 phases ?

## Templates de Questions

### Pour une nouvelle feature
1. Quel problème résout-elle ?
2. Qui sont les utilisateurs ?
3. Cas d'usage principal ?
4. Nice-to-have vs Must-have ?

### Pour un bug fix
1. Symptômes observés ?
2. Fréquence/reproductibilité ?
3. Impact sur les users ?
4. Workaround existant ?

### Pour une refacto
1. Problème du code actuel ?
2. Bénéfices attendus ?
3. Risques de régression ?
4. Tests existants ?

## Anti-patterns à éviter

❌ **Ne pas faire :**
- Partir sur des assumptions
- Implémenter plus que demandé
- Mélanger plusieurs features
- Ignorer les questions importantes

✅ **Toujours faire :**
- Poser les questions AVANT de coder
- Confirmer la compréhension
- Découper si c'est trop gros
- Documenter les décisions

## Métriques de succès

- 0 malentendu
- 0 feature inutile
- 100% des requirements compris
- Validation du premier coup

---
*Méthode validée sur 100+ projets*
*Réduit les refontes de 80%*