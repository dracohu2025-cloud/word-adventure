# Turn-Based Combat Design

Status: historical design record. This approach was explored, but the current implementation direction is real-time stat-driven combat. See `docs/superpowers/specs/2026-06-16-real-time-stat-combat-design.md`.

## 背景

当前战斗已经有玩家 HP、敌人 HP、`attack / shield / capture` 三个技能，以及 BOSS 技能词映射：

- `attack` 对应 `sword`
- `shield` 对应 `shield`
- `capture` 对应 `book`

但当前体验更像“玩家答题后立即扣血/反击”，敌人行动不够明确，导致 `shield` 缺少清晰价值。新版本目标是把 BOSS 战调整为清晰的回合制：玩家和怪物轮流行动，玩家根据敌人意图选择英文单词技能。

## 设计目标

- 战斗节奏清晰：玩家能看懂现在轮到谁行动。
- 技能语义自然：`sword / shield / book` 与攻击、防御、收服一一对应。
- UI 视觉优先：战斗界面保留角色、怪物、意图气泡、日志和技能按钮，不做纯表单化界面。
- 保持 POC 范围：先支持单敌人和 Word Imp BOSS，不引入多怪物、装备、技能冷却、复杂状态异常。

## 非目标

- 不做多敌人战斗。
- 不做背包、药水、装备系统。
- 不做技能冷却或技能树。
- 不做复杂 AI 行为树。
- 不重做地图和 BOSS 入场逻辑。

## 推荐方案

采用“清晰回合 + 战场叠加型 UI”。

战斗以 `CombatManager` 为唯一状态来源，`BattlePanel` 只负责展示状态、收集玩家选择、渲染当前题目和反馈。

### 回合流程

1. 进入战斗后生成敌人意图，例如 `attack`。
2. 进入玩家回合，UI 显示：
   - 回合状态：玩家回合
   - 敌人意图：例如“下一回合攻击 3”
   - 技能按钮：`sword 攻击`、`shield 防御`、`book 收服`
3. 玩家选择技能后，UI 构建对应英文单词题目。
4. 玩家提交答案后，`CombatManager` 结算玩家动作：
   - `sword` 答对：对敌人造成伤害。
   - `shield` 答对：本回合进入防御姿态。
   - `book` 答对：若 BOSS 可收服，则胜利。
   - 答错：玩家动作失败。
5. 若战斗未结束，进入敌人回合。
6. 敌人根据本回合意图行动：
   - 普通攻击会造成伤害。
   - 若玩家本回合成功使用 `shield`，普通攻击被格挡或显著减伤。
7. 敌人行动后生成下一轮意图，回到玩家回合。

## 状态模型

`CombatManager` 增加明确的战斗阶段：

- `PLAYER_TURN`：玩家可选择技能和答题。
- `PLAYER_RESOLVE`：玩家动作结算。
- `ENEMY_TURN`：敌人行动展示和结算。
- `VICTORY`：战斗胜利。
- `DEFEAT`：战斗失败。

第一版可以不暴露 `PLAYER_RESOLVE` 为长时间 UI 状态，但内部应保留该概念，方便以后加动画。

`CombatManager` 需要提供：

- `get_turn_phase()`
- `get_turn_count()`
- `get_enemy_intent()`
- `get_last_combat_log()`
- `can_select_skill(skill_id)`
- `apply_answer_result(correct, skill_id)`

## 敌人意图

第一版只需要少量可读意图：

- `attack`：下一回合造成固定伤害。
- `heavy_attack`：造成更高伤害，但出现频率低。

Word Imp BOSS 可以按固定序列循环：

1. `attack`
2. `attack`
3. `heavy_attack`

这样玩家能在看到强攻击时自然选择 `shield`。

## 技能语义

### sword / 攻击

- 对应技能：`attack`
- 题目词：`sword`
- 答对：对敌人造成伤害。
- 答错：不造成伤害，敌人仍行动。

### shield / 防御

- 对应技能：`shield`
- 题目词：`shield`
- 答对：本轮防御成功，敌人攻击减伤或格挡。
- 答错：防御失败，敌人照常攻击。

第一版建议：普通攻击完全格挡，重击减伤。

### book / 收服

- 对应技能：`capture`
- 题目词：`book`
- 仅当 BOSS HP 低于或等于捕获阈值时可用。
- 答对：收服成功，战斗胜利。
- 答错：BOSS 恢复少量 HP，敌人行动。

## UI 设计

采用战场叠加型界面。

### 主要区域

- 顶部状态条：显示“玩家回合 / 敌人回合”和回合数。
- 敌人旁意图气泡：显示“攻击 3”或“重击 5”。
- 中部战斗日志：显示短反馈，例如“你拼对 sword，剑光命中！”。
- 底部技能区：
  - `sword 攻击`
  - `shield 防御`
  - `book 收服`
- 题目区：显示当前技能对应题目和英文选项。

### 文案原则

- UI 主文案使用中文。
- 英文单词只出现在技能词和选项中。
- 日志短句优先，不写长段说明。

示例：

- “Word Imp 准备攻击 3 点。”
- “你拼对 sword，剑光命中！”
- “你拼对 shield，挡住了攻击。”
- “book 发出光芒，Word Imp 被收服了！”

## 数据流

1. `BossEncounter.start_interaction()` 调用 `CombatManager.start_boss_battle("word_imp")`。
2. `CombatManager` 初始化敌人 HP、玩家 HP、回合数、敌人意图。
3. `BattlePanel` 响应 `battle_started` 和 `battle_changed` 刷新 UI。
4. 玩家选技能时，`BattlePanel` 读取敌人数据中的 `skill_words` 和 `skill_challenge_types`，生成题目。
5. 玩家答题后，`BattlePanel` 调用 `CombatManager.apply_answer_result(correct, skill_id)`。
6. `CombatManager` 完成玩家结算、敌人回合、下一轮意图生成，并发出 `battle_changed`。
7. 若胜负已定，`CombatManager` 发出 `battle_finished`。

## 测试策略

新增或更新以下回归测试：

- 正确攻击会造成敌人伤害，并进入下一玩家回合。
- 答错攻击不会造成伤害，但敌人会行动。
- 敌人意图会显示且按回合推进。
- 正确 `shield` 会降低或格挡敌人攻击。
- 错误 `shield` 不会格挡敌人攻击。
- BOSS 低血量前不能 `capture`。
- BOSS 低血量后正确 `book` 可以收服。
- 错误 `book` 不结束战斗，并触发敌人行动。
- `BattlePanel` 显示中文回合状态、敌人意图和技能词。

## 实施顺序

1. 给 `CombatManager` 增加回合阶段、敌人意图、战斗日志。
2. 改造 `apply_answer_result()`，让玩家动作和敌人动作按回合结算。
3. 更新 `BattlePanel`，显示回合状态、敌人意图和中文战斗日志。
4. 调整现有战斗测试，补充回合制新测试。
5. 做一次视觉截图验证，检查战斗面板不再像表单，而是像战场叠加 UI。
