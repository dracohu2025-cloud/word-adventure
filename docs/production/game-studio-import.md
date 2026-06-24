# 游戏工作流引入记录

来源参考：

- [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)
- [htdt/godogen](https://github.com/htdt/godogen)

许可说明：上游项目使用 MIT License。本项目不直接 vendor 这些仓库；本文件记录的是为 `word-adventures` 重新撰写和适配后的工作流思想。

## 已引入的思想

### 1. 视觉优先制作

任何会出现在玩家屏幕上的功能，都必须先经过视觉检查，才能算 review-ready。

必要文档：

- `design/art/art-bible.md`：全局美术方向。
- `design/assets/asset-manifest.md`：已批准素材来源和使用规则。
- `design/ux/hud-and-prompts.md`：HUD、对话、提示、面板、战斗浮层规则。
- `design/gameplay/beginner-village-loop.md`：当前第一章玩法循环和验收清单。

### 2. 可见功能先写最小 brief

玩家可见功能开工前，先写清楚最小范围：

- 玩家侧目的。
- 交互前后的屏幕状态。
- 需要哪些素材。
- 需要哪张验收截图或 capture scene。
- 如果有交互行为，需要哪个回归测试。

### 3. Playtest 反馈进入 backlog

用户反馈要记录为观察，而不是模糊评价。

使用 `docs/production/playtest-notes.md` 记录：

- 玩家尝试了什么。
- 玩家期待什么。
- 实际发生了什么。
- 属于视觉问题、交互问题还是系统问题。
- 严重度和下一步动作。

### 4. Godot 开发纪律

Godot 场景应保持小而可检查：

- Scene 文件负责布局和节点层级。
- Script 文件负责行为和状态流转。
- Autoload 只负责跨场景系统。
- 用户已经遇到过的交互回归要补测试。

详见 `docs/production/godot-development-rules.md`。

### 5. 按功能类型验证

行为和视觉分开验证：

- 行为回归使用 Godot 场景测试。
- 视觉打磨使用明确的 capture scene 或人工截图检查。
- 用户已经反馈过的玩家可见问题，能补测试就补测试。

详见 `docs/production/test-and-capture-strategy.md`。

### 6. Godogen 式截图修复闭环

从 `godogen` 中吸收的关键原则：截图和录屏是玩家可见结果的事实来源。

本项目落地方式：

- `docs/production/godogen-workflow-adaptation.md`：适配后的工作流。
- `docs/production/visual-qa-gate.md`：视觉验收门槛。
- `scripts/run_visual_gate.sh word_castle_portrait`：当前手机竖屏单词城堡原型的视觉验收入口。
- `docs/production/project-memory.md`：项目级经验和坑。

## 不引入的内容

- 上游 `.claude/` 运行时结构。
- 只适用于 Claude Code 的 slash commands 和 hooks。
- 大型多代理路由规则。
- 与本项目 Godot/GDScript 架构不匹配的通用模板。
- `godogen` 的 C#/.NET Godot 生成器运行时。
- 本项目尚未采用的外部资产生成服务依赖。

## 当前项目默认值

- 主引擎：Godot 4。
- 主美术方向：高质量像素幻想 RPG。
- 主要目标用户：中国大陆中小学生。
- UI 语言：默认中文；英语只用于词汇内容和直接学习选项。
- 当前需求基线：`requirement.md`。
- 当前主线：横屏 `1280 x 720` 的第一章“书灯村”，优先验证 PC Web 端可玩性。
- 长期参考：`docs/superpowers/specs/2026-06-24-word-castle-portrait-ui-design.md`。
- 素材优先级：
  1. 已购且本地可用的 Tiny Swords 素材。
  2. 已批准的 CC0 / MIT / CC-BY 开源素材。
  3. 现有素材无法覆盖时，再生成补充素材。
