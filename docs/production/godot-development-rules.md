# Godot Development Rules

This document adapts the Godot-oriented workflow ideas from [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) for this project.

## Scene Ownership

- `.tscn` files own node hierarchy and initial layout.
- `.gd` files own behavior.
- Autoloads own cross-scene systems only.

Avoid putting unrelated gameplay logic into scene scripts just because a node is easy to access.

## Autoload Boundaries

Current expected responsibilities:

- `GameManager`: game state transitions.
- `PlayerData`: player stats, inventory, equipment, currencies.
- `QuestManager`: quest and progression state.
- `CombatManager`: combat orchestration.
- `AudioManager`: BGM and SFX playback.
- `ControlHints`: global contextual prompt layer.

Rule: if state belongs to one scene only, keep it in that scene.

## Signal Rules

Use signals for cross-node coordination when:

- The sender should not know the receiver.
- UI needs to react to data changes.
- Gameplay systems notify scene objects.

Keep direct node calls when:

- Parent owns child behavior.
- The call is local and obvious.
- Adding a signal would hide simple control flow.

## Input Rules

- Keyboard and mouse paths should trigger the same underlying method.
- UI click targets must not be stolen by map click-to-move.
- Dragging panels should begin from a header or safe handle region, not from item slots.
- Do not leave permanent hints that conflict with contextual prompts.

## Testing Rules

Add or update tests for:

- Bugs already reported by the player.
- Input routing changes.
- Inventory, equipment, combat, and quest state changes.
- UI behavior that can be asserted without screenshot comparison.

For visual changes:

- Prefer a capture scene when the output is important.
- Keep acceptance criteria in `design/ux/hud-and-prompts.md` or feature specs.

## Implementation Principles

- KISS: smallest implementation that solves the observed problem.
- YAGNI: do not build systems for future classes, zones, or items until the gameplay needs them.
- DRY: shared UI behavior should live in reusable scripts.
- SOLID: keep data systems, scene orchestration, and visual presentation separate.

