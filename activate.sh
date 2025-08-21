#!/bin/bash

# Jean Claude v2 - Profile Activator
# Usage: ./activate.sh [profile-name|--auto]

PROFILE=$1
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$BASE_DIR")"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Auto-detection si --auto
if [ "$PROFILE" = "--auto" ] || [ "$PROFILE" = "-a" ]; then
    echo -e "${BLUE}🔍 Détection automatique du type de projet...${NC}"
    echo ""
    
    # Run detector and capture output
    source "$BASE_DIR/project-detector.sh" "$PROJECT_DIR" > /tmp/detector_output.txt 2>&1
    
    # Read detected config if exists
    if [ -f "$BASE_DIR/detected-config.json" ]; then
        DETECTED_PROFILE=$(grep '"recommended_profile"' "$BASE_DIR/detected-config.json" | cut -d'"' -f4)
        DETECTED_TYPE=$(grep '"project_type"' "$BASE_DIR/detected-config.json" | cut -d'"' -f4)
        
        if [ -n "$DETECTED_PROFILE" ] && [ "$DETECTED_PROFILE" != "null" ]; then
            echo -e "${GREEN}✅ Type détecté: $DETECTED_TYPE${NC}"
            echo -e "${GREEN}✅ Profil sélectionné: $DETECTED_PROFILE${NC}"
            echo ""
            PROFILE="$DETECTED_PROFILE"
        else
            echo -e "${YELLOW}⚠️  Impossible de détecter le type. Utilisation du profil par défaut.${NC}"
            PROFILE="poc-rapide"
        fi
    else
        echo -e "${YELLOW}⚠️  Détection échouée. Utilisation du profil par défaut.${NC}"
        PROFILE="poc-rapide"
    fi
fi

if [ -z "$PROFILE" ]; then
    echo "❌ Usage: ./activate.sh [profile-name|--auto]"
    echo ""
    echo "Options:"
    echo "  --auto, -a     Détection automatique du profil"
    echo ""
    echo "Available profiles:"
    ls -1 "$BASE_DIR/profiles" | sed 's/\.md$//' | sed 's/^/  - /'
    exit 1
fi

PROFILE_FILE="$BASE_DIR/profiles/$PROFILE.md"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ Profile '$PROFILE' not found!"
    echo ""
    echo "Available profiles:"
    ls -1 "$BASE_DIR/profiles" | sed 's/\.md$//' | sed 's/^/  - /'
    exit 1
fi

# Create CLAUDE.md at project root
CLAUDE_FILE="$(dirname "$BASE_DIR")/CLAUDE.md"

cat > "$CLAUDE_FILE" << 'EOF'
# Jean Claude v2 - Configuration Active

EOF

echo "## 🎯 Profile Actif: $PROFILE" >> "$CLAUDE_FILE"
echo "" >> "$CLAUDE_FILE"
echo "---" >> "$CLAUDE_FILE"
echo "" >> "$CLAUDE_FILE"

# Add profile content
cat "$PROFILE_FILE" >> "$CLAUDE_FILE"

echo "" >> "$CLAUDE_FILE"
echo "---" >> "$CLAUDE_FILE"
echo "" >> "$CLAUDE_FILE"
echo "## 📁 Fichiers de Configuration Chargés" >> "$CLAUDE_FILE"
echo "" >> "$CLAUDE_FILE"

# Extract and load referenced files
if grep -q "pragmatic-builder" "$PROFILE_FILE"; then
    echo "### Agent: Pragmatic Builder" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/base/pragmatic-builder.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "git-guardian" "$PROFILE_FILE"; then
    echo "### Agent: Git Guardian" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/base/git-guardian.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "memory-keeper" "$PROFILE_FILE"; then
    echo "### Agent: Memory Keeper" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/base/memory-keeper.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    echo "### Session Context" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/sessions/current.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "psr-enforcer" "$PROFILE_FILE"; then
    echo "### Agent: PSR Enforcer" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/specialized/psr-enforcer.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "test-guardian" "$PROFILE_FILE"; then
    echo "### Agent: Test Guardian" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/specialized/test-guardian.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "session-continuity" "$PROFILE_FILE"; then
    echo "### Agent: Session Continuity" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/base/session-continuity.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    
    # Ajouter le contexte de session si existe
    if [ -f "$BASE_DIR/sessions/current-session.md" ]; then
        echo "### Contexte Session Active" >> "$CLAUDE_FILE"
        echo "" >> "$CLAUDE_FILE"
        cat "$BASE_DIR/sessions/current-session.md" >> "$CLAUDE_FILE"
        echo "" >> "$CLAUDE_FILE"
    fi
fi

if grep -q "wordpress-expert" "$PROFILE_FILE"; then
    echo "### Agent: WordPress Expert" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/specialized/wordpress-expert.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "laravel-expert" "$PROFILE_FILE"; then
    echo "### Agent: Laravel Expert" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/specialized/laravel-expert.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "fastapi-expert" "$PROFILE_FILE"; then
    echo "### Agent: FastAPI Expert" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/agents/specialized/fastapi-expert.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "autonomous" "$PROFILE_FILE"; then
    echo "### Trust Level: Autonomous" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/contexts/trust-levels/autonomous.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

if grep -q "conservative" "$PROFILE_FILE"; then
    echo "### Trust Level: Conservative" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    cat "$BASE_DIR/contexts/trust-levels/conservative.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
fi

echo "✅ Profile '$PROFILE' activé!"
echo "📄 Configuration écrite dans: $CLAUDE_FILE"
echo ""
echo "Claude Code va maintenant se comporter selon le profil '$PROFILE'."
echo "Pour changer de profil, relancez: ./activate.sh [autre-profile]"