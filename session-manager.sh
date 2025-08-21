#!/bin/bash

# Jean Claude v2 - Session Manager
# Gère la continuité entre les sessions

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSIONS_DIR="$BASE_DIR/sessions"
HISTORY_DIR="$SESSIONS_DIR/history"
CURRENT_FILE="$SESSIONS_DIR/current-session.md"
PROJECT_NAME="${2:-default}"
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H-%M")
DATETIME="$DATE-$TIME"

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function show_help() {
    echo "📚 Jean Claude Session Manager"
    echo ""
    echo "Usage: ./session-manager.sh [command] [project-name]"
    echo ""
    echo "Commands:"
    echo "  start [project]  - Démarre une nouvelle session"
    echo "  end [project]    - Termine et sauvegarde la session"
    echo "  status           - Affiche l'état de la session actuelle"
    echo "  history [project]- Affiche l'historique du projet"
    echo "  learn            - Affiche les apprentissages"
    echo ""
    echo "Examples:"
    echo "  ./session-manager.sh start wordpress-client"
    echo "  ./session-manager.sh end wordpress-client"
}

function start_session() {
    echo -e "${BLUE}🚀 Démarrage session: $PROJECT_NAME${NC}"
    echo ""
    
    # Chercher la dernière session du projet
    LAST_SESSION=$(ls -t "$HISTORY_DIR" 2>/dev/null | grep "$PROJECT_NAME" | head -1)
    
    # Créer le contexte de démarrage
    cat > "$CURRENT_FILE" << EOF
# Session Active: $PROJECT_NAME
**Démarrée**: $DATE à $(date +"%H:%M")

## Contexte de Session

### Projet
- **Nom**: $PROJECT_NAME
- **Type**: $(detect_project_type)
- **Stack**: $(detect_stack)
- **Environnement**: $(detect_environment)

EOF

    if [ -n "$LAST_SESSION" ]; then
        echo -e "${GREEN}✅ Session précédente trouvée: $LAST_SESSION${NC}"
        
        # Extraire les infos de la dernière session
        LAST_FILE="$HISTORY_DIR/$LAST_SESSION"
        
        # Ajouter le contexte de la dernière session
        cat >> "$CURRENT_FILE" << EOF
### Reprise de Session
**Dernière session**: $(echo $LAST_SESSION | cut -d'-' -f1-3)

#### État Précédent
$(grep -A 5 "## État Final du Projet" "$LAST_FILE" 2>/dev/null || echo "- État non documenté")

#### Derniers TODOs
$(grep -A 3 "## Pour la Prochaine Session" "$LAST_FILE" 2>/dev/null || echo "- Aucun TODO")

#### Décisions Importantes
$(grep -A 5 "## Décisions Prises" "$LAST_FILE" 2>/dev/null || echo "- Aucune décision majeure")

EOF
    else
        echo -e "${YELLOW}⚠️  Première session pour ce projet${NC}"
        cat >> "$CURRENT_FILE" << EOF
### Nouvelle Session
C'est la première session documentée pour ce projet.

EOF
    fi

    # Ajouter les patterns et erreurs à éviter
    cat >> "$CURRENT_FILE" << EOF
## Rappels Importants

### Patterns Qui Marchent
$(head -20 "$SESSIONS_DIR/learnings/patterns.md" 2>/dev/null || echo "Voir patterns.md")

### Erreurs à Éviter
$(grep "^### ❌" "$SESSIONS_DIR/learnings/avoid.md" 2>/dev/null | head -5 || echo "Voir avoid.md")

## Git Status
\`\`\`
$(cd "$(dirname "$BASE_DIR")" && git status --short 2>/dev/null || echo "Pas un repo git")
\`\`\`

## Branches
- Actuelle: $(cd "$(dirname "$BASE_DIR")" && git branch --show-current 2>/dev/null || echo "N/A")
- Derniers commits:
\`\`\`
$(cd "$(dirname "$BASE_DIR")" && git log --oneline -5 2>/dev/null || echo "Pas d'historique git")
\`\`\`

---
## Notes de Session (à remplir pendant le travail)

### Travail en Cours


### Décisions Prises


### Problèmes Rencontrés


### À Retenir

EOF

    echo -e "${GREEN}✅ Contexte de session créé: $CURRENT_FILE${NC}"
    echo ""
    echo "📋 Contexte à donner à Claude Code:"
    echo "----------------------------------------"
    cat "$CURRENT_FILE"
    echo "----------------------------------------"
    echo ""
    echo -e "${BLUE}💡 Copie ce contexte dans Claude Code pour qu'il reprenne où tu t'es arrêté!${NC}"
}

function end_session() {
    echo -e "${BLUE}💾 Sauvegarde session: $PROJECT_NAME${NC}"
    
    if [ ! -f "$CURRENT_FILE" ]; then
        echo -e "${RED}❌ Aucune session active trouvée${NC}"
        echo "Lancez d'abord: ./session-manager.sh start $PROJECT_NAME"
        exit 1
    fi
    
    # Créer le fichier d'historique
    HISTORY_FILE="$HISTORY_DIR/$DATE-$TIME-$PROJECT_NAME.md"
    
    # Demander un résumé
    echo ""
    echo "📝 Résumé rapide de la session (Entrée pour passer):"
    read -r SUMMARY
    
    echo "✅ Tâches complétées (une par ligne, Ctrl+D pour finir):"
    COMPLETED_TASKS=$(cat)
    
    echo "🔄 Tâches en cours (une par ligne, Ctrl+D pour finir):"
    IN_PROGRESS=$(cat)
    
    echo "📚 Leçon principale apprise:"
    read -r MAIN_LEARNING
    
    # Créer le fichier de fin de session
    cat > "$HISTORY_FILE" << EOF
# Session: $PROJECT_NAME
**Date**: $DATE  
**Heure**: $(date +"%H:%M")

## Résumé
${SUMMARY:-Pas de résumé fourni}

## Travail Accompli
### Complété ✅
${COMPLETED_TASKS:-Rien de spécifié}

### En Cours 🔄
${IN_PROGRESS:-Rien de spécifié}

## Commits Effectués
\`\`\`
$(cd "$(dirname "$BASE_DIR")" && git log --oneline --since="$DATE 00:00" 2>/dev/null || echo "Aucun commit aujourd'hui")
\`\`\`

## Apprentissages
${MAIN_LEARNING:-Aucun apprentissage noté}

## État Final du Projet
- Tests: $(check_tests_status)
- Build: $(check_build_status)
- Git: $(cd "$(dirname "$BASE_DIR")" && git status --porcelain | wc -l) fichiers modifiés

## Pour la Prochaine Session
### Priorité 1
${IN_PROGRESS:-Continuer le travail en cours}

## Commandes Utiles Utilisées
\`\`\`bash
$(history | tail -10 | cut -c 8-)
\`\`\`

---
*Session sauvegardée automatiquement*
EOF

    # Mettre à jour les learnings si nécessaire
    if [ -n "$MAIN_LEARNING" ]; then
        echo "" >> "$SESSIONS_DIR/learnings/patterns.md"
        echo "## Session $DATE - $PROJECT_NAME" >> "$SESSIONS_DIR/learnings/patterns.md"
        echo "$MAIN_LEARNING" >> "$SESSIONS_DIR/learnings/patterns.md"
    fi
    
    # Archiver la session courante
    mv "$CURRENT_FILE" "$HISTORY_FILE.current"
    
    echo -e "${GREEN}✅ Session sauvegardée: $HISTORY_FILE${NC}"
    echo ""
    echo "📊 Statistiques de session:"
    echo "  - Durée: ~$(calculate_duration) heures"
    echo "  - Commits: $(cd "$(dirname "$BASE_DIR")" && git log --oneline --since="$DATE 00:00" 2>/dev/null | wc -l)"
    echo "  - Fichiers modifiés: $(cd "$(dirname "$BASE_DIR")" && git status --porcelain 2>/dev/null | wc -l)"
}

function show_status() {
    if [ -f "$CURRENT_FILE" ]; then
        echo -e "${GREEN}📋 Session Active${NC}"
        echo ""
        cat "$CURRENT_FILE"
    else
        echo -e "${YELLOW}⚠️  Aucune session active${NC}"
        echo "Lancez: ./session-manager.sh start [project]"
    fi
}

function show_history() {
    echo -e "${BLUE}📚 Historique: $PROJECT_NAME${NC}"
    echo ""
    
    if [ "$PROJECT_NAME" = "default" ]; then
        ls -lt "$HISTORY_DIR" 2>/dev/null | grep -v total | head -10
    else
        ls -lt "$HISTORY_DIR" 2>/dev/null | grep "$PROJECT_NAME" | head -10
    fi
    
    echo ""
    echo "Pour voir une session: cat $HISTORY_DIR/[fichier]"
}

function show_learnings() {
    echo -e "${BLUE}📖 Base de Connaissances${NC}"
    echo ""
    echo -e "${GREEN}=== Patterns Qui Marchent ===${NC}"
    head -30 "$SESSIONS_DIR/learnings/patterns.md"
    echo ""
    echo -e "${RED}=== Erreurs à Éviter ===${NC}"
    head -30 "$SESSIONS_DIR/learnings/avoid.md"
}

# Helper Functions
function detect_project_type() {
    if [ -f "composer.json" ]; then
        if grep -q "laravel/framework" composer.json 2>/dev/null; then
            echo "Laravel"
        else
            echo "PHP"
        fi
    elif [ -f "package.json" ]; then
        echo "Node.js"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "Python"
    elif [ -f "wp-config.php" ] || [ -d "wp-content" ]; then
        echo "WordPress"
    else
        echo "Unknown"
    fi
}

function detect_stack() {
    local stack=""
    [ -f "docker-compose.yml" ] && stack="Docker "
    [ -f "composer.json" ] && stack="${stack}PHP "
    [ -f "package.json" ] && stack="${stack}Node "
    [ -f "requirements.txt" ] && stack="${stack}Python "
    echo "${stack:-N/A}"
}

function detect_environment() {
    if [ -f ".env" ]; then
        grep "APP_ENV\|NODE_ENV" .env 2>/dev/null | cut -d'=' -f2 || echo "local"
    else
        echo "local"
    fi
}

function check_tests_status() {
    if [ -f "composer.json" ] && grep -q "phpunit" composer.json; then
        echo "PHPUnit disponible"
    elif [ -f "package.json" ] && grep -q "test" package.json; then
        echo "Tests npm disponibles"
    else
        echo "Pas de tests configurés"
    fi
}

function check_build_status() {
    if [ -f "package.json" ] && grep -q "build" package.json; then
        echo "Build disponible"
    else
        echo "N/A"
    fi
}

function calculate_duration() {
    # Simpliste: suppose session de ~2h en moyenne
    echo "~2-3"
}

# Main
case "$1" in
    start)
        start_session
        ;;
    end)
        end_session
        ;;
    status)
        show_status
        ;;
    history)
        show_history
        ;;
    learn|learnings)
        show_learnings
        ;;
    *)
        show_help
        ;;
esac