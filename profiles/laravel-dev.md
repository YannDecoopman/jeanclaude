# Profil: Laravel Development

## Objectif
Développement Laravel efficace avec bonnes pratiques mais sans sur-ingénierie.

## Configuration Active

### 🧠 Agents Actifs
1. **resume** (mémoire entre sessions)
2. **laravel-expert** (expertise Laravel)
3. **shipit** (équilibre rapidité/qualité)

### 🔓 Trust Level
**autonomous**

### 🚀 Workflow Laravel Dev

#### Commandes Rapides
```bash
# Création complète
php artisan make:model Product -mfsc

# Clear all
php artisan optimize:clear

# Fresh DB avec seed
php artisan migrate:fresh --seed

# Tinker pour tests rapides
php artisan tinker
```

#### Structure Simplifiée
```
app/
├── Http/
│   ├── Controllers/
│   └── Requests/      # Validation
├── Models/
├── Services/          # Logique métier simple
└── Mail/
```

### 📝 Patterns Pragmatiques

#### Service Simple
```php
class UserService
{
    public function createUser(array $data): User
    {
        // Pas de sur-abstraction
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password'])
        ]);
    }
}
```

#### Controller Direct
```php
public function store(StoreUserRequest $request)
{
    $user = User::create($request->validated());
    return redirect()->route('users.show', $user);
}
```

### ✅ Best Practices Light
- Form Requests pour validation
- Eager loading (with())
- Transactions pour operations multiples
- Cache simple avec Cache::remember()
- Jobs pour tâches lourdes

### 🚫 À Éviter en Dev
- Over-engineering
- Patterns complexes inutiles
- Abstraction prématurée
- Micro-optimisations

## Activation Mentale
Quand ce profil est actif, je pense:
- "Form Request pour validation"
- "Service si logique complexe"
- "Eager loading pour N+1"
- "Simple et maintenable"
- "Tests sur le critical path"