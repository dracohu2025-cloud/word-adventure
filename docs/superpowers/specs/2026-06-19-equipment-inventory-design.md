# Equipment And Inventory Design

Date: 2026-06-19

## 背景

当前项目已经有实时数值战斗、玩家 HUD、金币、经验、NPC 支线奖励和 BOSS 战斗结算。`PlayerData` 中也已经预留了 `inventory`、`equipment` 以及 `strength / agility / intellect / stamina / spirit` 等主属性字段。

下一步需要把这些分散的成长点收束成一个玩家可理解、可操作、可展示的 RPG 成长系统：装备栏和背包栏。

本设计采用《魔兽世界》启发的信息架构：角色装备窗、合并背包、物品品质、tooltip、装备对比、右键快速装备/使用。但视觉上不复刻 WoW 的美术、图标、边框或布局细节，而是使用本项目已有的 Tiny Swords 像素风 UI 语言和安全授权素材。

## 设计目标

- 建立完整但可分阶段实现的装备栏 + 背包栏基础。
- 让玩家能通过 NPC 奖励和战斗掉落获得装备/消耗品。
- 让装备直接影响实时战斗数值。
- 让背包和装备 UI 具有清晰的 RPG 质感：品质颜色、格子、tooltip、属性对比。
- 面向中国大陆中小学生，界面说明使用中文；英文仅保留必要词汇、物品英文名或学习相关内容。
- 坚持视觉优先：首版实现必须接入真实像素素材或项目内像素 UI 样式，避免长期占位色块。

## 非目标

- 不 1:1 复刻 WoW 的具体公式、图标、美术或插件生态。
- 不做拖拽装备、背包内换位、多背包袋、搜索框、拍卖行、银行、材料仓库。
- 不做多职业收益差异；第一版只围绕战士职业。
- 不开放 Epic / Legendary / Artifact / Heirloom 等高阶品质掉落。
- 不做随机词缀、套装效果、装备耐久、附魔、宝石镶嵌。
- 不做存档系统重构；第一版可以只维护运行时状态。

## 推荐方案

采用“WoW 启发的双窗口装备系统”：

- 一个统一快捷键打开/关闭角色装备窗和背包窗。
- 角色装备窗和背包窗默认可以同时打开。
- 两个窗口都可以通过标题区域拖动。
- 背包使用单一合并网格，不做多个小包。
- 左键选中物品，显示 tooltip 和装备对比。
- 右键装备物品或使用消耗品。
- 右键已装备物品可卸下回背包。

## 窗口结构

### 角色装备窗

角色装备窗应像一个 RPG 角色面板，而不是普通设置面板。

首版结构：

- 顶部：角色名、等级、职业。
- 中间：玩家角色像素 avatar 或纸娃娃区域。
- 左右：装备槽位。
- 下方：属性面板，分为攻击、防御、生存等小组。

开放槽位：

- 武器
- 副手 / 盾牌
- 头部
- 胸甲
- 手套
- 腿甲
- 鞋子
- 护符

可灰显预留槽位：

- 戒指
- 披风
- 饰品
- 远程 / 魔法书

灰显槽位点击时显示短提示，例如：

```text
该装备槽将在后续冒险中解锁。
```

### 背包窗

背包窗采用合并背包网格。

首版规则：

- 固定 `20` 格。
- 推荐布局 `5 x 4`。
- 装备物品不可堆叠，占一个格子。
- 消耗品自动堆叠。
- 每个格子显示图标、品质边框、数量角标。
- 底部显示金币。
- 分类标签可先显示但只实现基础过滤：
  - 全部
  - 装备
  - 消耗品

第一版不做搜索框。搜索可以等物品数量超过当前新手村规模后再加入。

## 物品操作

### 左键

左键点击背包物品：

- 选中物品。
- 显示 tooltip。
- 如果物品是装备，并且对应槽已有装备，显示装备对比。

左键点击已装备物品：

- 显示 tooltip。
- 显示“当前已装备”状态。

### 右键

右键点击背包装备：

- 自动装备到对应槽位。
- 如果槽位已有装备，尝试把旧装备放回背包。
- 如果背包已满且需要卸下旧装备，则装备失败并提示背包已满。

右键点击已装备物品：

- 卸下回背包。
- 如果背包满，则卸下失败并提示。

右键点击消耗品：

- 立即使用。
- 堆叠数量减少。
- 数量为 0 时移除物品。

### 不支持的首版操作

- 拖拽到装备槽。
- 背包内换位。
- 拆分堆叠。
- 丢弃物品。
- 批量出售。

这些操作可在背包规模扩大后加入。

## 数据模型

### Item Definition

物品定义应集中管理，避免在 NPC、战斗、UI 中重复硬编码。

建议新增 `ItemDatabase` autoload 或等价资源文件，提供只读物品定义：

```gdscript
{
    "training_sword": {
        "id": "training_sword",
        "name": "训练木剑",
        "type": "equipment",
        "slot": "weapon",
        "quality": 1,
        "icon_path": "res://...",
        "weapon_damage_min": 4,
        "weapon_damage_max": 7,
        "weapon_speed": 1.8,
        "attributes": {
            "strength": 2,
            "stamina": 1
        },
        "description": "铁匠送给新手的练习武器。"
    }
}
```

### Inventory Entry

背包存储物品实例或堆叠条目：

```gdscript
{
    "item_id": "minor_healing_potion",
    "quantity": 3
}
```

装备首版可以不做随机词缀，因此不需要复杂实例 ID。后续如果加入随机词缀，再引入 `instance_id`。

### Equipment State

`PlayerData.equipment` 使用槽位到物品 ID 的映射：

```gdscript
{
    "weapon": "training_sword",
    "offhand": "beginner_shield",
    "chest": "cloth_tunic",
    "amulet": "beginner_charm"
}
```

### Signals

`PlayerData` 需要新增或明确以下信号：

- `inventory_changed`
- `equipment_changed`
- 继续保留 `stats_changed`

装备、卸下、使用物品后应触发对应信号，并让 UI 和战斗属性同步刷新。

## 装备槽位枚举

建议使用稳定字符串：

```text
weapon
offhand
head
chest
hands
legs
feet
amulet
ring
cloak
trinket
relic
```

首版开放：

```text
weapon, offhand, head, chest, hands, legs, feet, amulet
```

## 品质体系

严格采用 WoW 品质枚举和颜色语义：

| ID | 英文 | 中文 | 颜色 |
| ---: | --- | --- | --- |
| 0 | Poor | 粗糙 | `#9d9d9d` |
| 1 | Common | 普通 | `#ffffff` |
| 2 | Uncommon | 优秀 | `#1eff00` |
| 3 | Rare | 精良 | `#0070dd` |
| 4 | Epic | 史诗 | `#a335ee` |
| 5 | Legendary | 传说 | `#ff8000` |
| 6 | Artifact | 神器 | `#e6cc80` |
| 7 | Heirloom | 传家宝 | `#00ccff` |
| 8 | WoW Token | 特殊 | `#00ccff` |

新手村首版实际投放到 `Rare / 精良`：

- Poor / 粗糙
- Common / 普通
- Uncommon / 优秀
- Rare / 精良

UI 应完整支持所有颜色，但 loot table 不投放高阶品质。

## 属性体系

首版采用 WoW 主属性型，但只围绕战士职业设计收益。

主属性：

- `strength`：力量
- `agility`：敏捷
- `intellect`：智力
- `stamina`：耐力
- `spirit`：精神

装备基础属性：

- `armor`
- `weapon_damage_min`
- `weapon_damage_max`
- `weapon_speed`

战士收益建议：

```text
attack_power = base_attack_power
    + strength * 2
    + weapon_average_damage

max_hp = base_max_hp
    + stamina * 10

defense = base_defense
    + floor(armor / 3)

attack_speed = base_attack_speed
    + agility * 0.01
    + weapon_speed_modifier

crit_chance = base_crit_chance
    + agility * 0.002
```

公式不追求复刻 WoW 某个版本，只保留主属性驱动职业成长的结构。数值需要通过战斗体验继续校准。

智力和精神首版保留在数据结构和 UI 中，但战士装备不主动投放这两个属性，避免学生理解成本过高。

## Tooltip 设计

物品 tooltip 使用中文说明，保留英文学习点时可在括号中显示英文。

装备 tooltip 包含：

- 物品名称，按品质颜色显示。
- 绑定状态首版可不显示。
- 装备类型：例如 `单手剑`、`盾牌`、`胸甲`。
- 武器伤害和速度。
- 护甲值。
- 主属性。
- 说明文本。
- 右键提示：`右键装备`。

示例：

```text
训练木剑
普通
单手剑

伤害 4 - 7
速度 1.80
力量 +2
耐力 +1

铁匠送给新手的练习武器。
右键装备
```

消耗品 tooltip 包含：

- 名称
- 品质
- 类型：消耗品
- 使用效果
- 堆叠数量
- 右键提示：`右键使用`

## 装备对比

当选中背包装备，并且对应槽位已有装备时，tooltip 旁边显示当前装备对比。

首版不需要复杂绿色/红色逐行 diff，但至少显示：

- 当前装备名称。
- 新装备名称。
- 关键属性差值。

建议格式：

```text
当前：训练木剑
新：铜制短剑

攻击力 +3
耐力 -1
```

后续可加入类似 WoW 的绿色/红色差值高亮。

## 掉落与奖励

### NPC 固定奖励

三条新手村支线提供保底成长：

- 铁匠：武器或盾牌。
- 图书管理员：护符或书页相关物品。
- 园丁：药水/消耗品。

这些奖励保证玩家完成学习任务后拥有足够战斗能力，不依赖随机掉落。

### 怪物 / BOSS 概率掉落

普通怪物：

- 小概率掉 Poor / Common / Uncommon 装备或消耗品。

BOSS：

- 保底金币和经验。
- 保底关键奖励。
- 额外概率掉 Rare / 精良装备。

建议第一版使用简单 loot table：

```gdscript
[
    {"item_id": "minor_healing_potion", "chance": 0.45, "min": 1, "max": 2},
    {"item_id": "worn_leather_gloves", "chance": 0.20},
    {"item_id": "apprentice_guard_charm", "chance": 0.10}
]
```

不做先 roll 品质再 roll 词缀的完整系统。

## 背包满处理

背包固定 20 格。

规则：

- 新装备需要一个空格。
- 相同消耗品自动堆叠，不占新格。
- 如果掉落物品无法放入背包，战斗结算页显示“背包已满，未领取”。
- 首版不做邮箱或临时掉落箱。

战斗结算中应清楚展示哪些物品已进入背包，哪些未领取。

## UI 视觉要求

- 使用 Tiny Swords 或其他已确认授权的像素 UI 素材。
- 背包格子和装备槽必须有明确边框。
- 物品品质边框必须清晰可读。
- tooltip 使用像素化暗色面板 + 金色边框。
- 中文字号足够大，避免在 1280x720 下阅读困难。
- 不使用 WoW 原始图标、美术、边框截图。

## 与现有系统的集成

### `PlayerData`

需要扩展：

- 背包增删查。
- 装备/卸下。
- 消耗品使用。
- 装备属性汇总。
- 从主属性派生战斗属性。

`get_combat_stats()` 应返回装备加成后的数值。

### `CombatManager`

应继续只依赖 `PlayerData.get_combat_stats()`，不直接读取装备细节。

这样装备系统内部可以变化，不影响战斗管理器。

### `QuestManager` / NPC

支线完成时发放固定物品奖励。

奖励发放不应散落在 UI 中，建议通过 `PlayerData.add_item(item_id, quantity)` 完成。

### 战斗结算

战斗胜利后：

- 继续显示金币和经验。
- 新增掉落物品列表。
- 成功放入背包的物品显示正常。
- 背包满导致未领取的物品显示警告。

## 推荐分阶段实现

### Phase 1：数据模型和基础操作

- `ItemDatabase`
- 物品品质枚举
- 20 格背包
- 自动堆叠消耗品
- 装备/卸下/使用物品 API
- 装备影响 `PlayerData.get_combat_stats()`

### Phase 2：角色装备窗

- 统一快捷键打开 / 关闭角色装备窗和背包窗。
- 装备槽 UI。
- 角色属性面板。
- 已装备物品 tooltip。
- 右键卸下。

### Phase 3：背包窗

- 背包窗与角色装备窗默认一起打开，并可单独通过关闭按钮隐藏。
- 5x4 背包网格。
- 品质边框。
- 数量角标。
- 左键 tooltip。
- 右键装备/使用。

### Phase 4：奖励和掉落

- NPC 固定奖励。
- BOSS/怪物 loot table。
- 战斗结算展示掉落。
- 背包满提示。

### Phase 5：体验增强

- 装备对比。
- 分类标签。
- 更多装备图标。
- 更好的 SFX。
- 锁定槽提示。

## 测试策略

新增或扩展 Godot scene tests：

- `test_item_database.tscn`
  - 物品定义存在。
  - 品质颜色完整。
  - 首版物品都有图标路径和中文名。

- `test_inventory_stack_and_capacity.tscn`
  - 背包固定 20 格。
  - 消耗品可堆叠。
  - 装备不可堆叠。
  - 背包满时新增装备失败。

- `test_equipment_stats.tscn`
  - 装备武器增加攻击。
  - 装备护甲增加防御/生命。
  - 卸下装备恢复数值。

- `test_equipment_ui.tscn`
  - 角色窗可打开。
  - 核心槽位存在。
  - 灰显槽位提示存在。

- `test_inventory_ui.tscn`
  - 背包窗可打开。
  - 显示 20 格。
  - 品质边框可见。
  - 数量角标可见。

- `test_loot_rewards.tscn`
  - NPC 支线奖励进入背包。
  - BOSS 胜利后根据 loot table 发放物品。
  - 战斗结算显示掉落。

现有全量测试仍应通过。

## 验收标准

本设计对应的首轮实现完成时：

- 玩家能用一个统一快捷键打开 / 关闭角色装备窗和背包窗。
- 两个窗口默认同时打开，并且都可以通过标题区域拖动。
- 背包固定 20 格，消耗品自动堆叠。
- 玩家可右键装备、卸下、使用消耗品。
- 装备影响实时战斗数值。
- 物品显示 WoW 品质颜色语义。
- 新手村 NPC 和 BOSS 能发放物品奖励。
- 战斗结算显示掉落物品。
- UI 使用像素风素材，不出现长期色块占位。
- 全量 Godot 测试通过。
