#!/bin/bash

# Jean Claude v2 - Project Type Detector
# Détecte automatiquement le type de projet et recommande le profil

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(dirname "$BASE_DIR")}"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables de détection
PROJECT_TYPE=""
PROJECT_STACK=""
PROJECT_ENV=""
RECOMMENDED_PROFILE=""
CONFIDENCE="low"

function detect_wordpress() {
    local score=0
    local details=""
    
    # Détection forte
    if [ -f "$PROJECT_DIR/wp-config.php" ]; then
        score=$((score + 50))
        details="${details}✓ wp-config.php trouvé\n"
    fi
    
    if [ -d "$PROJECT_DIR/wp-content" ]; then
        score=$((score + 50))
        details="${details}✓ wp-content/ trouvé\n"
    fi
    
    # Détection Docker WordPress
    if [ -f "$PROJECT_DIR/docker-compose.yml" ] || [ -f "$PROJECT_DIR/docker-compose.yaml" ]; then
        if grep -q "wordpress" "$PROJECT_DIR/docker-compose.y*" 2>/dev/null; then
            score=$((score + 30))
            details="${details}✓ Docker Compose avec WordPress\n"
            PROJECT_ENV="docker"
        fi
    fi
    
    # Détection thème
    if [ -d "$PROJECT_DIR/wp-content/themes" ]; then
        local theme_count=$(ls -1 "$PROJECT_DIR/wp-content/themes" 2>/dev/null | wc -l)
        if [ $theme_count -gt 0 ]; then
            score=$((score + 20))
            details="${details}✓ $theme_count thèmes détectés\n"
        fi
    fi
    
    # Détection plugins critiques
    if [ -d "$PROJECT_DIR/wp-content/plugins/advanced-custom-fields-pro" ]; then
        score=$((score + 10))
        details="${details}✓ ACF Pro détecté\n"
    fi
    
    if [ $score -ge 100 ]; then
        PROJECT_TYPE="wordpress"
        if [ "$PROJECT_ENV" = "docker" ]; then
            PROJECT_STACK="WordPress Dockerisé"
            RECOMMENDED_PROFILE="wordpress-docker"
        else
            PROJECT_STACK="WordPress Standard"
            RECOMMENDED_PROFILE="wordpress-standard"
        fi
        CONFIDENCE="high"
        echo -e "${details}"
        return 0
    fi
    
    return 1
}

function detect_laravel() {
    local score=0
    local details=""
    local laravel_version=""
    
    # Détection forte
    if [ -f "$PROJECT_DIR/artisan" ]; then
        score=$((score + 40))
        details="${details}✓ artisan trouvé\n"
    fi
    
    if [ -f "$PROJECT_DIR/composer.json" ]; then
        if grep -q "laravel/framework" "$PROJECT_DIR/composer.json" 2>/dev/null; then
            score=$((score + 50))
            laravel_version=$(grep -o '"laravel/framework": "[^"]*"' "$PROJECT_DIR/composer.json" | cut -d'"' -f4)
            details="${details}✓ Laravel $laravel_version détecté\n"
        fi
    fi
    
    # Détection structure Laravel
    if [ -d "$PROJECT_DIR/app" ] && [ -d "$PROJECT_DIR/resources" ] && [ -d "$PROJECT_DIR/routes" ]; then
        score=$((score + 30))
        details="${details}✓ Structure Laravel standard\n"
    fi
    
    # Détection environnement
    if [ -f "$PROJECT_DIR/.env" ]; then
        score=$((score + 10))
        details="${details}✓ Fichier .env présent\n"
        
        # Détection mode entreprise
        if grep -q "APP_ENV=production" "$PROJECT_DIR/.env" 2>/dev/null; then
            PROJECT_ENV="production"
        elif grep -q "APP_ENV=staging" "$PROJECT_DIR/.env" 2>/dev/null; then
            PROJECT_ENV="staging"
        else
            PROJECT_ENV="local"
        fi
    fi
    
    # Détection tests
    if [ -d "$PROJECT_DIR/tests" ] && [ -f "$PROJECT_DIR/phpunit.xml" ]; then
        score=$((score + 10))
        details="${details}✓ Tests PHPUnit configurés\n"
    fi
    
    # Détection packages entreprise
    if grep -q "laravel/horizon\|laravel/telescope\|laravel/sanctum" "$PROJECT_DIR/composer.json" 2>/dev/null; then
        score=$((score + 10))
        details="${details}✓ Packages entreprise détectés\n"
    fi
    
    if [ $score -ge 90 ]; then
        PROJECT_TYPE="laravel"
        PROJECT_STACK="Laravel $laravel_version"
        
        if [ "$PROJECT_ENV" = "production" ] || [ "$PROJECT_ENV" = "staging" ]; then
            RECOMMENDED_PROFILE="entreprise-laravel"
        else
            RECOMMENDED_PROFILE="laravel-dev"
        fi
        
        CONFIDENCE="high"
        echo -e "${details}"
        return 0
    fi
    
    return 1
}

function detect_fastapi() {
    local score=0
    local details=""
    
    # Détection forte
    if [ -f "$PROJECT_DIR/requirements.txt" ]; then
        if grep -q "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
            score=$((score + 50))
            details="${details}✓ FastAPI dans requirements.txt\n"
        fi
    fi
    
    if [ -f "$PROJECT_DIR/pyproject.toml" ]; then
        if grep -q "fastapi" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
            score=$((score + 50))
            details="${details}✓ FastAPI dans pyproject.toml\n"
        fi
    fi
    
    # Détection main.py typique FastAPI
    if [ -f "$PROJECT_DIR/main.py" ] || [ -f "$PROJECT_DIR/app/main.py" ]; then
        local main_file="$PROJECT_DIR/main.py"
        [ -f "$PROJECT_DIR/app/main.py" ] && main_file="$PROJECT_DIR/app/main.py"
        
        if grep -q "from fastapi import\|import fastapi" "$main_file" 2>/dev/null; then
            score=$((score + 40))
            details="${details}✓ Import FastAPI dans main.py\n"
        fi
        
        if grep -q "app = FastAPI()" "$main_file" 2>/dev/null; then
            score=$((score + 20))
            details="${details}✓ Instance FastAPI créée\n"
        fi
    fi
    
    # Détection structure FastAPI
    if [ -d "$PROJECT_DIR/app" ] && [ -d "$PROJECT_DIR/app/routers" ]; then
        score=$((score + 20))
        details="${details}✓ Structure FastAPI avec routers\n"
    fi
    
    # Détection Alembic (migrations)
    if [ -d "$PROJECT_DIR/alembic" ] || [ -f "$PROJECT_DIR/alembic.ini" ]; then
        score=$((score + 10))
        details="${details}✓ Alembic configuré (migrations)\n"
    fi
    
    # Détection environnement
    if [ -f "$PROJECT_DIR/.env" ]; then
        PROJECT_ENV="development"
        details="${details}✓ Fichier .env présent\n"
    fi
    
    # Détection Docker
    if [ -f "$PROJECT_DIR/Dockerfile" ]; then
        if grep -q "python\|fastapi" "$PROJECT_DIR/Dockerfile" 2>/dev/null; then
            score=$((score + 10))
            details="${details}✓ Dockerfile Python/FastAPI\n"
        fi
    fi
    
    if [ $score -ge 50 ]; then
        PROJECT_TYPE="fastapi"
        PROJECT_STACK="Python/FastAPI"
        RECOMMENDED_PROFILE="poc-python"
        CONFIDENCE="high"
        echo -e "${details}"
        return 0
    fi
    
    return 1
}

function detect_generic() {
    local details=""
    
    # Détection PHP générique
    if [ -f "$PROJECT_DIR/composer.json" ]; then
        PROJECT_TYPE="php"
        PROJECT_STACK="PHP"
        details="${details}✓ Projet PHP (composer.json)\n"
    # Détection Node.js générique
    elif [ -f "$PROJECT_DIR/package.json" ]; then
        PROJECT_TYPE="node"
        PROJECT_STACK="Node.js"
        details="${details}✓ Projet Node.js (package.json)\n"
    # Détection Python générique
    elif [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/setup.py" ]; then
        PROJECT_TYPE="python"
        PROJECT_STACK="Python"
        details="${details}✓ Projet Python\n"
    else
        PROJECT_TYPE="unknown"
        PROJECT_STACK="Non détecté"
        CONFIDENCE="none"
        return 1
    fi
    
    RECOMMENDED_PROFILE="poc-rapide"
    CONFIDENCE="medium"
    echo -e "${details}"
    return 0
}

function analyze_project() {
    echo -e "${BLUE}🔍 Analyse du projet: $PROJECT_DIR${NC}"
    echo ""
    
    # Tentative de détection dans l'ordre de priorité
    if detect_wordpress; then
        echo -e "${GREEN}✅ Type détecté: WordPress${NC}"
    elif detect_laravel; then
        echo -e "${GREEN}✅ Type détecté: Laravel${NC}"
    elif detect_fastapi; then
        echo -e "${GREEN}✅ Type détecté: FastAPI${NC}"
    else
        detect_generic
        if [ "$PROJECT_TYPE" = "unknown" ]; then
            echo -e "${YELLOW}⚠️  Type de projet non reconnu${NC}"
        else
            echo -e "${YELLOW}⚠️  Type générique: $PROJECT_TYPE${NC}"
        fi
    fi
    
    # Détection additionnelle
    detect_additional_features
}

function detect_additional_features() {
    echo ""
    echo -e "${CYAN}📋 Caractéristiques additionnelles:${NC}"
    
    # Git
    if [ -d "$PROJECT_DIR/.git" ]; then
        local branch=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null)
        echo "  ✓ Git repository (branch: ${branch:-unknown})"
    fi
    
    # Docker
    if [ -f "$PROJECT_DIR/docker-compose.yml" ] || [ -f "$PROJECT_DIR/docker-compose.yaml" ]; then
        echo "  ✓ Docker Compose configuré"
    fi
    
    # CI/CD
    if [ -d "$PROJECT_DIR/.github/workflows" ]; then
        echo "  ✓ GitHub Actions configuré"
    elif [ -f "$PROJECT_DIR/.gitlab-ci.yml" ]; then
        echo "  ✓ GitLab CI configuré"
    fi
    
    # Tests
    if [ -f "$PROJECT_DIR/phpunit.xml" ] || [ -f "$PROJECT_DIR/phpunit.xml.dist" ]; then
        echo "  ✓ PHPUnit configuré"
    elif [ -f "$PROJECT_DIR/pytest.ini" ] || [ -f "$PROJECT_DIR/setup.cfg" ]; then
        echo "  ✓ Pytest configuré"
    elif [ -f "$PROJECT_DIR/jest.config.js" ]; then
        echo "  ✓ Jest configuré"
    fi
    
    # Linting
    if [ -f "$PROJECT_DIR/.eslintrc" ] || [ -f "$PROJECT_DIR/.eslintrc.js" ]; then
        echo "  ✓ ESLint configuré"
    elif [ -f "$PROJECT_DIR/.php-cs-fixer.php" ] || [ -f "$PROJECT_DIR/.php-cs-fixer.dist.php" ]; then
        echo "  ✓ PHP CS Fixer configuré"
    elif [ -f "$PROJECT_DIR/.flake8" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
        grep -q "flake8\|black\|ruff" "$PROJECT_DIR/pyproject.toml" 2>/dev/null && echo "  ✓ Python linting configuré"
    fi
}

function generate_config() {
    local config_file="$BASE_DIR/detected-config.json"
    
    cat > "$config_file" << EOF
{
  "project_type": "$PROJECT_TYPE",
  "project_stack": "$PROJECT_STACK",
  "project_env": "$PROJECT_ENV",
  "recommended_profile": "$RECOMMENDED_PROFILE",
  "confidence": "$CONFIDENCE",
  "project_dir": "$PROJECT_DIR",
  "detected_at": "$(date -Iseconds)"
}
EOF
    
    echo ""
    echo -e "${GREEN}✅ Configuration sauvegardée: $config_file${NC}"
}

function show_recommendation() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎯 RECOMMANDATION${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "Type de projet: ${CYAN}$PROJECT_STACK${NC}"
    echo -e "Environnement: ${CYAN}${PROJECT_ENV:-local}${NC}"
    echo -e "Confiance: ${CYAN}$CONFIDENCE${NC}"
    echo ""
    
    if [ "$RECOMMENDED_PROFILE" != "" ]; then
        echo -e "${GREEN}Profil recommandé: $RECOMMENDED_PROFILE${NC}"
        echo ""
        echo "Pour activer ce profil:"
        echo -e "${YELLOW}./activate.sh $RECOMMENDED_PROFILE${NC}"
    else
        echo -e "${YELLOW}Profil par défaut: poc-rapide${NC}"
        echo ""
        echo "Pour activer:"
        echo -e "${YELLOW}./activate.sh poc-rapide${NC}"
    fi
    
    echo ""
    echo "Ou activation automatique:"
    echo -e "${YELLOW}./activate.sh --auto${NC}"
}

# Main execution
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Jean Claude v2 - Project Detector     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

analyze_project
generate_config
show_recommendation

# Export pour utilisation dans activate.sh
export DETECTED_PROFILE="$RECOMMENDED_PROFILE"
export DETECTED_TYPE="$PROJECT_TYPE"
export DETECTED_CONFIDENCE="$CONFIDENCE"