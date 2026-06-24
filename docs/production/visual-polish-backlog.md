# Visual Polish Backlog

This backlog keeps visual-first work visible and reviewable.

Inspired by the production workflow in [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios), adapted for this project.

## Rules

- Every item should describe what is visually wrong, not only what code should change.
- Prefer screenshots, crop references, or capture scenes.
- Link to asset manifest entries when new assets are needed.
- Mark an item done only after test or visual inspection.

## Backlog

| Priority | Area | Issue | Desired Result | Status |
| --- | --- | --- | --- | --- |
| P1 | Beginner village | Roads should guide movement without looking oversized | Narrow, readable routes to each home and encounter | Open |
| P1 | Combat | Duel overlay must make attacks and damage obvious | Close symmetric combat composition with readable damage | In progress |
| P1 | Beginner village | NPCs should stand near their own homes or task anchors | Each branch NPC has a believable location and connected route | Open |
| P1 | Beginner village | Player should not get stuck near NPCs, roads, or props | Collision and walkable strips match visible paths | Open |
| P2 | Context prompts | Action button must be more visible than shortcut hint | Asset-backed highlighted CTA | Done |
| P2 | Inventory / character | Equipment icons must match item type | Correct weapon, shield, armor, boots, gloves icons | Open |
| P2 | HUD | Panel materials and bars should feel cohesive | Pixel asset-backed HUD with no overlap | Open |
| P2 | Dialogue | Dialogue and puzzle result feedback should feel like NPC speech | Results appear as follow-up NPC dialogue, not detached system text | Open |
| P2 | Settlement | Battle settlement should not stack over battle overlay | Clean single settlement screen with victory / rewards | Open |
| P2 | Asset integrity | Multi-part trees, houses, and props must not render as partial objects | Only complete documented compositions appear in the map | Open |
| P3 | Capture tooling | Visual capture scenes should reliably show target UI state | Capture scripts explicitly set up the visual state under review | Open |

## Done Criteria

- Screenshot or manual review confirms visual target.
- Related interaction tests pass if behavior changed.
- Asset usage is documented if new assets were imported.
