# 精简重构实施方案

---

## 第一步：删除 codeg-server 独立服务器

### 要删的文件
| # | 文件 | 操作 |
|---|------|------|
| 1 | `src-tauri/src/bin/codeg_server.rs` | 🗑 整个文件 |
| 2 | `src-tauri/Cargo.toml` | 删第44-47行 `[[bin]] name = "codeg-server"` |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 3 | `Dockerfile` | 删 Stage 2 构建 codeg-server 的行 + Stage 3 复制行 + CMD |
| 4 | `docker-compose.yml` | 🗑 整个文件 |
| 5 | `.github/workflows/test.yml` | 删 `mode: [desktop, server]` 中的 server，去掉 server 分支 |
| 6 | `.github/workflows/release.yml` | 删 server 相关构建步骤 |
| 7 | `.github/workflows/build.yml` | 检查是否有 server 引用 |
| 8 | `package.json` | 删 `server:build` + `server:dev` 脚本 |
| 9-18 | `docs/readme/*.md` + `README.md` | 删服务器部署章节 |

### 验证
- `cargo check` 通过（无 codeg-server 引用的编译错误）
- `cargo build --bin codeg` 正常

---

## 第二步：国际化缩到 en + zh-CN + zh-TW

### 要删的文件
| # | 文件 | 大小 |
|---|------|:----:|
| 19 | `src/i18n/messages/ja.json` | 147KB |
| 20 | `src/i18n/messages/ar.json` | 151KB |
| 21 | `src/i18n/messages/ko.json` | 133KB |
| 22 | `src/i18n/messages/es.json` | 130KB |
| 23 | `src/i18n/messages/de.json` | 132KB |
| 24 | `src/i18n/messages/fr.json` | 134KB |
| 25 | `src/i18n/messages/pt.json` | 128KB |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 26 | `src/lib/i18n.ts` 或 i18n 配置 | 只注册 en/zh-CN/zh-TW 三种语言 |
| 27 | `src/i18n/request.ts` 或类似 | 同上 |

### 验证
- `pnpm build` 通过
- 页面显示正常，未保留语言自动回退到英文

---

## 第三步：删除 project-boot 项目初始化向导

### 要删的文件
| # | 文件 | 备注 |
|---|------|------|
| 28 | `src/components/project-boot/` | 整个目录（~76KB） |
| 29 | `src/app/project-boot/` | 整个目录 |
| 30 | `src-tauri/src/commands/project_boot.rs` | 23KB |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 31 | `src-tauri/src/lib.rs` | 去掉 project_boot:: 注册 |
| 32 | `src-tauri/src/commands/mod.rs` | 删 mod project_boot |
| 33 | `src-tauri/src/web/router.rs`（如有） | 删 project_boot 路由 |
| 34 | 前端路由/菜单 | 删入口 |

### 验证
- `cargo check` 通过
- `pnpm build` 通过
- 工作区没有项目初始化按钮/链接残留

---

## 第四步：删除 gemini + openclaw 解析器

### 要删的文件
| # | 文件 | 大小 |
|---|------|:----:|
| 35 | `src-tauri/src/parsers/gemini.rs` | 40KB |
| 36 | `src-tauri/src/parsers/openclaw.rs` | 52KB |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 37 | `src-tauri/src/parsers/mod.rs` | 删 mod gemini + mod openclaw |

### 验证
- `cargo check` 通过
- 导入功能不报错

---

## 第五步：删除桌面宠物（可选，阶段二）

### 要删的文件
| # | 文件/目录 | 备注 |
|---|-----------|------|
| 38 | `src-tauri/src/pets/` | 整个目录 |
| 39 | `src-tauri/src/pet_state_mapper.rs` | 整个文件 |
| 40 | `src-tauri/src/commands/pet.rs` | 整个文件 |
| 41 | `src-tauri/src/models/pet.rs` | 整个文件 |
| 42 | `src/app/pet/` | 整个目录 |
| 43 | `src/components/settings/pet*` | 宠物设置组件 |
| 44 | `src/lib/pet/` | 整个目录 |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 45 | `src-tauri/src/lib.rs` | 删 pet_state_mapper 引用 + pet 订阅任务 |
| 46 | `src-tauri/src/commands/mod.rs` | 删 mod pet |
| 47 | `src-tauri/src/models/mod.rs` | 删 mod pet |
| 48 | `src-tauri/src/db/` | 可能需处理 pet 表 |
| 49 | 前端 settings 页面 | 删宠物设置入口 |

### 验证
- `cargo check` 通过
- `pnpm build` 通过
- 设置页面无宠物选项

---

## 第六步：删除聊天频道（可选，阶段二）

### 要删的文件
| # | 文件/目录 | 备注 |
|---|-----------|------|
| 50 | `src-tauri/src/chat_channel/` | 整个目录（397KB） |
| 51 | `src-tauri/src/commands/chat_channel.rs` | 整个文件 |
| 52 | `src/components/settings/chat-channel*` | 前端组件 |
| 53 | `src-tauri/src/web/handlers/chat_channel.rs` | 如有 |

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 54 | `src-tauri/src/lib.rs` | 删 chat_channel 初始化 |
| 55 | `src-tauri/src/commands/mod.rs` | 删 mod chat_channel |
| 56 | `src-tauri/src/app_state.rs` | 删 ChatChannelManager |
| 57 | `src-tauri/src/models/mod.rs` | 删 chat_channel 模型 |
| 58 | 前端 settings 页面 | 删聊天频道入口 |
| 59 | `src-tauri/src/db/` | 处理 chat_channel 表 |

### 验证
- `cargo check` 通过
- `pnpm build` 通过
- 应用启动正常

---

## 第七步：项目重命名 + 图标重新设计

### 命名方案（待定）

候选名称（用户选择）：
- **Apex** — 巅峰，顶级
- **Nexus** — 枢纽，多智能体连接
- **Forge** — 锻造
- **Orbit** — 轨道运行
- **Craft** — 精心打造

### 要改的文件
| # | 文件 | 改动 |
|---|------|------|
| 60 | `src-tauri/Cargo.toml` | `name = "新名称"` |
| 61 | `src-tauri/tauri.conf.json` | `productName` + `identifier` |
| 62 | `package.json` | `name` |
| 63 | `src-tauri/Tauri-icon` | 所有图标文件 |
| 64 | `public/` | 图标、logo |
| 65 | 全部 README | 更新名称 |
| 66 | 安装脚本 | 更新名称 |

### 图标设计
- 重新设计 SVG 图标
- 更新 tauri.conf.json 中的图标路径
- 生成各平台图标（icon.ico, icon.png, icon.icns）

### 验证
- 编译后二进制名称为新名字
- 窗口标题显示新名字
- 图标正确显示
