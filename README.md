# Jean Claude v2 - Système de Configuration Modulaire pour Claude Code

## Structure

```
jean-claude-v2/
├── agents/          # Personnalités et comportements
├── contexts/        # Niveaux de confiance et règles
├── profiles/        # Combinaisons prêtes à l'emploi
└── sessions/        # Mémoire entre sessions
```

## Utilisation

```bash
./activate.sh poc-rapide        # Mode POC rapide
./activate.sh entreprise-strict  # Mode entreprise avec standards stricts
```

## Agents Disponibles

- **pragmatic-builder**: Optimise pour la vitesse, refactorise après
- **git-guardian**: Commits atomiques fréquents, historique propre

## Profils

- **poc-rapide**: Autonome, rapide, peu de questions
- **entreprise-strict**: PSR-12, tests obligatoires, validations