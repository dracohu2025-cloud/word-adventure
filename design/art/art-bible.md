# Word Adventures Art Bible

This document is the visual source of truth for `word-adventures`.

Inspired by the workflow structure of [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios), adapted for this project.

## Visual Priority

This game is visual-first. A feature is not considered ready for player review if it works mechanically but looks unfinished.

For every visible feature:

- Use real pixel assets where available.
- Prefer coherent asset families over mixed styles.
- Avoid placeholder rectangles except in internal-only tests.
- Capture or manually inspect the screen after layout changes.
- Keep text readable for Chinese-speaking students.

## Core Style

- Genre: sword-and-magic beginner RPG.
- Camera: 2D top-down village and field exploration.
- Tone: warm, readable, adventurous, not dark or grim.
- Pixel density: preserve crisp pixel edges; avoid blurry scaling.
- Primary scene mood: cozy village that gradually opens into danger.

## Asset Family Rules

### Tiny Swords

Tiny Swords is the current primary visual family.

Use it for:

- Player character and enemies.
- Village buildings.
- Props and environmental decorations.
- HUD panels, buttons, icons, and combat UI when suitable.

Rules:

- Do not mix Tiny Swords with another asset family inside one tightly grouped object unless the mismatch is intentional and reviewed.
- Use complete objects, not partial slices.
- When a sprite sheet contains animation frames, document which frame range is used.

### Kenney / LPC / Other Open Assets

Use when Tiny Swords cannot cover a need or the alternative is clearly better.

Rules:

- Verify license before import.
- Document source and usage in `design/assets/asset-manifest.md`.
- Avoid mixing different outline thicknesses or camera perspectives in the same focal area.

## UI Direction

UI should feel like a polished pixel RPG, not a web form.

Use:

- Asset-backed panels and buttons.
- High-contrast CTA states.
- Compact prompts near the object being interacted with.
- Chinese labels for game actions.
- English only for vocabulary, spelling, or direct word choices.

Avoid:

- Default Godot button appearance.
- Large permanent bottom hints that waste map space.
- Text that touches or crosses panel borders.
- Two unrelated modal panels stacked on top of each other.

## Village Composition

The beginner village should communicate paths and affordances visually.

Rules:

- NPCs should stand near their own home or task location.
- Roads should connect doors, NPCs, boss gates, and learning objectives.
- Roads should be narrow enough to guide movement.
- Decorations must not block or visually overlap interaction-critical objects.
- Exclamation indicators should appear only when the player is close enough to interact.

## Combat Composition

Combat should be readable at a glance.

Rules:

- Player and enemy should be close enough in the combat focus overlay to imply contact.
- Names should sit above avatars.
- Health bars should not cover avatars.
- Damage numbers should appear near the target taking damage.
- Combat settlement should replace the battle focus UI instead of nesting inside it.

## Review Checklist

Before asking for visual review:

- The screen uses approved assets.
- CTA buttons are visually distinguishable.
- Chinese text fits inside its panel.
- No important text overlaps buttons or icons.
- No character appears stuck inside props.
- Screenshot or capture scene exists when the change is visual.

