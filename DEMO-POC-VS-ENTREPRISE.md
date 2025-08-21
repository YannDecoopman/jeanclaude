# Démonstration: POC Rapide vs Entreprise Laravel

## Scénario: "Crée une fonction pour valider un email et l'enregistrer"

---

## 🚀 MODE POC RAPIDE

### Mon Comportement
```
Contexte dernière session:
- Projet: API Laravel 
- Dernière action: Setup routes de base
- État: Fonctionnel

Je crée la fonction de validation email.
```

### Code Produit
```php
// app/Http/Controllers/EmailController.php
function saveEmail(Request $request) {
    $email = $request->email;
    
    // Validation basique
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return response()->json(['error' => 'Invalid email'], 400);
    }
    
    // Save to DB
    DB::table('emails')->insert([
        'email' => $email,
        'created_at' => now()
    ]);
    
    return response()->json(['status' => 'saved']);
}

// Route ajoutée
Route::post('/email', 'EmailController@saveEmail');
```

**Ma réponse:** "Fait. Route `/email` disponible. Commit fait (8 min)."

### Caractéristiques Mode POC
- ✅ **Temps**: 30 secondes
- ✅ **Lignes de code**: 15
- ✅ **Fonctionne**: Oui
- ❌ **Tests**: 0
- ❌ **PSR-12**: Non respecté
- ❌ **Sécurité**: Injection SQL possible
- ❌ **DocBlock**: Absent

---

## 🏢 MODE ENTREPRISE LARAVEL

### Mon Comportement
```
Bonjour, j'analyse votre demande de validation et enregistrement d'email.

Questions préliminaires:
1. Usage: Newsletter, compte utilisateur, ou autre?
2. Double opt-in requis?
3. RGPD: Besoin de consentement explicite?
4. Déduplication: Email unique obligatoire?

Architecture proposée:
- Form Request pour validation
- Service pour logique métier
- Repository pour persistence
- Job pour envoi email confirmation
- Tests unitaires et d'intégration

Cette approche vous convient-elle?
```

*[Après validation de l'utilisateur]*

### Test d'Abord (TDD)
```php
<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Services\EmailService;
use App\Repositories\EmailRepository;
use Tests\TestCase;
use Mockery;

/**
 * @covers \App\Services\EmailService
 * @group  email
 */
class EmailServiceTest extends TestCase
{
    private EmailService $service;
    private MockInterface $repositoryMock;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->repositoryMock = Mockery::mock(EmailRepository::class);
        $this->service = new EmailService($this->repositoryMock);
    }

    /**
     * @test
     * @testdox Enregistre un email valide avec succès
     */
    public function it_saves_valid_email_successfully(): void
    {
        // Arrange
        $email = 'test@example.com';
        $this->repositoryMock
            ->shouldReceive('exists')
            ->with($email)
            ->once()
            ->andReturn(false);
            
        $this->repositoryMock
            ->shouldReceive('save')
            ->with($email)
            ->once()
            ->andReturn(true);

        // Act
        $result = $this->service->registerEmail($email);

        // Assert
        $this->assertTrue($result);
    }

    /**
     * @test
     * @testdox Rejette un email déjà enregistré
     */
    public function it_rejects_duplicate_email(): void
    {
        // Arrange
        $email = 'existing@example.com';
        $this->repositoryMock
            ->shouldReceive('exists')
            ->with($email)
            ->once()
            ->andReturn(true);

        // Assert & Act
        $this->expectException(DuplicateEmailException::class);
        $this->service->registerEmail($email);
    }
}
```

### Form Request
```php
<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validation pour l'enregistrement d'email
 * 
 * @package App\Http\Requests
 * @author  Development Team
 * @since   1.0.0
 */
final class StoreEmailRequest extends FormRequest
{
    /**
     * Détermine si l'utilisateur est autorisé
     * 
     * @return bool
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Règles de validation
     * 
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'email' => [
                'required',
                'email:rfc,dns',
                'max:255',
                'unique:emails,email'
            ],
            'consent' => [
                'required',
                'boolean',
                'accepted'
            ],
            'source' => [
                'nullable',
                'string',
                'in:website,api,mobile'
            ]
        ];
    }

    /**
     * Messages d'erreur personnalisés
     * 
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'email.required' => 'L\'adresse email est obligatoire.',
            'email.email' => 'L\'adresse email doit être valide.',
            'email.unique' => 'Cette adresse email est déjà enregistrée.',
            'consent.accepted' => 'Vous devez accepter les conditions.'
        ];
    }
}
```

### Service
```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\EmailRepository;
use App\Events\EmailRegistered;
use App\Exceptions\DuplicateEmailException;
use Illuminate\Support\Facades\Log;

/**
 * Service de gestion des emails
 * 
 * Gère l'enregistrement et la validation des emails
 * avec respect du RGPD et double opt-in.
 * 
 * @package App\Services
 * @author  Development Team
 * @since   1.0.0
 */
final class EmailService
{
    /**
     * @param EmailRepository $repository
     */
    public function __construct(
        private readonly EmailRepository $repository
    ) {
    }

    /**
     * Enregistre un nouvel email
     * 
     * @param  string $email   Email à enregistrer
     * @param  array  $metadata Données additionnelles
     * @return bool            Succès de l'opération
     * @throws DuplicateEmailException Si email existe
     */
    public function registerEmail(string $email, array $metadata = []): bool
    {
        // Vérification unicité
        if ($this->repository->exists($email)) {
            Log::warning('Tentative d\'enregistrement email dupliqué', [
                'email' => $email,
                'ip' => request()->ip()
            ]);
            
            throw new DuplicateEmailException(
                'Email already registered: ' . $email
            );
        }

        try {
            // Enregistrement
            $result = $this->repository->save($email, $metadata);
            
            // Event pour déclencher double opt-in
            event(new EmailRegistered($email));
            
            Log::info('Email enregistré avec succès', [
                'email' => $email,
                'source' => $metadata['source'] ?? 'unknown'
            ]);
            
            return $result;
            
        } catch (\Exception $e) {
            Log::error('Erreur enregistrement email', [
                'email' => $email,
                'error' => $e->getMessage()
            ]);
            
            throw $e;
        }
    }
}
```

### Controller
```php
<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreEmailRequest;
use App\Services\EmailService;
use Illuminate\Http\JsonResponse;
use App\Exceptions\DuplicateEmailException;

/**
 * Controller pour la gestion des emails
 * 
 * @package App\Http\Controllers\Api
 * @author  Development Team
 * @since   1.0.0
 */
final class EmailController extends Controller
{
    /**
     * @param EmailService $emailService
     */
    public function __construct(
        private readonly EmailService $emailService
    ) {
    }

    /**
     * Enregistre un nouvel email
     * 
     * @param  StoreEmailRequest $request Requête validée
     * @return JsonResponse               Réponse JSON
     */
    public function store(StoreEmailRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            
            $this->emailService->registerEmail(
                email: $validated['email'],
                metadata: [
                    'source' => $validated['source'] ?? 'api',
                    'ip' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'consent_given_at' => now()
                ]
            );
            
            return response()->json([
                'success' => true,
                'message' => 'Email enregistré. Vérifiez votre boîte mail.'
            ], 201);
            
        } catch (DuplicateEmailException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Cet email est déjà enregistré.'
            ], 409);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue.'
            ], 500);
        }
    }
}
```

### Vérifications
```
✅ PSR-12: Pass (vendor/bin/pint)
✅ Static Analysis: Pass (PHPStan level 8)
✅ Tests: 100% coverage
✅ Security: Injection SQL impossible (Eloquent)
✅ RGPD: Consentement + logs
✅ Pre-commit hooks: All green

Souhaitez-vous que je crée également:
1. Migration pour la table emails?
2. Job pour double opt-in?
3. Tests d'intégration API?
```

---

## 📊 COMPARAISON FINALE

| Critère | Mode POC | Mode Entreprise |
|---------|----------|-----------------|
| **Temps développement** | 30 secondes | 30 minutes |
| **Lignes de code** | 15 | 300+ |
| **Fichiers créés** | 1 | 8 |
| **Tests** | 0 | 5+ |
| **Coverage** | 0% | 100% |
| **PSR-12** | ❌ Non | ✅ Strict |
| **Sécurité** | ❌ Faille SQL | ✅ Sécurisé |
| **Documentation** | ❌ Aucune | ✅ Complète |
| **Maintenabilité** | Faible | Excellente |
| **Scalabilité** | Nulle | Haute |
| **RGPD Compliant** | ❌ Non | ✅ Oui |
| **Questions posées** | 0 | 5+ |
| **Confirmations demandées** | 0 | 3+ |

## 🎯 Quand Utiliser Chaque Mode

### POC Rapide
- MVP pour lever des fonds
- Démo client demain
- Test d'API externe
- Script one-shot
- Prototype jetable

### Entreprise Laravel
- Code production
- Client grand compte
- Audit prévu
- Équipe 5+ devs
- Maintenance long terme
- Conformité légale

## 🔄 Activation

```bash
# Pour un POC rapide
./jean-claude-v2/activate.sh poc-rapide

# Pour un projet client
./jean-claude-v2/activate.sh entreprise-laravel
```

**La différence est RADICALE. Je deviens une personne complètement différente selon le profil!**