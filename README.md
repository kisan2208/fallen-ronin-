# Fallen Ronin

A stylized 2.5D action-adventure game built with **Godot 4**. *Fallen
Ronin* takes inspiration from the readable side-scrolling exploration
and approachable 3D presentation of games such as **Swordigo**, with a
samurai fantasy setting, sword combat, magic projectiles, enemies,
bosses, and multiple biomes.

> **Development status:** In active development. Core player combat and
> enemy systems are being built and tested; the first biome and broader
> progression systems are still in progress.

## Table of Contents

-   [Project Overview](#project-overview)
-   [Vision and Design Goals](#vision-and-design-goals)
-   [Technology and Target Platforms](#technology-and-target-platforms)
-   [Gameplay](#gameplay)
-   [Implemented Systems](#implemented-systems)
-   [Current Development Progress](#current-development-progress)
-   [World and Biomes](#world-and-biomes)
-   [Controls](#controls)
-   [Project Structure](#project-structure)
-   [Running the Project](#running-the-project)
-   [Roadmap](#roadmap)
-   [Development Notes](#development-notes)
-   [Contributing](#contributing)
-   [License](#license)

## Project Overview

**Fallen Ronin** is a 2.5D samurai action-adventure focused on
platforming, sword combat, magical attacks, enemy encounters, and
exploration. The game uses 3D models and environments while presenting
the world from a side-on camera angle.

The project is being developed with a small-project and mobile-friendly
mindset: stylized low-poly models, readable silhouettes, reusable
environment pieces, and performance-conscious effects.

### Core pillars

-   **Responsive platforming:** move, jump, and navigate platforms.
-   **Action combat:** use a katana and time attacks against enemies.
-   **Magic:** cast a fireball projectile as a ranged option.
-   **Exploration:** travel through themed biomes and discover
    progression items.
-   **Boss encounters:** defeat biome bosses to unlock the next stage of
    the journey.
-   **Stylized 3D presentation:** low-poly, hand-painted-inspired
    visuals with a 2.5D camera.

## Vision and Design Goals

-   **Perspective:** 2.5D side-scrolling gameplay using 3D assets.
-   **Visual direction:** stylized, low-poly fantasy art inspired by
    Swordigo's readable environments and character scale.
-   **Performance:** keep models, effects, and scenes suitable for
    modest PC hardware, with Android as a later target.
-   **Gameplay scope:** a focused action-adventure rather than a massive
    open-world game.
-   **Combat scope:** sword attacks and magic, with platforming as a
    central part of traversal.

## Technology and Target Platforms

  -----------------------------------------------------------------------
  Area                                Current choice
  ----------------------------------- -----------------------------------
  Engine                              Godot 4.x

  Main language                       GDScript

  Character/environment assets        3D models; GLB assets are used in
                                      the workflow

  Camera                              2.5D side-on follow camera

  Initial target                      PC

  Future target                       Android

  Art direction                       Stylized low-poly, mobile-friendly
                                      3D
  -----------------------------------------------------------------------

The project has been worked on with Godot 4.1 in the development
workflow. The exact engine version should be confirmed in the project
before a release.

## Gameplay

### Player abilities

-   Horizontal movement.
-   Jumping.
-   Double jump / long-jump traversal work has been explored; final
    tuning may change during development.
-   Katana attack with a dedicated hit area.
-   Fireball casting with a projectile scene and cooldown.
-   Health and death handling.
-   Direction/facing updates for side-on combat.

### Combat approach

The current combat foundation is intentionally straightforward:

1.  Position the player to face an enemy.
2.  Use the sword attack at close range.
3.  Cast a fireball to attack from a distance.
4.  Avoid enemy contact and improve movement/positioning during
    encounters.

**Design exclusions currently agreed:** no air attack, no sword
dash/Sacred Dash, no ladder traversal, and no sprint mechanic. Combat is
not intended to become a complex Souls-like system.

## Implemented Systems

The following systems have been implemented or prototyped in the
project. Some may still need testing, balancing, and cleanup.

### Player controller

-   `CharacterBody3D`-based movement.
-   Horizontal movement and facing direction.
-   Gravity and ground jumping.
-   Animation selection for idle, movement, jumping, sword attack,
    fireball casting, and death.
-   Player health tracking and death handling.

### Sword combat

-   A `SwordArea` / `Area3D`-style hit area.
-   Attack state handling to prevent overlapping attacks.
-   Hit-target tracking to reduce repeated damage during one swing.
-   Calls enemy damage methods when a valid target is hit.

### Magic projectile

-   Fireball scene based on `Area3D`.
-   Projectile direction and speed.
-   Damage value and caster reference.
-   Collision handling that ignores the caster.
-   Projectile lifetime/cleanup.
-   Casting cooldown and animation timing.

### Enemy foundation

-   Enemy movement and basic patrol/chase/attack behaviour have been
    developed in earlier iterations.
-   Damage handling, knockback, hurt/death animations, and health logic
    have been prototyped.
-   A slime enemy has been used while testing combat and animation
    behaviour.

### Camera

-   A follow-camera setup has been developed for the 2.5D view.
-   Smooth following and look-ahead behaviour have been explored.
-   Camera stability during player facing-direction changes is an
    important testing point.

### Assets and animation workflow

-   3D character and enemy models are imported as GLB assets.
-   AnimationPlayer is used to control character animations.
-   Animation speed and timing have been adjusted individually for
    actions such as attacks and fireball casting.
-   Environment work is focused on reusable platform tiles and modular
    props.

## Current Development Progress

This table records the known project status; it is not a claim that
every feature is release-ready.

  -----------------------------------------------------------------------
  System / area           Status                  Notes
  ----------------------- ----------------------- -----------------------
  Godot project and 2.5D  In place                Godot 4.x with a
  direction                                       side-on camera

  Player movement and     Implemented / testing   Continue tuning feel
  jumping                                         and collision behaviour

  Player animation        Implemented / testing   Idle, movement, jump,
  playback                                        attack, cast, and death
                                                  states

  Sword attack and hit    Implemented / testing   Verify hitbox timing
  detection                                       and damage consistency

  Fireball magic          Implemented / testing   Projectile, collision
                                                  damage, and cooldown

  Player health and death Prototyped              Needs playtesting and
                                                  UI integration

  Basic enemy AI and      Prototyped              Patrol/chase/attack and
  damage                                          damage behaviour have
                                                  been developed

  Camera follow           Prototyped              Continue checking
                                                  smoothness and rotation
                                                  behaviour

  Slime enemy             In progress             Animation, ground
                                                  collision, and enemy
                                                  behaviour need
                                                  validation

  Biome 1 --- Sakura      In progress             Main environment
  Forest                                          direction and modular
                                                  tiles

  Environment props       In progress             Platforms, houses,
                                                  chests, and decorative
                                                  details

  First boss              Planned / in progress   Encounter design and
                                                  implementation remain
                                                  to be completed

  Four biome fragments    Planned                 One fragment per main
  and progression                                 biome

  Biomes 2--4             Planned                 Content and encounters
                                                  remain to be built

  Biome 5 / final boss    Planned                 Intended to unlock
  area                                            after the four
                                                  fragments are collected

  Inventory and equipment Not implemented yet     Future system

  Save/load system        Not implemented yet     Future system

  Shops, quests, and      Not implemented yet     Future systems
  skill tree                                      

  Android optimization    Future work             PC is the initial
  and release                                     target
  -----------------------------------------------------------------------

## World and Biomes

The planned world has **five biomes**:

-   **Biomes 1--4:** each contains a boss and one fragment required for
    progression.
-   **Biome 5:** the final area, intended to become available after the
    player clears the four main biomes, defeats their bosses, and
    collects all four fragments.

### Biome 1 --- Sakura Forest

The first biome is being developed as the initial environment milestone.
Its intended visual language includes stylized forest platforms, trees,
rocks, terrain pieces, and detailed props such as houses and chests.
Reusable modular pieces should make it easier to build levels without
creating every object from scratch.

The exact names, layouts, enemies, and boss details for the remaining
biomes can be documented here as they are finalized.

## Controls

Controls may change as the input map and UI are finalized. Configure
actions in **Project → Project Settings → Input Map**.

  -----------------------------------------------------------------------
  Action                              Intended input
  ----------------------------------- -----------------------------------
  Move left / right                   Keyboard directional keys or
                                      configured movement actions

  Jump                                Configured `jump` action

  Sword attack                        Configured `attack` action

  Cast magic                          Configured `magic` action
  -----------------------------------------------------------------------

For an Android build, add and test on-screen touch controls before
treating mobile controls as complete.

## Project Structure

The exact folder names may differ in the current repository. A useful
organization for the project is:

``` text
Fallen-Ronin/
├── project.godot
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── projectiles/
│   ├── levels/
│   └── ui/
├── scripts/
│   ├── player/
│   ├── enemies/
│   └── systems/
├── assets/
│   ├── characters/
│   ├── environments/
│   ├── materials/
│   ├── animations/
│   └── audio/
└── README.md
```

This is a suggested structure, not a verified listing of the repository.
Keep the README aligned with the actual folders as the project evolves.

## Running the Project

1.  Install a compatible **Godot 4.x** version.
2.  Clone or download this repository.
3.  Open Godot's Project Manager.
4.  Select **Import** and choose the project's `project.godot` file.
5.  Open the project, select the main scene, and press **F6** to run the
    current scene or **F5** to run the configured main scene.

If the project does not launch, check that imported GLB assets and
referenced scenes are present, and review the Output panel for missing
resources or script errors.

## Roadmap

### Phase 1 --- Core gameplay

-   [x] Establish the Godot project and 2.5D direction.
-   [x] Build the first version of player movement and jumping.
-   [x] Add sword attack and hit detection.
-   [x] Add a fireball projectile and casting cooldown.
-   [ ] Stabilize combat timing, enemy damage, and animation
    transitions.
-   [ ] Finish player/enemy collision and ground-contact testing.

### Phase 2 --- First playable level

-   [ ] Finish the Sakura Forest greybox and platform layout.
-   [ ] Create and place reusable terrain tiles and environment props.
-   [ ] Add enemy encounters and checkpoints.
-   [ ] Implement and test the first boss.
-   [ ] Playtest the complete first-biome route.

### Phase 3 --- Progression and content

-   [ ] Build biomes 2, 3, and 4.
-   [ ] Implement the four fragments and progression gates.
-   [ ] Unlock the fifth biome after the four fragments are collected.
-   [ ] Build the final boss encounter.
-   [ ] Add save/load and other progression systems.

### Phase 4 --- Polish and release preparation

-   [ ] Add sound effects, music, and combat feedback.
-   [ ] Improve UI for health, magic, and progression.
-   [ ] Profile performance and reduce unnecessary scene complexity.
-   [ ] Test controller/keyboard usability.
-   [ ] Add Android touch controls and optimize for mobile.
-   [ ] Prepare a playable release build.

## Development Notes

-   Prefer reusable modular environment pieces over unique meshes for
    every platform.
-   Keep collision shapes simple and verify that characters and enemies
    remain grounded.
-   Test attack hitboxes independently from visual animation timing.
-   Use animation-specific speed settings when only one animation needs
    retiming.
-   Test performance in the actual game scene, not only in an empty test
    scene.
-   Keep large source assets and generated/imported files organized;
    review the repository before committing to avoid uploading
    unnecessary build files.

## Contributing

This is an evolving game project. If you want to contribute:

1.  Describe the issue or feature clearly.
2.  Keep changes focused and compatible with the current Godot 4.x
    project.
3.  Test affected scenes before submitting changes.
4.  Include screenshots or short recordings for visual/gameplay changes
    when useful.

## License

**License not yet specified.** Add a `LICENSE` file before inviting
reuse or redistribution. Until a license is added, do not assume that
the project is open for unrestricted copying, modification, or
redistribution.

------------------------------------------------------------------------

*README status: written from the project's documented design decisions
and development history. Update the progress table as features are
tested and completed.*
