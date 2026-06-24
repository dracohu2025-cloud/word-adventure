# Playtest Notes

Use this file to turn player feedback into actionable work.

Inspired by the playtest/report workflow in [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios), adapted for this project.

## Session Template

### Date

YYYY-MM-DD

### Build / Branch

Local Godot run / branch / commit if available.

### Scenario

What the player was trying to do.

### Observation

What the player saw or felt.

### Expected

What the player expected instead.

### Category

- Visual polish
- Interaction
- Combat
- Learning content
- Quest flow
- Performance
- Audio

### Severity

- P0: blocks progress or crashes.
- P1: major experience problem.
- P2: noticeable polish issue.
- P3: minor cleanup.

### Next Action

One concrete change or investigation.

## Running Notes

| Date | Scenario | Observation | Category | Severity | Next Action |
| --- | --- | --- | --- | --- | --- |
| 2026-06-21 | NPC interaction prompt | Action button was not visually distinct enough | Visual polish | P2 | Use a stronger asset-backed CTA for action area |
| 2026-06-21 | Equipment / inventory | Separate character and bag shortcuts add unnecessary friction | Interaction | P2 | Use one shortcut to open both panels together |
| 2026-06-21 | Equipment / inventory | Character and bag panels need flexible positioning | Interaction | P2 | Allow dragging panels from header areas |
| 2026-06-20 | Beginner village | Some roads feel too wide for guided movement | Visual polish | P1 | Redesign road widths around one-character passability and clear branch routes |
| 2026-06-20 | Beginner village | NPCs and props can overlap or feel detached from homes | Visual polish | P1 | Anchor each NPC near a believable home or task prop |
| 2026-06-20 | Combat | Battle was hard to read on the map alone | Combat | P1 | Use a focused duel overlay with larger avatars and damage text |
| 2026-06-20 | Combat settlement | Settlement panel nested over battle overlay looked messy | Visual polish | P2 | Replace battle overlay with settlement screen after combat ends |
| 2026-06-20 | HUD | HP / MP bars and temporary reward text could overlap | Visual polish | P2 | Keep HUD persistent state clean; temporary notices should expire or use separate placement |
