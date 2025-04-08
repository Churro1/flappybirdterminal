# Flappy Bird in Assembly

## Title and Project Track
**Track:** Self-Proposed Project

## Project Description
This project aims to recreate the classic *Flappy Bird* game in assembly language, running entirely in the terminal using ASCII characters. The game will feature:

- A player-controlled bird that moves up when a key is pressed and falls due to gravity.
- Procedurally generated obstacles (pipes) that the player must navigate through.
- Collision detection between the bird and pipes or the ground.
- A scoring system that increments as the bird successfully passes through pipes.
- A simple game loop that handles input, updates game logic, and renders the output in the terminal.

### Motivation
I have previously programmed the game *Snake* multiple times and want to challenge myself with a different game. Writing *Flappy Bird* in assembly will deepen my understanding of low-level programming concepts, such as direct memory manipulation, CPU registers, and efficient control flow management.

## Tools and Platforms
- **Assembly Language** (ARM64) for Raspberry Pi 3B
- **Raspberry Pi 3B** running a **64-bit OS**
- **Visual Studio Code** for assembling code and basic testing away from home. 
- **Terminal-based ASCII rendering**
- Potential use of **minimal C libraries** for system interaction (e.g., input handling)

## Timeline and Milestones
| Week | Milestone |
|------|-----------|
| Week 1 | Set up development environment, test basic assembly programs. Implement basic bird physics (gravity, jumping mechanics) |
| Week 2 | Create pipe generation and movement system. Implement collision detection and scoring system |
| Week 3 | Playtesting, debugging, and final refinements |

### Contingency Plan
- If rendering in the terminal proves too complex, I will simplify the graphics further.
- If full collision detection is difficult to implement, I will use a simpler hitbox system.
- If input handling in pure assembly is too cumbersome, I may incorporate small C functions.

## Course Concepts Applied
This project directly relates to the following course topics:
- **Assembly Language:** Due to the nature of the project.
- **Memory Layout & Stack Management:** Efficient use of registers and stack for game state storage.
- **Control Flow & Loops:** Implementing game loops, conditional jumps, and function calls efficiently.
- **I/O Handling:** Managing real-time input from the user within the constraints of assembly.



This is to test.