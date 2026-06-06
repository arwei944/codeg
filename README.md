# Codeg

[![Release](https://img.shields.io/github/v/release/arwei944/codeg)](https://github.com/arwei944/codeg/releases)
[![License](https://img.shields.io/github/license/arwei944/codeg)](./LICENSE)
[![Tauri](https://img.shields.io/badge/Tauri-2.x-24C8DB)](https://tauri.app/)
[![Next.js](https://img.shields.io/badge/Next.js-16-black)](https://nextjs.org/)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED)](./Dockerfile)

<p>
  <strong>English</strong> |
  <a href="./docs/readme/README.zh-CN.md">简体中文</a> |
  <a href="./docs/readme/README.zh-TW.md">繁體中文</a> |
  <a href="./docs/readme/README.ja.md">日本語</a> |
  <a href="./docs/readme/README.ko.md">한국어</a> |
  <a href="./docs/readme/README.es.md">Español</a> |
  <a href="./docs/readme/README.de.md">Deutsch</a> |
  <a href="./docs/readme/README.fr.md">Français</a> |
  <a href="./docs/readme/README.pt.md">Português</a> |
  <a href="./docs/readme/README.ar.md">العربية</a>
</p>

Codeg is a **multi-agent coding workspace**. It aggregates sessions from multiple AI coding agents (Claude Code, Codex CLI, OpenCode, Gemini CLI, OpenClaw, Cline, etc.) into one unified workspace, enabling conversation aggregation, multi-agent collaboration, and remote task management. Available as a desktop app (Tauri), standalone server, or Docker deployment.

![gallery](./docs/images/gallery.svg)

## Features

### Conversation Aggregation
Import sessions from all supported agents into one unified workspace. Browse, search, filter, and revisit any session across agents.

### Multi-Agent Collaboration
Within a single session, the main agent delegates tasks to sub-agents of different types (e.g. Claude Code calling Codex, Gemini CLI) to jointly complete tasks. Each sub-agent runs as an independent session.

### Chat Channels
Connect messaging platforms to your coding agents:
- **Telegram** — Bot API (HTTP long-polling)
- **Lark (Feishu)** — WebSocket + REST API
- **iLink (Weixin)** — WebSocket + REST API
- More (Discord, Slack, DingTalk) planned

Send tasks, follow-up messages, approve permissions, resume sessions, and monitor activity — all from your chat app.

### Project Boot
Visually scaffold new projects with live preview:
- Pick style, color theme, icon library, font, border radius from dropdowns
- Live preview iframe updates instantly
- One-click scaffolding with shadcn/ui (Next.js / Vite / React Router / Astro / Laravel)
- Auto-detects installed package managers (pnpm / npm / yarn / bun)

### Engineering Tools
- File tree browser + diff viewer
- Git changes, commit, branch management with `git worktree` flows
- Integrated terminal
- MCP management (local scan + registry search/install)
- Skills management (global and project scope)
- Git remote account management (GitHub and other Git servers)

### Deployment Options
- **Desktop app** — Tauri 2 with native window management, tray, updater
- **Web service** — Access from any browser
- **Standalone server** — Run `codeg-server` on any Linux/macOS server
- **Docker** — `docker compose up` or `docker run`

## Quick Start

### Requirements
- Node.js `>=22`
- pnpm `>=10`
- Rust stable (2021 edition)
- Tauri 2 build dependencies (desktop mode only)

Linux (Debian/Ubuntu):
```bash
sudo apt-get update
sudo apt-get install -y \
  libwebkit2gtk-4.1-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev \
  patchelf
```

### Development
```bash
pnpm install

# Frontend only (Next.js dev server, no Rust)
pnpm dev

# Full desktop app
pnpm tauri dev

# Desktop release build
pnpm tauri build

# Standalone server (no GUI)
pnpm server:dev
pnpm server:build
```

### Binaries

| Binary | Role | Build |
|--------|------|-------|
| `codeg` | Tauri desktop app | `pnpm tauri build` |
| `codeg-server` | Standalone HTTP + WebSocket server | `pnpm server:build` |
| `codeg-mcp` | Per-launch stdio MCP companion for multi-agent delegation | Auto-built with sidecar |

### Server Deployment

**One-line install (Linux / macOS):**
```bash
curl -fsSL https://raw.githubusercontent.com/arwei944/codeg/main/install.sh | bash
```

**One-line install (Windows PowerShell):**
```powershell
irm https://raw.githubusercontent.com/arwei944/codeg/main/install.ps1 | iex
```

**Docker:**
```bash
docker compose up -d
# or
docker run -d -p 3080:3080 -v codeg-data:/data ghcr.io/arwei944/codeg:latest
```

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CODEG_PORT` | `3080` | HTTP port |
| `CODEG_HOST` | `0.0.0.0` | Bind address |
| `CODEG_TOKEN` | (random) | Auth token |
| `CODEG_DATA_DIR` | `~/.local/share/codeg` | SQLite database directory |
| `CODEG_STATIC_DIR` | `./web` or `./out` | Next.js static export directory |
| `CODEG_MCP_BIN` | (unset) | Absolute path to codeg-mcp companion |

## Supported Agents

| Agent | macOS / Linux Default | Windows Default |
|-------|----------------------|-----------------|
| Claude Code | `~/.claude/projects` | `%USERPROFILE%\.claude\projects` |
| Codex CLI | `~/.codex/sessions` | `%USERPROFILE%\.codex\sessions` |
| OpenCode | `~/.local/share/opencode/opencode.db` | `%USERPROFILE%\.local\share\opencode\opencode.db` |
| Gemini CLI | `~/.gemini` | `%USERPROFILE%\.gemini` |
| OpenClaw | `~/.openclaw/agents` | `%USERPROFILE%\.openclaw\agents` |
| Cline | `~/.cline/data/tasks` | `%USERPROFILE%\.cline\data\tasks` |

Environment variables (`$CLAUDE_CONFIG_DIR`, `$CODEX_HOME`, etc.) take precedence over fallback paths.

## Screenshots

### Main Interface
![Codeg Light](./docs/images/main-light.png#gh-light-mode-only)
![Codeg Dark](./docs/images/main-dark.png#gh-dark-mode-only)

### Settings
![Settings Light](./docs/images/settings-light.png#gh-light-mode-only)
![Settings Dark](./docs/images/settings-dark.png#gh-dark-mode-only)

### Project Boot
![Project Boot Light](./docs/images/project-boot-light.png#gh-light-mode-only)
![Project Boot Dark](./docs/images/project-boot-dark.png#gh-dark-mode-only)

## Architecture

```
Next.js 16 (Static Export) + React 19
        |
        | invoke() (desktop) / fetch() + WebSocket (web)
        v
  ┌─────────────────────────┐
  │   Transport Abstraction  │
  │  (Tauri IPC or HTTP/WS) │
  └─────────────────────────┘
        |
        v
┌─── Tauri Desktop ───┐    ┌─── codeg-server ───┐
│  Tauri 2 Commands    │    │  Axum HTTP + WS    │
│  (window management) │    │  (standalone mode)  │
└──────────┬───────────┘    └──────────┬──────────┘
           └──────────┬───────────────┘
                      v
            Shared Rust Core
              |- AppState
              |- ACP Manager
              |- Parsers (conversation ingestion)
              |- Chat Channels
              |- Git / File Tree / Terminal
              |- MCP marketplace + config
              |- SeaORM + SQLite
                      |
              ┌───────┼───────┐
              v       v       v
  Local Filesystem  Git   Chat Channels
    / Git Repos    Repos  (Telegram, Lark, iLink)
```

### Tech Stack

- **Desktop Runtime**: Tauri 2 (Rust backend + webview frontend)
- **Server Runtime**: Standalone Rust binary (Axum HTTP + WebSocket)
- **Frontend**: Next.js 16 (static export) + React 19 + TypeScript (strict)
- **Styling**: Tailwind CSS v4 + shadcn/ui (radix-maia)
- **i18n**: next-intl (10 languages)
- **Database**: SeaORM + SQLite
- **Package Manager**: pnpm

## In-Place Updates

The server can update itself from **Settings → Software Update**. It downloads the signed release for its platform, swaps binaries and web assets, and restarts.

Start with `--supervise` for auto-rollback on boot failure:
```bash
CODEG_STATIC_DIR=./web ./codeg-server --supervise
```

## Privacy & Security

- Local-first by default for parsing, storage, and project operations
- Network access only on user-triggered actions
- System proxy support for enterprise environments
- Web service mode uses token-based authentication

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

### Code Style
- Prettier: no semicolons, trailing commas (es5), 2-space indent, 80 char width
- ESLint: next/core-web-vitals + typescript + prettier
- TypeScript: strict mode with `noUnusedLocals` and `noUnusedParameters`
- Rust: 2021 edition, `thiserror` for error types

### Testing
```bash
# Frontend
pnpm eslint .
pnpm test
pnpm build

# Rust (in src-tauri/)
cargo check --features test-utils
cargo test --features test-utils
cargo clippy --all-targets --features test-utils -- -D warnings
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `codeg-mcp` not found | Set `CODEG_MCP_BIN` env var to absolute path of binary |
| Docker container exits immediately | Check `CODEG_TOKEN` is set or accept the random one printed to stderr |
| Desktop app won't build | Ensure Tauri 2 system dependencies are installed |
| Server won't start on port 3080 | Check port availability or set `CODEG_PORT` |
| Agent sessions not showing | Verify agent paths are correct (check environment variables) |
| Cannot connect to chat channels | Ensure bot tokens / webhook URLs are configured correctly in settings |

## License

Apache-2.0. See [LICENSE](./LICENSE).

## Acknowledgments

- [ACP (Agent Client Protocol)](https://agentclientprotocol.com) — the foundation enabling Codeg to connect with multiple agents
- [LinuxDO](https://linux.do) community for their support

## Community

Scan the QR code to join our WeChat group for discussions, feedback, and updates.

<img src="./docs/images/weixin-light.jpg#gh-light-mode-only" alt="WeChat" width="240" />
<img src="./docs/images/weixin-dark.jpg#gh-dark-mode-only" alt="WeChat" width="240" />
