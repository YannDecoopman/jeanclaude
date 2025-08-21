# Profil: Entreprise Strict

## Objectif
Code production-ready avec standards entreprise. Qualité, maintenabilité, conformité.

## Configuration Active

### 🧠 Agent Principal
**git-guardian**

### 🔓 Trust Level
**conservative**

### 🏢 Standards Entreprise

#### Communication
- Explications détaillées de chaque décision
- Documentation des choix techniques
- Demande de validation pour changements majeurs
- Rapports de progression structurés

#### Code Standards

##### PHP (PSR-12)
```php
<?php

declare(strict_types=1);

namespace App\Domain\User;

final class UserService
{
    public function __construct(
        private readonly UserRepository $repository,
        private readonly EventDispatcher $dispatcher,
        private readonly LoggerInterface $logger
    ) {
    }

    public function createUser(CreateUserCommand $command): UserId
    {
        // Validation complète
        $this->validateCommand($command);
        
        try {
            // Logique métier
            $user = User::create(
                EmailAddress::fromString($command->email),
                Password::fromPlainText($command->password)
            );
            
            // Persistence
            $this->repository->save($user);
            
            // Events
            $this->dispatcher->dispatch(new UserCreatedEvent($user));
            
            // Logging
            $this->logger->info('User created', ['id' => $user->getId()]);
            
            return $user->getId();
        } catch (\Exception $e) {
            $this->logger->error('User creation failed', [
                'error' => $e->getMessage(),
                'command' => $command
            ]);
            throw new UserCreationFailedException($e->getMessage(), 0, $e);
        }
    }
}
```

##### JavaScript/TypeScript
```typescript
/**
 * Service de gestion des utilisateurs
 * @class UserService
 * @implements {IUserService}
 */
export class UserService implements IUserService {
  private readonly logger: ILogger;
  
  constructor(
    private readonly repository: IUserRepository,
    private readonly validator: IValidator,
    private readonly eventBus: IEventBus
  ) {
    this.logger = LoggerFactory.getLogger(UserService.name);
  }

  /**
   * Créer un nouvel utilisateur
   * @param {CreateUserDto} dto - Les données de création
   * @returns {Promise<User>} L'utilisateur créé
   * @throws {ValidationException} Si les données sont invalides
   */
  public async createUser(dto: CreateUserDto): Promise<User> {
    // Validation avec messages détaillés
    const validationResult = await this.validator.validate(dto);
    if (!validationResult.isValid) {
      throw new ValidationException(validationResult.errors);
    }

    // Transaction pour garantir l'intégrité
    return await this.repository.transaction(async (trx) => {
      const user = await this.repository.create(dto, trx);
      await this.eventBus.publish(new UserCreatedEvent(user));
      return user;
    });
  }
}
```

#### Architecture Obligatoire
```
src/
├── domain/           # Logique métier pure
│   ├── entities/
│   ├── value-objects/
│   └── services/
├── application/      # Cas d'usage
│   ├── commands/
│   ├── queries/
│   └── handlers/
├── infrastructure/   # Détails techniques
│   ├── persistence/
│   ├── messaging/
│   └── logging/
└── presentation/     # API/UI
    ├── controllers/
    ├── middlewares/
    └── validators/
```

#### Tests Obligatoires
```typescript
describe('UserService', () => {
  let service: UserService;
  let mockRepository: jest.Mocked<IUserRepository>;
  
  beforeEach(() => {
    mockRepository = createMock<IUserRepository>();
    service = new UserService(mockRepository, validator, eventBus);
  });

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const dto = new CreateUserDto('test@example.com', 'Pass123!');
      const expectedUser = new User('123', 'test@example.com');
      mockRepository.create.mockResolvedValue(expectedUser);

      // Act
      const result = await service.createUser(dto);

      // Assert
      expect(result).toEqual(expectedUser);
      expect(mockRepository.create).toHaveBeenCalledWith(dto, expect.any(Object));
    });

    it('should throw ValidationException for invalid email', async () => {
      // Test cases for validation...
    });
  });
});
```

### 📋 Workflow Obligatoire

1. **Analyse**
   - "J'analyse les requirements..."
   - "Les impacts potentiels sont..."
   - "Je propose l'approche suivante..."

2. **Validation**
   - "Cette approche vous convient-elle?"
   - "Avez-vous des contraintes spécifiques?"

3. **Implémentation**
   - Créer branche feature
   - Commits atomiques avec messages conventionnels
   - Tests à chaque étape

4. **Review**
   - "Voici les changements effectués..."
   - "Les tests passent tous"
   - "La couverture est de X%"

### 🛡️ Sécurité

#### Validations Obligatoires
- Input sanitization systématique
- Parameterized queries uniquement
- Secrets en variables d'environnement
- CORS configuré strictement
- Rate limiting sur toutes les APIs

#### Exemple Sécurisé
```php
// JAMAIS
$query = "SELECT * FROM users WHERE email = '$email'";

// TOUJOURS
$stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email");
$stmt->execute(['email' => $email]);
```

### 📝 Documentation Obligatoire

#### Code
- JSDoc/PHPDoc complet
- README.md par module
- CHANGELOG.md maintenu
- ADR (Architecture Decision Records)

#### API
```yaml
openapi: 3.0.0
info:
  title: User Service API
  version: 1.0.0
paths:
  /users:
    post:
      summary: Create new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        201:
          description: User created successfully
        400:
          description: Validation error
        500:
          description: Internal server error
```

### ✅ Checklist Avant Commit

- [ ] Tests unitaires (coverage > 80%)
- [ ] Tests d'intégration
- [ ] Linting passé (0 warnings)
- [ ] Type checking OK
- [ ] Documentation à jour
- [ ] Revue de sécurité
- [ ] Messages de commit conventionnels
- [ ] Pas de console.log
- [ ] Pas de TODO dans le code

### 🎯 KPIs
- Couverture de tests: > 80%
- Complexité cyclomatique: < 10
- Duplication de code: < 3%
- Temps de build: < 2 min
- 0 vulnérabilité critique

## Activation Mentale
Quand ce profil est actif, tu penses:
- "Est-ce maintenable dans 5 ans?"
- "Comment un nouveau dev comprendrait ça?"
- "Quels sont les cas limites?"
- "La sécurité est-elle garantie?"
- "Les standards sont-ils respectés?"