# Erreurs à Éviter - Base de Connaissances

## WordPress

### ❌ Permissions Docker
```bash
# JAMAIS
chmod 777 -R /var/www/html  # Trop permissif

# TOUJOURS
docker-compose exec wordpress chown www-data:www-data /var/www/html/wp-content/uploads
```

### ❌ Direct DB Queries
```php
// JAMAIS
$wpdb->query("DELETE FROM wp_posts WHERE ID = $id");  // SQL Injection!

// TOUJOURS
wp_delete_post($id, true);  // Utilise les hooks WordPress
```

### ❌ Update Plugins en Prod
```
JAMAIS update plugins directement en production
→ Toujours tester en staging d'abord
→ Backup DB avant tout update
```

### ❌ Conflits jQuery
```javascript
// JAMAIS
$(document).ready(function() { });  // Peut confliter avec Gutenberg

// TOUJOURS
jQuery(document).ready(function($) { });  // No conflict mode
```

## Laravel

### ❌ Mass Assignment
```php
// JAMAIS
User::create($request->all());  // Danger!

// TOUJOURS
User::create($request->validated());  // Après validation
```

### ❌ N+1 Queries
```php
// JAMAIS
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name;  // N+1 queries!
}

// TOUJOURS
$posts = Post::with('author')->get();  // Eager loading
```

### ❌ Env en Production
```php
// JAMAIS
$key = env('API_KEY');  // Null en production avec cache

// TOUJOURS
$key = config('services.api.key');  // Via config
```

### ❌ DD en Production
```php
// JAMAIS commiter
dd($variable);  // Tue l'app
dump($variable);  // Expose data
var_dump($data);  // Moche

// TOUJOURS
Log::debug('Debug info', ['data' => $data]);
```

## Git

### ❌ Force Push sur Main
```bash
# JAMAIS
git push --force origin main  # Détruit l'historique équipe

# Si vraiment nécessaire
git push --force-with-lease  # Plus sûr
```

### ❌ Commits Géants
```bash
# JAMAIS
git add .
git commit -m "big update"  # 500+ lignes changées

# TOUJOURS
git add -p  # Par chunks logiques
git commit -m "feat: specific change"
```

### ❌ Secrets dans le Code
```javascript
// JAMAIS
const API_KEY = 'sk_live_abc123';  // Exposé sur GitHub!

// TOUJOURS
const API_KEY = process.env.API_KEY;  // Via .env
```

## Docker

### ❌ Latest Tags
```dockerfile
# JAMAIS
FROM php:latest  # Peut casser à tout moment

# TOUJOURS
FROM php:8.2.10-fpm  # Version fixe
```

### ❌ Root User
```dockerfile
# JAMAIS
USER root  # Sécurité compromise

# TOUJOURS
USER node  # User non-privilégié
```

### ❌ Build Context Énorme
```bash
# JAMAIS
docker build .  # Avec node_modules, .git, etc.

# TOUJOURS
# Utiliser .dockerignore
node_modules
.git
*.log
```

## PHP/PSR-12

### ❌ Else après Return
```php
// JAMAIS
if ($condition) {
    return true;
} else {
    return false;
}

// TOUJOURS
if ($condition) {
    return true;
}
return false;
```

### ❌ Variables Globales
```php
// JAMAIS
global $config;
$_GLOBALS['data'] = $value;

// TOUJOURS
// Dependency injection
public function __construct(Config $config) {
    $this->config = $config;
}
```

## Tests

### ❌ Tests Dépendants
```php
// JAMAIS
public function testA() {
    $this->id = User::create()->id;  // Sauve état
}
public function testB() {
    User::find($this->id);  // Dépend de testA
}

// TOUJOURS
public function testB() {
    $user = User::factory()->create();  // Indépendant
    // Test...
}
```

### ❌ Pas de Cleanup
```php
// JAMAIS
public function testCreate() {
    User::create(['email' => 'test@test.com']);
    // Laisse en DB
}

// TOUJOURS
use RefreshDatabase;  // Laravel
// ou
protected function tearDown(): void {
    User::truncate();
    parent::tearDown();
}
```

## Performance

### ❌ Loops SQL
```php
// JAMAIS
foreach ($ids as $id) {
    DB::update("UPDATE users SET active = 1 WHERE id = $id");
}

// TOUJOURS
User::whereIn('id', $ids)->update(['active' => 1]);  // 1 query
```

### ❌ Cache Sans TTL
```php
// JAMAIS
Cache::forever('key', $value);  // Peut exploser la mémoire

// TOUJOURS
Cache::put('key', $value, now()->addHours(1));  // TTL défini
```

## Sécurité

### ❌ Hash Faible
```php
// JAMAIS
md5($password);  // Cassable
sha1($password);  // Cassable

// TOUJOURS
Hash::make($password);  // Bcrypt/Argon2
password_hash($password, PASSWORD_DEFAULT);
```

### ❌ CORS Trop Permissif
```php
// JAMAIS
'allowed_origins' => ['*'],  // Tout le monde

// TOUJOURS
'allowed_origins' => ['https://app.example.com'],  // Spécifique
```

## Erreurs Coûteuses Vécues

### 🔥 Truncate en Prod
```
Date: 2023-XX-XX
Erreur: TRUNCATE TABLE users exécuté en prod
Impact: 10k utilisateurs perdus
Leçon: TOUJOURS vérifier APP_ENV avant opération destructive
```

### 🔥 Migration Sans Rollback
```
Date: 2023-XX-XX
Erreur: Migration qui drop une colonne sans backup
Impact: Rollback impossible, data perdue
Leçon: Toujours tester down() en local
```

### 🔥 Git Force Push
```
Date: 2023-XX-XX
Erreur: git push --force sur main
Impact: 2 jours de travail équipe perdus
Leçon: Protection de branche + --force-with-lease
```

### 🔥 Env Exposé
```
Date: 2023-XX-XX
Erreur: .env commité sur GitHub public
Impact: API keys compromises, $3k de frais AWS
Leçon: .gitignore dès le début + rotation keys
```

---
*Document enrichi à chaque erreur pour ne jamais les répéter*