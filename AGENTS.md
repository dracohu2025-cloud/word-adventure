# Word Adventures Agent Rules

本文件是项目级开发约定。它吸收了 [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) 中对游戏制作有帮助的工作流思想，但不引入其 Claude Code 专用运行时。

## 默认语言

始终使用简体中文和项目作者沟通。

## 文档语言

项目文档默认使用简体中文撰写。

例外：

- 代码标识、文件路径、字段名、资源名保持原文。
- 英语、日语、德语等学习内容保持目标语言原文。
- 引用第三方项目、素材包、许可证名称时保留官方名称。

## 视觉优先

本项目是视觉依赖型、视觉优先的像素 RPG。

任何玩家可见功能都必须考虑：

- 是否使用真实像素素材，而不是占位形状。
- 视觉容器、边框、按钮、名牌等不能临时手绘；必须优先使用许可明确的开源/已购素材，素材缺口再用 image_gen 生成。
- 文字是否适合中国大陆中小学生阅读。
- UI 是否像游戏界面，而不是默认引擎控件。
- 截图中是否存在遮挡、重叠、错位、过小、对比度不足。
- 任何固定尺寸容器内的文字都必须有明确的内边距、换行/裁剪策略和回归测试，不能越出视觉边框。
- 玩家可见的地名、章节名、NPC 名不能使用“入口村”“新手村”这类功能占位名，必须使用自然、有世界感的中文命名。

视觉规范见：

- `design/art/art-bible.md`
- `design/assets/asset-manifest.md`
- `design/ux/hud-and-prompts.md`

## 当前设计源头

实现玩家可见功能前，优先对齐：

- `requirement.md`
- `docs/superpowers/specs/2026-06-21-story-script-design.md`
- `design/gameplay/beginner-village-loop.md`
- `docs/story/chapter-01-adventure-gate-village-script.md`
- `docs/story/chapter-01-02-map-design.md`
- `docs/superpowers/specs/2026-06-16-real-time-stat-combat-design.md`
- `docs/superpowers/specs/2026-06-19-equipment-inventory-design.md`

旧规格可以作为历史思路参考，但如果与上述文件冲突，以上述文件为准。

## 素材使用顺序

1. 优先使用当前已引入并许可明确的 Tiny Swords 素材。
2. Tiny Swords 不覆盖时，使用 Kenney / LPC / Dungeon Crawl 等许可安全素材。
3. 仍无法覆盖时，再考虑生成素材。

使用新素材前要记录来源、许可和用途。

## Godot 开发边界

- `.tscn` 负责节点结构和初始布局。
- `.gd` 负责行为逻辑。
- Autoload 只放跨场景状态或系统。
- 鼠标和键盘路径应尽量调用同一底层方法。

更多规则见 `docs/production/godot-development-rules.md`。

## 测试与验证

修复用户已经反馈过的问题时，优先补回归测试。

常见测试目标：

- 交互提示点击不被地图寻路抢走。
- NPC / BOSS 交互能通过鼠标和键盘触发。
- 背包、装备、战斗、任务状态变更符合预期。
- UI 文本、按钮、面板的关键布局可通过代码断言。

完成前必须运行和改动相关的测试，并在最终回复中说明结果。

视觉类改动的验证策略见 `docs/production/test-and-capture-strategy.md`。

## Godogen 适配后的视觉验收门槛

本项目只吸收 `htdt/godogen` 中适合我们的工作流，不引入其生成器运行时。

玩家可见改动完成前必须做到：

- 先运行相关 Godot 测试，再生成对应截图。
- 以截图为准判断视觉问题；代码看起来正确但截图里错位、遮挡、出框，就视为未完成。
- 手机竖屏界面必须验证 720x1280 基准截图。
- UI 文本必须通过边界检查：文字不能超出容器、不能被按钮或图标遮挡。
- 所有视觉容器、按钮、边框、名牌必须来自已记录来源的素材或生成素材；不要临时代码绘制。
- 每次发现新的 Godot 或视觉坑，要沉淀到 `docs/production/project-memory.md` 或相关设计文档。

可直接运行：

- `scripts/run_visual_gate.sh word_castle_portrait`

详细规则见 `docs/production/godogen-workflow-adaptation.md` 和 `docs/production/visual-qa-gate.md`。

## Git 规则

除非用户明确要求，不要执行：

- `git commit`
- `git push`
- 创建分支
- reset / checkout 等可能覆盖用户改动的命令

仓库可能处于脏工作区。不要回滚自己没有创建的改动。

## Playtest 工作流

用户体验反馈优先记录为：

- 场景
- 观察
- 期望
- 类型
- 严重度
- 下一步动作

模板见 `docs/production/playtest-notes.md`。
