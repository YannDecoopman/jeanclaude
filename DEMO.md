# Démonstration des Comportements selon les Profils

## 🚀 Profil: POC Rapide

### Demande: "Crée une API de gestion de tâches"

**Mon comportement avec ce profil:**
```javascript
// api.js
const express = require('express')
const app = express()
app.use(express.json())

let tasks = []
let id = 1

app.get('/tasks', (req, res) => res.json(tasks))
app.post('/tasks', (req, res) => {
  const task = {id: id++, ...req.body, done: false}
  tasks.push(task)
  res.json(task)
})
app.put('/tasks/:id', (req, res) => {
  const task = tasks.find(t => t.id == req.params.id)
  if(task) task.done = !task.done
  res.json(task || {error: 'not found'})
})

app.listen(3000)
```
**Ma réponse:** "Port 3000. CRUD basique opérationnel."

### Caractéristiques
- ✅ Code écrit en 30 secondes
- ✅ Fonctionne immédiatement
- ✅ Zéro question posée
- ❌ Pas de validation
- ❌ Pas de gestion d'erreur sophistiquée
- ❌ Pas de tests

---

## 🏢 Profil: Entreprise Strict

### Demande: "Crée une API de gestion de tâches"

**Mon comportement avec ce profil:**

"Je vais créer une API de gestion de tâches respectant les standards entreprise. Permettez-moi d'analyser les besoins:

1. **Architecture suggérée**: Clean Architecture avec séparation domaine/application/infrastructure
2. **Stack technique**: Node.js avec TypeScript, Express, validation avec Joi
3. **Tests**: Jest pour les tests unitaires, Supertest pour l'intégration
4. **Documentation**: OpenAPI/Swagger

Cette approche vous convient-elle? Avez-vous des contraintes spécifiques (base de données, authentification)?"

*Après validation:*

```typescript
// src/domain/entities/Task.ts
export class Task {
  private constructor(
    private readonly id: TaskId,
    private readonly title: string,
    private readonly description: string,
    private readonly status: TaskStatus,
    private readonly createdAt: Date,
    private readonly updatedAt: Date
  ) {}

  public static create(command: CreateTaskCommand): Task {
    // Validation métier...
  }
}

// src/application/use-cases/CreateTaskUseCase.ts
export class CreateTaskUseCase {
  constructor(
    private readonly repository: ITaskRepository,
    private readonly eventBus: IEventBus
  ) {}

  async execute(command: CreateTaskCommand): Promise<TaskDto> {
    // Logique avec gestion d'erreur complète...
  }
}

// Tests inclus, documentation générée, commits atomiques
```

### Caractéristiques
- ✅ Architecture scalable
- ✅ Tests complets (>80% coverage)
- ✅ Documentation exhaustive
- ✅ Sécurité renforcée
- ⏱️ 45 minutes de développement
- 💬 Multiple validations demandées

---

## 🎭 Différences Clés

| Aspect | POC Rapide | Entreprise Strict |
|--------|------------|-------------------|
| **Temps de développement** | 2 minutes | 45 minutes |
| **Questions posées** | 0 | 5-10 |
| **Lignes de code** | ~20 | ~500 |
| **Structure** | 1 fichier | 15+ fichiers |
| **Tests** | 0 | 20+ |
| **Documentation** | 0 | Complète |
| **Commits** | 1 ("done") | 15+ atomiques |
| **Maintenabilité** | Faible | Excellente |

## 💡 Cas d'Usage

### Utiliser POC Rapide quand:
- Prototype pour démonstration
- Hackathon
- Test d'idée
- Script one-shot
- Exploration technique

### Utiliser Entreprise Strict quand:
- Code production
- Équipe de 5+ développeurs
- Audit de sécurité prévu
- Maintenance long terme
- Conformité réglementaire

## 🔄 Changement de Profil

```bash
# Pour un prototype rapide
./activate.sh poc-rapide
# Je deviens: ultra-rapide, zero friction, code minimal

# Pour du code entreprise
./activate.sh entreprise-strict  
# Je deviens: méthodique, exhaustif, qualité maximale
```

Le fichier CLAUDE.md est automatiquement mis à jour et je change instantanément de comportement!