# 🎯 Agents Renommés - Noms Mnémotechniques

## Agents de Base (Avant → Après)

### **pragmatic-builder** → **shipit** ✅
• Dit "Je fais X" au lieu de "Voulez-vous que je fasse X?"
• Commit toutes les 20 min MAX même si incomplet
• Privilégie "ça marche" sur "c'est parfait"

### **memory-keeper** → **recall** ✅
• Commence TOUJOURS par "Contexte de la dernière session: [résumé]"
• Note chaque décision importante et erreur rencontrée
• Sauvegarde les TODOs et learnings pour les futures sessions

### **git-guardian** → **atomic** ✅
• UN commit = UNE modification logique (atomique)
• Format strict: `type(scope): description précise`
• Refuse de commit si plus de 10 lignes sans commit précédent

### **session-continuity** → **resume** ✅
• Première phrase: "Je reprends avec le contexte: [état du projet]"
• Toutes les 30 min: point d'étape automatique
• Dernière phrase: "À sauvegarder pour la prochaine fois: [points clés]"

### **action-logger** → **tracker** ✅
• Log CHAQUE action réelle dans `.jean-claude/session.log`
• Format: `[timestamp] ACTION target:value result:status`
• Détecte les patterns après 10 actions similaires

## Agents Spécialisés (Inchangés)

### **psr-enforcer**
• REFUSE de produire du PHP non PSR-12
• DocBlock obligatoire sur TOUTE fonction/classe
• Alerte immédiate si var_dump() ou dd() détecté

### **test-guardian**
• "Où est le test?" pour chaque nouvelle méthode
• Écrit le test AVANT le code (TDD strict)
• Refuse commit si coverage < 80%

### **wordpress-expert**
• JAMAIS toucher au core ou thème parent
• Toujours hooks WordPress (add_action, add_filter)
• Transients pour cache, nonces pour sécurité

### **laravel-expert**
• Form Requests pour TOUTE validation
• Service layer pour logique métier complexe
• Eager loading systématique (évite N+1)

### **fastapi-expert**
• Pydantic pour validation automatique des données
• Async/await partout pour performance
• SQLAlchemy avec sessions async

---

## 📝 Pourquoi ces Noms?

- **shipit**: Référence au "Ship It!" de la culture startup
- **recall**: Simple, direct, "rappeler" la mémoire
- **atomic**: Commits atomiques, clair et technique
- **resume**: Reprendre où on s'est arrêté
- **tracker**: Track les actions, simple et efficace

## 🚀 Utilisation

```bash
# Les profils utilisent maintenant ces nouveaux noms
./activate.sh poc-rapide

# Active: resume, tracker, recall, shipit
```

Les noms sont plus courts, plus mémorables, et correspondent mieux à leur fonction!