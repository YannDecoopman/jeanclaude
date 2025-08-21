# Patterns Qui Marchent

## WordPress

### Performance
```php
// Transients pour cache de requêtes lourdes
$key = 'heavy_query_result';
if (false === ($result = get_transient($key))) {
    $result = $wpdb->get_results("SELECT ...");
    set_transient($key, $result, HOUR_IN_SECONDS);
}
```

### Sécurité
```php
// Toujours vérifier nonce dans les forms
if (!wp_verify_nonce($_POST['_wpnonce'], 'my_action')) {
    wp_die('Security check failed');
}
```

### Docker WordPress
```bash
# Permissions qui marchent
docker-compose exec wordpress chown -R www-data:www-data /var/www/html
```

## Laravel

### Repository Pattern
```php
// Interface pour tests
interface UserRepositoryInterface {
    public function find(int $id): ?User;
}

// Implementation
class UserRepository implements UserRepositoryInterface {
    public function find(int $id): ?User {
        return User::find($id);
    }
}

// Binding dans ServiceProvider
$this->app->bind(UserRepositoryInterface::class, UserRepository::class);
```

### Queues Robustes
```php
// Job avec retry et timeout
class ProcessPayment implements ShouldQueue
{
    public $tries = 3;
    public $timeout = 120;
    public $backoff = [10, 30, 60];
    
    public function handle() {
        // Logic avec transaction
        DB::transaction(function () {
            // Process
        });
    }
}
```

### Validation Réutilisable
```php
// Form Request partagé
abstract class ApiRequest extends FormRequest
{
    protected function failedValidation(Validator $validator) {
        throw new HttpResponseException(response()->json([
            'errors' => $validator->errors()
        ], 422));
    }
}
```

## Python/FastAPI

### Async Patterns
```python
# Connection pool réutilisable
from databases import Database

database = Database("postgresql://...")

@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()
```

### Dependency Injection
```python
from fastapi import Depends

async def get_db():
    async with database.transaction():
        yield database

@app.post("/items/")
async def create_item(item: Item, db = Depends(get_db)):
    # Use db
    pass
```

## Git

### Commits Atomiques
```bash
# Ajouter par chunks
git add -p

# Commit avec scope
git commit -m "feat(auth): add JWT validation"

# Squash avant merge
git rebase -i HEAD~3
```

### Branches Propres
```bash
# Update depuis main sans merge commit
git checkout feature-branch
git rebase main

# Clean history
git log --oneline --graph
```

## Docker

### Build Optimisé
```dockerfile
# Multi-stage pour size réduite
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "index.js"]
```

### Volumes Persistants
```yaml
# docker-compose.yml
volumes:
  db-data:
    driver: local
  
services:
  postgres:
    volumes:
      - db-data:/var/lib/postgresql/data
```

## Tests

### Mocks Efficaces
```php
// Laravel
$mock = $this->mock(Service::class);
$mock->shouldReceive('method')
     ->once()
     ->with($expectedArg)
     ->andReturn($expectedResult);
```

### Data Providers
```php
/**
 * @dataProvider validationCases
 */
public function testValidation($input, $expected) {
    $this->assertEquals($expected, validate($input));
}

public function validationCases() {
    return [
        ['valid@email.com', true],
        ['invalid', false],
    ];
}
```

## Performance

### Caching Strategies
```php
// Laravel - Cache aside pattern
$value = Cache::remember('key', 3600, function () {
    return expensive_operation();
});
```

### Query Optimization
```php
// Eager loading pour éviter N+1
$posts = Post::with(['author', 'comments.user'])->get();

// Chunk pour large datasets
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // Process
    }
});
```

## Sécurité

### Validation Stricte
```php
// Jamais trust user input
$email = filter_var($request->email, FILTER_VALIDATE_EMAIL);
if (!$email) {
    throw new ValidationException('Invalid email');
}
```

### SQL Injection Prevention
```php
// Toujours paramétré
$users = DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// Ou Eloquent
$user = User::where('email', $email)->first();
```

---
*Document enrichi à chaque session avec les patterns qui fonctionnent*