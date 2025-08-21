#!/bin/bash

# Jean Claude v2 - Log Analyzer
# Analyse les logs d'actions pour détecter les patterns

LOG_DIR=".jean-claude"
LOG_FILE="$LOG_DIR/session.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

function show_help() {
    echo "📊 Jean Claude Log Analyzer"
    echo ""
    echo "Usage: ./analyze-logs.sh [command]"
    echo ""
    echo "Commands:"
    echo "  summary    - Résumé de la session actuelle"
    echo "  patterns   - Patterns détectés"
    echo "  time       - Analyse temporelle"
    echo "  bugs       - Bugs rencontrés et fixes"
    echo "  top        - Top 10 actions"
    echo "  metrics    - Métriques JSON"
}

function check_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}❌ Pas de logs trouvés dans $LOG_FILE${NC}"
        echo "Activez un profil avec action-logger d'abord"
        exit 1
    fi
}

function show_summary() {
    check_logs
    echo -e "${BLUE}📊 Résumé de Session${NC}"
    echo ""
    
    # Stats basiques
    local total_actions=$(wc -l < "$LOG_FILE")
    local files_created=$(grep -c "CREATE file:" "$LOG_FILE")
    local files_modified=$(grep -c "MODIFY file:" "$LOG_FILE")
    local bugs_fixed=$(grep -c "FIX bug:" "$LOG_FILE")
    local tests_run=$(grep -c "RUN cmd:.*test" "$LOG_FILE")
    local commits=$(grep -c "COMMIT" "$LOG_FILE")
    
    echo "📈 Statistiques:"
    echo "  Total actions: $total_actions"
    echo "  Fichiers créés: $files_created"
    echo "  Fichiers modifiés: $files_modified"
    echo "  Bugs corrigés: $bugs_fixed"
    echo "  Tests exécutés: $tests_run"
    echo "  Commits: $commits"
    
    # Durée session
    if [ $total_actions -gt 0 ]; then
        local start_time=$(head -1 "$LOG_FILE" | cut -d' ' -f2 | cut -d']' -f1)
        local end_time=$(tail -1 "$LOG_FILE" | cut -d' ' -f2 | cut -d']' -f1)
        echo ""
        echo "⏱️  Temps:"
        echo "  Début: $start_time"
        echo "  Fin: $end_time"
    fi
}

function show_patterns() {
    check_logs
    echo -e "${CYAN}🔍 Patterns Détectés${NC}"
    echo ""
    
    # Patterns de bugs
    echo "🐛 Bugs récurrents:"
    grep "IDENTIFY bug:" "$LOG_FILE" | \
        sed 's/.*bug://' | cut -d' ' -f1 | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count bug; do
            echo "  $count x $bug"
        done
    
    echo ""
    echo "🔧 Solutions appliquées:"
    grep "FIX" "$LOG_FILE" | \
        sed 's/.*solution://' | cut -d' ' -f1 | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count solution; do
            echo "  $count x $solution"
        done
    
    echo ""
    echo "📝 Décisions techniques:"
    grep "DECIDE" "$LOG_FILE" | \
        sed 's/.*choice://' | cut -d' ' -f1 | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count decision; do
            echo "  $count x $decision"
        done
}

function show_time_analysis() {
    check_logs
    echo -e "${YELLOW}⏱️  Analyse Temporelle${NC}"
    echo ""
    
    # Actions par heure
    echo "📅 Actions par heure:"
    cut -d' ' -f2 "$LOG_FILE" | cut -d: -f1 | \
        sort | uniq -c | \
        while read count hour; do
            # Créer une barre visuelle
            bar=$(printf '█%.0s' $(seq 1 $((count/2))))
            echo "  ${hour}h: $bar ($count)"
        done
    
    echo ""
    echo "🔥 Périodes intenses (>10 actions/5min):"
    # Grouper par tranches de 5 minutes
    awk '{print substr($2,1,5)}' "$LOG_FILE" | \
        uniq -c | sort -rn | head -3 | \
        while read count time; do
            echo "  $time - $count actions"
        done
}

function show_bugs() {
    check_logs
    echo -e "${RED}🐛 Analyse des Bugs${NC}"
    echo ""
    
    echo "Bugs identifiés:"
    grep "IDENTIFY bug:" "$LOG_FILE" | \
        while IFS= read -r line; do
            bug=$(echo "$line" | sed 's/.*bug://' | cut -d' ' -f1)
            impact=$(echo "$line" | grep -o "impact:[^ ]*" | cut -d: -f2)
            echo "  • $bug (impact: ${impact:-unknown})"
        done
    
    echo ""
    echo "Solutions appliquées:"
    grep "FIX bug:" "$LOG_FILE" | \
        while IFS= read -r line; do
            bug=$(echo "$line" | sed 's/.*bug://' | cut -d' ' -f1)
            solution=$(echo "$line" | grep -o "solution:[^ ]*" | cut -d: -f2)
            time=$(echo "$line" | grep -o "time:[^ ]*" | cut -d: -f2)
            echo "  ✓ $bug → $solution (${time:-unknown})"
        done
}

function show_top_actions() {
    check_logs
    echo -e "${GREEN}🏆 Top 10 Actions${NC}"
    echo ""
    
    # Extraire le type d'action et compter
    awk '{print $3}' "$LOG_FILE" | \
        sort | uniq -c | sort -rn | head -10 | \
        while read count action; do
            printf "  %3d x %s\n" "$count" "$action"
        done
}

function generate_metrics() {
    check_logs
    echo -e "${BLUE}📊 Génération metrics.json${NC}"
    
    local total=$(wc -l < "$LOG_FILE")
    local created=$(grep -c "CREATE" "$LOG_FILE")
    local modified=$(grep -c "MODIFY" "$LOG_FILE")
    local bugs=$(grep -c "FIX bug:" "$LOG_FILE")
    local tests=$(grep -c "test" "$LOG_FILE")
    local commits=$(grep -c "COMMIT" "$LOG_FILE")
    
    cat > "$LOG_DIR/metrics.json" << EOF
{
  "session": {
    "total_actions": $total,
    "files_created": $created,
    "files_modified": $modified,
    "bugs_fixed": $bugs,
    "tests_run": $tests,
    "commits": $commits,
    "generated_at": "$(date -Iseconds)"
  }
}
EOF
    
    echo "✅ Métriques sauvegardées dans $LOG_DIR/metrics.json"
}

# Main
case "$1" in
    summary)
        show_summary
        ;;
    patterns)
        show_patterns
        ;;
    time)
        show_time_analysis
        ;;
    bugs)
        show_bugs
        ;;
    top)
        show_top_actions
        ;;
    metrics)
        generate_metrics
        ;;
    *)
        show_help
        ;;
esac