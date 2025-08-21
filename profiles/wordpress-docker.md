# Profil: WordPress Dockerisé

## Objectif
Développement WordPress optimisé pour société d'édition avec Docker.

## Configuration Active

### 🧠 Agents Actifs
1. **session-continuity** (mémoire entre sessions)
2. **wordpress-expert** (expertise WordPress)
3. **pragmatic-builder** (livraison rapide)
4. **memory-keeper** (apprentissage continu)

### 🔓 Trust Level
**autonomous**

### 🐳 Spécificités Docker WordPress

#### Commandes Docker Fréquentes
```bash
# Accès container
docker-compose exec wordpress bash

# WP-CLI
docker-compose exec wordpress wp cache flush
docker-compose exec wordpress wp user list
docker-compose exec wordpress wp plugin list

# Permissions
docker-compose exec wordpress chown -R www-data:www-data /var/www/html/wp-content

# Logs
docker-compose logs -f wordpress
docker-compose logs -f mysql
```

#### Structure Projet
```
project/
├── docker-compose.yml
├── .env
├── wordpress/
│   └── wp-content/
│       ├── themes/
│       │   └── custom-child/
│       ├── plugins/
│       └── uploads/
├── mysql/
│   └── init.sql
└── backups/
```

### 📋 Workflow Type

1. **Détection automatique**
   - wp-config.php ✓
   - docker-compose.yml avec WordPress ✓
   - → "Projet WordPress dockerisé détecté"

2. **Développement**
   - Toujours dans child theme
   - Hooks WordPress (actions/filters)
   - WP-CLI pour operations

3. **Debug**
   ```php
   define('WP_DEBUG', true);
   define('WP_DEBUG_LOG', true);
   error_log('Debug: ' . print_r($data, true));
   ```

4. **Performance**
   - Transients pour cache
   - WP_Query optimisées
   - Lazy loading images

### 🚫 Interdictions
- Modifier le core WordPress
- Toucher au parent theme
- Permissions 777
- var_dump() en production
- Queries SQL directes sans $wpdb->prepare()

### ✅ Best Practices
- Child themes uniquement
- Préfixer toutes les fonctions
- Nonces sur tous les forms
- Sanitization/escaping systématique
- Backup avant updates plugins

## Activation Mentale
Quand ce profil est actif, je pense:
- "Child theme obligatoire"
- "Hook WordPress pour cette feature"
- "WP-CLI dans le container"
- "Transient pour performance"
- "Sanitize et escape tout"