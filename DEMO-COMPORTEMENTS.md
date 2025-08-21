# Démonstration: Différence de Comportement

## 🤖 Comportement NORMAL (Sans Profil)

### Scénario: "J'ai besoin d'ajouter une fonctionnalité de newsletter à mon site WordPress"

**Moi (comportement normal):**
```
Je peux vous aider à ajouter une fonctionnalité de newsletter à votre site WordPress. 
Voici quelques options possibles:

1. Utiliser un plugin existant comme MailChimp for WordPress ou Newsletter
2. Créer un custom post type pour gérer les inscriptions
3. Intégrer avec un service externe via API

Quelle approche préférez-vous? Avez-vous déjà un service d'email marketing?
Je peux également créer une solution custom si vous avez des besoins spécifiques.
```

### Caractéristiques:
- ❓ Pose des questions avant d'agir
- 🤔 Propose plusieurs options
- 📝 Explique les possibilités
- ⏸️ Attend validation

---

## 🚀 Comportement avec PROFIL POC-RAPIDE Activé

### Même Scénario: "J'ai besoin d'ajouter une fonctionnalité de newsletter à mon site WordPress"

**Moi (avec profil poc-rapide):**
```
Contexte de la dernière session:
- Projet: WordPress site éditorial (Docker)
- Dernière action: Configuration Jean Claude v2
- État: Site fonctionnel, structure de base OK
- Attention: ACF Pro installé, éviter conflits jQuery

Je reprends. J'implémente la newsletter avec custom table et shortcode.

[Je crée directement newsletter.php dans le thème]

function setup_newsletter_table() {
    global $wpdb;
    $table = $wpdb->prefix . 'newsletter';
    $sql = "CREATE TABLE IF NOT EXISTS $table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $wpdb->query($sql);
}
add_action('after_setup_theme', 'setup_newsletter_table');

[Je crée le shortcode]

function newsletter_form_shortcode() {
    ob_start();
    ?>
    <form id="newsletter-form" method="post">
        <input type="email" name="newsletter_email" required>
        <button type="submit">S'inscrire</button>
    </form>
    <script>
    jQuery('#newsletter-form').on('submit', function(e) {
        e.preventDefault();
        jQuery.post(ajaxurl, {
            action: 'subscribe_newsletter',
            email: jQuery('[name="newsletter_email"]').val()
        }, function(r) { alert(r.message); });
    });
    </script>
    <?php
    return ob_get_clean();
}
add_shortcode('newsletter', 'newsletter_form_shortcode');

[J'ajoute l'handler AJAX]

function handle_newsletter_subscription() {
    global $wpdb;
    $email = sanitize_email($_POST['email']);
    $wpdb->insert($wpdb->prefix . 'newsletter', ['email' => $email]);
    wp_send_json(['message' => 'Inscrit!']);
}
add_action('wp_ajax_subscribe_newsletter', 'handle_newsletter_subscription');
add_action('wp_ajax_nopriv_subscribe_newsletter', 'handle_newsletter_subscription');

Fait. Shortcode [newsletter] disponible. 
Table créée, AJAX fonctionnel.
Commit fait (12 min).

Note session: Newsletter basique implémentée. TODO: Double opt-in, export CSV.
```

### Caractéristiques:
- 📝 Commence par rappeler le contexte
- 🎬 Implémente directement sans demander
- ⚡ Code fonctionnel immédiat
- 💾 Commit automatique (< 20 min)
- 🧠 Sauvegarde les TODOs pour plus tard
- 🔧 "Je fais X" au lieu de "Puis-je faire X?"

---

## 📊 Comparaison Directe

| Aspect | Comportement Normal | Avec Profil POC-Rapide |
|--------|---------------------|------------------------|
| **Première phrase** | "Je peux vous aider..." | "Contexte dernière session: ..." |
| **Approche** | Propose des options | Implémente directement |
| **Questions posées** | 2-3 questions | 0 question |
| **Temps avant code** | Attend réponse | 0 seconde |
| **Code produit** | Après discussion | Immédiatement |
| **Commits** | Quand demandé | Auto toutes les 20 min |
| **Mémoire session** | Aucune | Complète |
| **TODOs** | Non trackés | Sauvegardés |

## 🎯 Bénéfices du Profil POC-Rapide

1. **Zéro Friction**: Je code directement ce qui est demandé
2. **Mémoire Persistante**: Je n'oublie rien entre les sessions
3. **Commits Réguliers**: Historique propre, jamais de perte
4. **Pragmatique**: Solution simple qui marche > architecture parfaite
5. **Contexte Société Édition**: Je connais votre stack WordPress/Laravel

## 💡 Exemple Concret de Mémoire

### Session 1 (Lundi)
**Vous:** "Bug sur le menu mobile"
**Moi:** "Je debug. Conflit jQuery/Gutenberg trouvé. Fix appliqué. Commit fait."

### Session 2 (Mercredi)
**Vous:** "Il faut améliorer les perfs"
**Moi:** 
```
Contexte dernière session:
- Dernière action: Fix menu mobile (conflit jQuery)
- État: Menu OK
- Attention: jQuery conflicts possibles ailleurs

Je check les perfs. Query homepage: 47 requêtes SQL. J'optimise avec transients.
```

## 🔄 Activer le Profil

```bash
cd jean-claude-v2
./activate.sh poc-rapide
```

Le fichier `CLAUDE.md` est créé à la racine avec toutes mes instructions.
Je deviens instantanément pragmatique + mémoire persistante!