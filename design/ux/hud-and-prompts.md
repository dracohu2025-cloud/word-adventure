# HUD And Prompt Guidelines

This document defines player-facing UI rules for `word-adventures`.

Inspired by the UX workflow in [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios), adapted for this project.

## Language

- Default UI language: Chinese.
- English appears only for vocabulary learning, spelling, item names when intentionally English, or bilingual learning moments.
- Instructions should be short and concrete.

## HUD

HUD should show persistent player state only.

Allowed persistent HUD data:

- Level.
- HP / MP.
- Gold.
- Book pages or core quest progress.
- Short temporary reward notifications if they expire quickly.

Avoid:

- Permanent tutorial hints at the bottom of the screen.
- Status text that overlaps HP / MP bars.
- Icons that do not match the value they represent.

## Contextual Prompts

Prompts should appear near the object being interacted with.

Rules:

- Show prompt only when the player is in interaction range.
- Left side: shortcut hint, such as `空格/E`.
- Right side: highlighted action button, such as `交谈` or `挑战`.
- The action button must have stronger visual contrast than the shortcut hint.
- Mouse click on the action button must trigger the same action as keyboard interaction.
- Do not show the old exclamation marker at the same time as the contextual prompt; one clear signal is better than two competing signals.

## Dialogue

Dialogue should make speaker identity obvious.

Rules:

- Bubble or panel should appear near the NPC when possible.
- Speaker name should be visible.
- Puzzle result should return through the NPC's next dialogue line, not as isolated system text.
- Continue buttons must not cover dialogue text.

## Inventory And Character Panels

Rules:

- Panels can be opened together through one shortcut.
- Panels can be dragged by their header area.
- Selected filters should be visually brighter than inactive filters.
- Tooltips should show item name, rarity, slot, stats, and right-click action.
- Equipment icons must visually match their item type.

## Combat UI

Rules:

- Combat focus overlay should replace map-level ambiguity with a clear duel view.
- Player label should be `你`.
- Enemy label should use the enemy name.
- Names should appear above avatars.
- HP bars should not cover avatars.
- Damage numbers should appear on the damaged target.
- Settlement panel should replace battle UI, not stack inside it.

## Visual QA Checklist

- Text stays inside panels and buttons.
- CTA state is obvious at rest, hover, and press.
- Mouse and keyboard actions are equivalent.
- Panels do not block critical scene information unless modal.
- UI uses pixel assets rather than default engine styling.
