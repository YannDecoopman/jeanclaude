# 🤖 Jean Claude v2 - Modular Configuration System for Claude Code

> Transform Claude Code into a personalized assistant with modular agents and persistent memory.

## 🚀 Quick Start

```bash
# Automatic project detection
./activate.sh --auto

# Or manual profile selection
./activate.sh poc-rapide
```

## 📦 Structure

```
jean-claude-v2/
├── agents/          # Agents that modify behavior
│   ├── base/       # shipit, recall, atomic, resume, tracker
│   └── specialized/ # wordpress-expert, laravel-expert, etc.
├── contexts/        # Trust levels (autonomous, conservative)
├── profiles/        # Ready-to-use combinations
└── sessions/        # Persistent memory between sessions
```

## 🎯 Available Agents

### Base Agents
- **shipit**: Ship fast, commit every 20 min
- **recall**: Memory from previous sessions  
- **atomic**: Strict atomic commits
- **resume**: Resume with complete context
- **tracker**: Log all real actions

### Specialized Agents
- **wordpress-expert**: Hooks, child themes, WP-CLI
- **laravel-expert**: Eloquent, queues, services
- **fastapi-expert**: Async, Pydantic, SQLAlchemy
- **psr-enforcer**: Strict PSR-12 for PHP
- **test-guardian**: Mandatory TDD, 80%+ coverage

## 🎭 Pre-configured Profiles

- **poc-rapide**: Fast prototyping, zero friction
- **entreprise-laravel**: PSR-12, tests, production code
- **wordpress-docker**: Optimized for dockerized WordPress
- **laravel-dev**: Balance between speed and quality
- **poc-python**: Quick FastAPI for POCs

## 🔍 Automatic Detection

```bash
./project-detector.sh

# Detects:
# - WordPress (wp-config.php + docker-compose)
# - Laravel (artisan + composer.json)
# - FastAPI (requirements.txt + fastapi)
```

## 💾 Persistent Memory

```bash
# Start session
./session-manager.sh start my-project

# End session (auto-save)
./session-manager.sh end my-project

# View history
./session-manager.sh history my-project
```

## 📊 Action Tracking

The `tracker` agent logs all actions in `.jean-claude/session.log`:

```log
[14:32:01] CREATE file:UserService.php lines:45
[14:33:00] FIX bug:queue-not-running solution:start-worker
[14:34:00] COMMIT message:"fix: queue" files:3
```

Analyze with:
```bash
tools/analyze-logs.sh summary
tools/analyze-logs.sh patterns
```

## 🆚 Difference with Jean Claude v1

| v1 (Bash Scripts) | v2 (Markdown Agents) |
|-------------------|----------------------|
| Scripts that "do" things | Instructions that modify behavior |
| No memory | Complete persistent memory |
| Fixed profiles | Combinable modular agents |
| No detection | Auto-detection of project type |

## 📈 Measured ROI

- **Without Jean Claude**: 15-20 min to recover context
- **With Jean Claude v2**: 0 min, immediate resume
- **Gain per session**: 20-30 min
- **Over 10 sessions**: 3-5 hours saved

## 🔄 Typical Workflow

```bash
# 1. Activate the right profile
./activate.sh --auto

# 2. Claude Code reads CLAUDE.md with agents

# 3. Modified behavior:
# - Starts with "Resuming with context..."
# - Auto-commit every 20 min
# - Logs all actions
# - Saves session at the end
```

## 🎯 How It Works

Jean Claude v2 uses **markdown agents** that Claude Code reads at the beginning of each session. These agents contain instructions that fundamentally change how Claude behaves:

- **Not scripts** that execute commands
- **But instructions** that modify Claude's personality and workflow
- Claude reads them and **becomes** a different assistant

Example: With the `shipit` agent, Claude stops asking "Would you like me to..." and starts saying "I'm doing X..." - a complete behavior change.

## 🛠️ Installation

```bash
# Clone the repo
git clone https://github.com/YannDecoopman/jeanclaude.git
cd jeanclaude

# Use in your project
cd ../your-project
../jeanclaude/activate.sh --auto
```

## 📄 License

MIT - Use freely in your projects

---

*Jean Claude v2 - "Agents that truly transform Claude's behavior"*

**Version 2.0** | By Yann with Claude