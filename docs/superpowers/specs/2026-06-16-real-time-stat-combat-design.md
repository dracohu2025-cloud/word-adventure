# Real-Time Stat Combat Design

## 背景

当前 BOSS 战使用“选择技能 + 回答英文题目 + 回合结算”的形式。这个方案能把 `sword / shield / book` 和战斗动作绑定起来，但实际体验会频繁打断战斗节奏，视觉上也更像答题面板，不像 RPG 战斗。

新的方向是把战斗从单词背诵中抽离出来：战斗由动画和数值系统驱动，单词学习转移到 NPC 任务、装备解锁、剧情谜题和成长系统中。这样玩家先通过学习获得能力，再在战斗中看到能力产生效果。

## 设计目标

- 战斗体验更像 RPG：玩家与怪物在场景中实时交战，而不是弹出答题面板。
- 视觉反馈优先：攻击动画、受击反馈、伤害飘字、血条变化要比文字说明更重要。
- 数值系统可扩展：第一版支持 HP、MP、金币、攻击力、防御力、攻击速度、暴击。
- 保持 POC 可控：先支持单个 BOSS，不做技能栏、装备栏、背包 UI、复杂 AI 或多怪战斗。
- 学习和战斗仍有关联：单词不直接参与攻击输入，而是用于解锁装备、技能或属性奖励。

## 非目标

- 不复刻完整《魔兽世界》战斗公式。
- 不做仇恨系统、职业天赋、DOT/HOT、范围技能、打断、控制链。
- 不做联网、同步、战斗日志持久化。
- 不在第一版实现玩家主动技能轮盘。
- 不引入新的付费或生成素材。

## 推荐方案

采用“MMO-lite 自动战斗”。

玩家靠近 BOSS 并交互后进入战斗状态。玩家和 BOSS 根据各自攻击速度自动出手，每次出手播放攻击动画，随后按数值公式结算伤害，并在目标头顶显示伤害数字。战斗中不出现答题面板。

第一版仍然保留简单控制：玩家可以移动到 BOSS 附近触发战斗，但进入战斗后先采用自动互攻。这样能快速验证数值、血条、飘字、动画和胜负流程。

## 战斗流程

1. 玩家完成三个 NPC 支线后，BOSS 出现在森林入口。
2. 玩家靠近 BOSS 并按交互键。
3. `CombatManager.start_boss_battle("word_imp")` 进入实时战斗。
4. 顶部玩家 HUD 显示 HP、MP、金币、等级。
5. BOSS 头顶显示名称和 HP 条。
6. 双方各自累积攻击计时器：
   - 玩家每 `player_attack_interval` 秒攻击一次。
   - BOSS 每 `enemy_attack_interval` 秒攻击一次。
7. 每次攻击触发：
   - 攻击动画或受击闪烁。
   - 数值伤害结算。
   - 目标头顶飘出伤害数字。
   - HP 条实时减少。
8. 玩家 HP 归零，战斗失败并回到安全位置。
9. BOSS HP 归零，战斗胜利，标记 BOSS 已击败，发放金币和经验。

## 数值模型

第一版属性：

- `max_hp`
- `hp`
- `max_mp`
- `mp`
- `attack_power`
- `defense`
- `attack_speed`
- `crit_chance`
- `crit_multiplier`
- `level`
- `gold`

建议初始数值：

```text
玩家：
level = 1
max_hp = 120
max_mp = 40
attack_power = 18
defense = 8
attack_speed = 1.3
crit_chance = 0.1
crit_multiplier = 1.5

Word Imp：
level = 1
max_hp = 180
attack_power = 14
defense = 5
attack_speed = 0.9
crit_chance = 0.05
crit_multiplier = 1.5
```

`attack_speed` 表示每秒攻击次数。攻击间隔：

```text
attack_interval = 1.0 / attack_speed
```

基础伤害公式：

```text
armor_reduction = defense / (defense + level * 25.0)
raw_damage = attack_power
damage_after_armor = raw_damage * (1.0 - armor_reduction)
final_damage = max(1, round(damage_after_armor))
```

暴击：

```text
if random() < crit_chance:
    final_damage *= crit_multiplier
```

第一版使用可预测的伪随机即可，不需要复杂命中、闪避和等级压制。

## UI 设计

### 顶部玩家 HUD

玩家 HUD 常驻在屏幕上方，替代当前左上角任务板的一部分功能，第一版显示：

- 头像或职业图标
- 等级
- HP 条：`HP 120 / 120`
- MP 条：`MP 40 / 40`
- 金币：`金币 0`
- 任务进度：`书页 3/3`

HUD 要像素化，使用现有 `PixelUIStyle` 的边框、暗色底和金色描边。

### 怪物头顶状态栏

只在战斗中显示：

- BOSS 名称：`Word Imp`
- HP 条
- 当前 HP 数值

状态栏跟随 BOSS 的世界坐标移动。它不应该遮挡 BOSS 立绘，位置应在头顶上方 12-20 像素。

### 伤害飘字

每次造成伤害，在目标头顶生成飘字：

- 玩家打怪：黄色或白色数字。
- 怪物打玩家：红色数字。
- 暴击：更大、更亮，带短暂缩放。

飘字生命周期约 0.7 秒，向上漂移并淡出。

### 战斗面板处理

当前 `BattlePanel` 不再作为主战斗 UI。第一版可以先隐藏或停用它，避免旧答题战斗与实时战斗并存造成混乱。

## 数据流

1. `BossEncounter` 仍然负责触发 BOSS 战。
2. `CombatManager` 改为实时战斗状态机，负责：
   - 初始化双方战斗属性。
   - 在 `_process(delta)` 或专用 tick 方法中推进攻击计时器。
   - 计算伤害。
   - 发出 `damage_dealt`、`combatant_changed`、`battle_finished` 信号。
3. `VillageHUD` 监听玩家状态变化，刷新顶部 HUD。
4. 新增或改造 `EnemyStatusBar`，监听 BOSS 状态并跟随 BOSS 显示。
5. 新增 `FloatingDamageText`，由战斗伤害事件创建并自动销毁。
6. 战斗胜利后，`QuestManager.mark_boss_defeated()`，并通过 `PlayerData` 发放金币和经验。

## 组件边界

### `CombatManager`

职责：战斗规则和状态。

不负责：

- 不直接创建 UI。
- 不直接播放具体动画。
- 不读取输入。

### `PlayerData`

职责：玩家长期属性和资源。

需要扩展：

- HP / MP / Gold / Level / Experience。
- 从基础属性派生战斗属性。

### `VillageHUD`

职责：显示玩家长期状态。

需要扩展：

- HP 条、MP 条、金币、等级。
- 保留任务进度，但视觉上不要压过生命状态。

### `BossEncounter`

职责：世界中的 BOSS 节点和战斗入口。

需要扩展：

- 持有 BOSS 状态栏挂点。
- 接收受击反馈信号，播放简单动画或闪烁。

## 学习系统与战斗的连接

战斗不再要求玩家输入单词，但学习仍然影响战斗：

- 学会 `sword`：获得基础武器，提升 `attack_power`。
- 学会 `shield`：获得初心护符或盾牌，提升 `defense`。
- 学会 `book`：解锁对 Word Imp 的最终胜利条件或额外伤害。

第一版可以先把三个 NPC 支线完成后的奖励汇总成：

```text
attack_power +6
defense +4
max_mp +10
```

之后再把这些奖励视觉化为装备或技能。

## 测试策略

新增或更新测试：

- 战斗开始后，`CombatManager` 进入实时战斗状态。
- 攻击计时器到达间隔后，玩家会对 BOSS 造成伤害。
- BOSS 攻击计时器到达间隔后，玩家会受到伤害。
- 防御属性会降低受到的伤害。
- 暴击会造成更高伤害，并在伤害事件中标记 `is_critical`。
- BOSS HP 归零后，触发胜利和任务完成。
- 玩家 HP 归零后，触发失败。
- `VillageHUD` 显示 HP、MP、金币。
- BOSS 头顶状态栏只在战斗中显示。
- 伤害飘字在伤害事件后生成，并在生命周期结束后销毁。

## 实施顺序

1. 给 `PlayerData` 增加 HP、MP、金币和基础战斗属性。
2. 把 `CombatManager` 从答题回合制改为实时战斗 tick。
3. 新增伤害事件信号和伤害计算方法。
4. 改造 `BattlePanel`：先在实时战斗中隐藏旧答题面板。
5. 扩展 `VillageHUD`：顶部显示 HP、MP、金币、等级和书页。
6. 新增 BOSS 头顶状态栏。
7. 新增伤害飘字。
8. 接入简单攻击/受击动画反馈。
9. 更新战斗相关测试与视觉捕获。

## 风险与取舍

- 实时战斗会让 `CombatManager` 更像系统核心，需要保持边界清晰，避免 UI 和规则混在一起。
- 如果自动战斗缺少玩家输入，可能会偏“看戏”。第一版先验证视觉和数值，下一版再加主动技能或走位机制。
- 参考《魔兽世界》应参考“属性驱动和攻速节奏”，不复制完整复杂公式。
- 单词学习必须保留在成长闭环里，否则项目主题会被削弱。

