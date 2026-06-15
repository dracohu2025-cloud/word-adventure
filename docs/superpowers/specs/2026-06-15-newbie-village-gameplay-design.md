# Newbie Village Gameplay Design

Date: 2026-06-15

## Goal

Design the first complete gameplay chapter for Word Adventures: a 20-30 minute beginner village that combines vocabulary learning, RPG exploration, rewards, and a first combat climax.

The village should no longer feel like a single puzzle proof of concept. It should feel like the opening chapter of a sword-and-magic vocabulary RPG.

## Product Direction

The project remains visual-first. Gameplay systems should be introduced with visible in-world context, readable NPC placement, clear icons, and real or generated assets early in the process.

Vocabulary learning is the core. RPG systems are the gamification shell that makes repetition, recall, and review feel like adventure progression.

## Core Premise

The protagonist is a child chosen by a magic book.

The village's magic book has gone out of control. Basic English words have escaped as floating pages, distorted village sentences, and small word monsters. The player must restore three lost book pages, then defeat and capture the Word Imp guarding the forest gate.

## Target Audience And Difficulty

Initial vocabulary difficulty:

- Elementary and junior high school level English words.
- Friendly first-session difficulty.
- No hard failure punishment in the village.

Learning progression:

1. Word meaning recognition.
2. Spelling recall.
3. Contextual sentence completion.
4. Boss encounter that combines all three.

## Chapter Structure

Chosen structure: three village side quests converge into a boss gate.

The player may complete the three branches in any order:

1. Library branch: word meaning recognition.
2. Blacksmith branch: spelling input.
3. Garden or well branch: contextual sentence completion.

Each branch rewards one restored book page. Restoring all three pages unlocks the forest gate encounter.

## Opening Flow

Duration target: 3-5 minutes.

Sequence:

1. Player starts in the village.
2. Mentor or village elder introduces the unstable magic book.
3. Player receives the empty magic book.
4. First nearby interaction teaches proximity markers.
5. A simple word meaning question demonstrates that correct answers restore magic.
6. The forest gate explains the objective: restore three book pages before leaving.

Minimum tutorial mechanics:

- Movement.
- Nearby interaction prompt.
- NPC marker behavior.
- First vocabulary question.
- Book page counter.

## Branch 1: Library

Purpose: teach word meaning recognition.

NPC:

- Librarian or magic book mentor.

Location:

- Small library, book stall, or bookcase area.

Story:

- The first escaped page hides among village books.
- Floating pages show basic English words.

Gameplay:

- The player sees an English word.
- The player chooses the correct meaning from 3-4 options.

Example words:

- `apple`
- `river`
- `forest`
- `shield`
- `light`

Example challenge:

- `forest` -> forest / river / shield / apple.

Rewards:

- `Book Page 1`
- Small amount of coins or vocabulary fragments.
- Magic book "word record" page becomes visible.

## Branch 2: Blacksmith

Purpose: introduce spelling recall.

NPC:

- Blacksmith.

Location:

- Forge, tool stand, or blacksmith corner.

Story:

- The forge inscription has been scrambled.
- The player must restore words to forge their first charm.

Gameplay:

- The player receives a Chinese meaning, image hint, or short prompt.
- The player inputs or assembles the English spelling.

Example words:

- `sword`
- `fire`
- `stone`
- `water`
- `book`

Example challenge:

- `剑` -> `sword`.

Rewards:

- `Book Page 2`
- `Beginner Charm`
- Unlock or introduce `Shield` / `Focus` battle utility.

## Branch 3: Garden Or Well

Purpose: introduce contextual word use.

NPC:

- Villager, gardener, or child.

Location:

- Garden, well, or village road.

Story:

- A word monster has hidden inside villagers' everyday sentences.
- The player repairs the sentences by selecting the correct word.

Gameplay:

- The player sees a simple sentence with a blank.
- The player selects the best English word for the context.

Example words:

- `water`
- `eat`
- `sun`
- `home`
- `friend`

Example challenge:

- `I drink ____.` -> water / sword / tree / book.

Rewards:

- `Book Page 3`
- `Potion`
- Unlock the forest gate training fight.

## Quest Convergence

The village tracks:

- Branch completion states.
- Book page count: `0/3`, `1/3`, `2/3`, `3/3`.
- Forest gate lock state.

Forest gate behavior:

- Before 3 pages: gate remains sealed and says how many pages are missing.
- After 3 pages: gate starts the training fight or boss sequence.
- After boss victory: gate opens toward the forest.

First version does not need a full quest log UI. It may use:

- NPC proximity markers.
- Completed marker disappearance.
- Book page counter.
- Forest gate feedback text.

## Normal Combat

Purpose: make vocabulary answers feel like spells.

Normal combat should be quick. It should teach the relation between answers and battle outcomes without slowing the village flow.

Flow:

1. Battle starts.
2. A vocabulary question appears.
3. Correct answer: player attacks.
4. Incorrect answer: enemy counterattacks.
5. Enemy HP reaches zero: victory and reward.

Normal combat question mix:

- Mostly meaning recognition.
- Some contextual completion.
- No heavy spelling requirement in fast fights.

## Skills

First-version battle skills:

- `Attack`: answer a question to deal damage.
- `Shield`: answer a question to reduce incoming damage this round.
- `Capture`: available only when the enemy is weakened enough.

Do not implement complex MP, talent trees, or class skills in the first village. Use battle phase or simple cooldowns if a limiter is needed.

## Boss: Word Imp

The Word Imp is the first major escaped word monster. It guards the forest gate.

Duration target: 5-7 minutes including dialogue and retry time.

Phases:

1. Weakening phase.
   - Question type: meaning recognition.
   - Goal: reduce boss HP below 60%.
   - Teaches correct answer as attack.
2. Confusion phase.
   - Question type: spelling and context.
   - Boss scrambles words or pollutes simple sentences.
   - Goal: reduce boss HP below 20%.
3. Capture phase.
   - `Capture` becomes available.
   - Player completes a combined challenge.
   - Success captures Word Imp into the magic book.
   - Failure restores a small amount of boss HP and repeats a short combat loop.

Failure handling:

- Player HP reaching zero does not cause a hard game over.
- Player returns to the mentor.
- Completed branches remain completed.
- The player may retry the boss.

Boss rewards:

- `Restored Page: Forest Words`
- Upgrade or activation of `Beginner Charm`
- Forest gate opens.
- Magic book records the first captured word monster.

## Rewards And Progression

First-version rewards:

- Restored book pages.
- Beginner charm.
- Potion.
- Coins or vocabulary fragments.
- Captured Word Imp record.

Minimal stats:

- HP.
- Attack.
- Defense.

Do not implement full equipment rarity, random stats, shop economy, or class progression in this chapter.

## Data Model Direction

Use structured data instead of hardcoding all content in scene files.

Recommended first data groups:

- `words`: word, meaning, example sentence, difficulty, supported challenge types.
- `quests`: id, name, status, goals, rewards, completion conditions.
- `npcs`: id, dialogue, optional quest, challenge pool.
- `enemies`: id, HP, question pools, battle phases, rewards.

The first implementation may use local GDScript dictionaries or JSON resources. The design should keep a later migration to external word lists possible.

## Asset Strategy

Asset priority:

1. Existing CC0 open-source assets already in the project.
2. Additional low-risk open-source assets: CC0, MIT, or CC-BY with attribution.
3. Generated assets via image generation only when open-source assets do not cover a key concept.

Current local open-source asset coverage:

- Kenney Tiny Town: village terrain, houses, roads, trees, fences, signs, props.
- Kenney Tiny Dungeon: simple characters, dungeon props, some monsters, weapons, shields, items.
- Kenney Game Icons: UI icons and interaction markers.

Likely generated asset candidates:

- Magic book.
- Escaped book pages.
- Word Imp.
- Boss variant.
- Capture or restoration effect.

Style rule:

- Village map and ordinary props should stay close to the existing 16x16 Kenney pixel style.
- Key monsters and magic book visuals may use a slightly more expressive 32x32 RPG pixel style if needed.

Every third-party or generated asset must be recorded in the asset credits documentation with source, license or generation notes, local path, and modification notes.

## Implementation Milestones

### Milestone 1: Quest And Page Loop

Goal: make the three-branch structure playable.

Scope:

- Quest status data.
- Book page counter.
- Three NPCs or interactable branch anchors.
- Branch completion rewards.
- Forest gate checks `3/3` pages.

Visual requirements:

- Real or sourced book page icon.
- Clear branch NPCs or interactables.
- Forest gate locked/unlocked feedback.

### Milestone 2: Vocabulary Challenge Types

Goal: each branch has a distinct learning activity.

Scope:

- Meaning recognition.
- Spelling input.
- Contextual completion.
- Structured word data.

Visual requirements:

- Magic book or page-like challenge panel.
- Challenge type icons where useful.

### Milestone 3: Rewards And Equipment Stub

Goal: branch rewards feel like RPG progression.

Scope:

- Beginner charm.
- Potion or coins.
- Initial captured word record.
- Minimal stat model.

Visual requirements:

- Reward popup.
- Item icons from open source or generated assets if necessary.

### Milestone 4: Normal Combat Stub

Goal: one fast fight proves answer-to-action combat.

Scope:

- Player HP and enemy HP.
- `Attack` and `Shield`.
- Correct answer damages enemy.
- Incorrect answer triggers counterattack.

Visual requirements:

- Battle panel.
- Enemy sprite.
- Basic hit/guard feedback.

### Milestone 5: Forest Gate Boss

Goal: deliver the chapter climax.

Scope:

- Word Imp boss.
- Multi-phase question mix.
- `Capture` skill.
- Retry flow.
- Forest gate opens after victory.

Visual requirements:

- Distinct boss sprite.
- Capture/restoration feedback.
- Forest gate open state.

### Milestone 6: Chapter Polish

Goal: make the village feel like one coherent 20-30 minute chapter.

Scope:

- Dialogue polish.
- Guidance text.
- Difficulty tuning.
- Branch order validation.
- Regression tests and visual review.

Visual requirements:

- NPC distinction.
- Branch location readability.
- UI polish.
- BGM/SFX review.

## Out Of Scope For First Village

- Multiple professions or classes.
- Full equipment rarity and random attributes.
- Full shop economy.
- Complex skill tree.
- Large monster roster.
- Multiple maps.
- Full save system.
- Advanced battle animation.

## Testing And Verification

Existing regression tests should remain green:

- Main menu.
- Village visual structure.
- Phase 1 interaction loop.
- Player movement and collision.
- NPC proximity marker.
- Collision blocking.

New tests should be added as systems land:

- Quest state transitions.
- Book page counter.
- Forest gate lock/unlock conditions.
- Each vocabulary challenge type.
- Battle outcome for correct and incorrect answers.
- Boss capture success and retry behavior.

## Acceptance Criteria

The first village chapter is ready for implementation review when:

- The player can understand the magic book premise in-game.
- The player can complete three village branches in any order.
- Each branch uses a distinct vocabulary challenge type.
- Each branch grants a visible reward and one book page.
- The forest gate requires all three pages.
- The player completes at least one normal fight.
- The player defeats and captures the Word Imp boss.
- The forest gate opens after boss victory.
- Visual assets are license-safe or documented generated assets.
- The experience can be played in roughly 20-30 minutes after content tuning.
