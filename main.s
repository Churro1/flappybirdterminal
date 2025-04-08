.global _start  // Define the entry point of the program

// ==========================
//  SECTION: Read-Write Data
// ==========================
.section .data  
// This section stores **fixed values** that we know in advance.
gravity:       .double  0.2       // Gravity value affecting the bird
jump_force:    .double -1.5       // Upward force applied when jumping
pipe_speed:    .double  0.5       // Speed at which pipes move left
pipe_gap:      .word    6         // Vertical gap between pipes
screen_width:  .word    40        // Width of the terminal screen
screen_height: .word    20        // Height of the terminal screen

    // Bird Properties
bird_x:        .word    5         // X position of the bird (fixed)
bird_y:        .word    10        // Y position of the bird (updates)
bird_velocity: .double  0.0       // Vertical velocity of the bird

    // Pipe Data
pipe_positions: .space  40        // Space for pipe X positions
pipe_gap_pos:   .word   8         // Y position of the gap in the pipe

    // Game State Variables
score:         .word    0         // Player’s score
game_over:     .word    0         // 0 = Running, 1 = Game Over

// ==========================
// SECTION: Read-Only Data
// ==========================
.section .rodata  
// This section stores **read-only constants and messages**.

game_over_msg: .asciz "Game Over!\n"     // Message printed when the game ends
clear_screen:  .asciz "\033[H\033[J"     // ANSI escape code to clear terminal
bird_char:     .asciz "@"                // Character representing the bird
pipe_char:     .asciz "|"                // Character representing the pipes
ground_char:   .asciz "="                // Character for the ground line
score_msg:     .asciz "Score: "          // Score label displayed on the screen
newline:       .asciz "\n"               // Newline for formatting output

// ==========================
//  SECTION: Uninitialized Data (BSS)
// ==========================
.section .bss  
// This section reserves space for **variables that change over time**.

.lcomm pipe_positions, 40   // Space for pipe positions
.lcomm bird_velocity, 8     // Space for bird's velocity (double precision)
.lcomm bird_y, 4           // Bird's Y position (integer)
.lcomm score, 4            // Player's score
.lcomm game_state, 4       // Stores game state (0 = running, 1 = game over)

// ==========================
//  SECTION: Executable Code
// ==========================
.section .text  
.global _start

// ---- MAIN ENTRY POINT ----
_start:
// This is where the program execution begins.

    // Clear the screen before starting
    ldr x0, =clear_screen  // Load the address of the clear screen escape sequence
    bl print_string        // Call function to print it

    // Initialize game variables
    // Set up the bird's initial position
    ldr x0, =bird_y        // Load address of bird_y variable
    mov w1, #10            // Set initial Y position (adjust as needed)
    str w1, [x0]           // Store initial value in memory

    // Initialize bird velocity
    ldr x0, =bird_velocity
    mov x1, #0             // Start with zero velocity
    str x1, [x0]

    // Initialize pipes (example: set default positions)
    ldr x0, =pipe_positions
    mov w1, #20            // Example: First pipe at X = 20
    str w1, [x0]
    mov w1, #40            // Second pipe at X = 40
    str w1, [x0, #4]       // Store at next position

    // Initialize score
    ldr x0, =score
    mov w1, #0
    str w1, [x0]

    // Set game state to running
    ldr x0, =game_state
    mov w1, #0  // 0 = Running, 1 = Game Over
    str w1, [x0]

    // Print the starting screen
    bl draw_game  // Function to render the game frame

    // Start the main game loop
    bl game_loop  

// ==========================
//  HELPER FUNCTIONS
// ==========================

// Function: print_string
// Prints a null-terminated string (address in X0)
print_string:
    mov x1, x0             // Move string address to X1
    mov x0, #1             // File descriptor (1 = stdout)
    mov x2, #100           // Max length (ensures string prints correctly)
    mov x8, #64            // syscall: write
    svc #0                 // Make system call
    ret                    // Return

// ==========================
//  Function: draw_game
//  Renders the game frame with bird, pipes, and score.
// ==========================
draw_game:
    // Clear the screen
    ldr x0, =clear_screen  // Load the address of the clear screen escape sequence
    bl print_string        // Call function to print it

    // Print the bird
    ldr x0, =bird_y        // Load bird's Y position
    ldr w1, [x0]           // Get Y position value
    mov w2, #10            // Bird's fixed X position (column in terminal)
    bl draw_bird           // Call function to draw bird at (w1, w2)

    // Print the pipes
    ldr x0, =pipe_positions  // Load address of pipe positions array
    mov w1, #0               // Counter for pipe index

draw_pipes_loop:
    ldr w2, [x0, w1, SXTW #2]  // Load pipe X position (scaled by 4 bytes per entry)
    bl draw_pipe              // Draw pipe at X = w2
    add w1, w1, #1            // Move to the next pipe
    cmp w1, #5                // Limit: adjust based on number of pipes
    blt draw_pipes_loop       // Loop until all pipes are drawn

    // Print the score
    ldr x0, =score      // Load score variable
    ldr w1, [x0]        // Get current score value
    bl print_score      // Call function to print score

    ret                 // Return from draw_game

// ==========================
//  Function: draw_bird
//  Draws the bird at (w1 = Y position, w2 = X position).
// ==========================
draw_bird:
    // Save registers to stack (preserve values)
    stp x1, x2, [sp, #-16]!  
    stp x0, x30, [sp, #-16]!

    // Move cursor to (Y, X)
    mov x0, w1              // Y position (row)
    mov x1, w2              // X position (column)
    bl move_cursor          // Call function to move cursor

    // Print the bird ("O")
    ldr x0, =bird_char    // Load address of "O"
    bl print_string         // Print "O" at the cursor position

    // Restore registers
    ldp x0, x30, [sp], #16  
    ldp x1, x2, [sp], #16  
    ret                     // Return from draw_bird

// ==========================
//  Function: draw_pipe
//  Draws a pipe at X = w2.
//  - The pipe is vertical and spans the height of the terminal.
//  - A gap is left for the bird to pass through.
// ==========================
draw_pipe:
    // Save registers to stack
    stp x0, x1, [sp, #-16]!  
    stp x2, x30, [sp, #-16]!

    // Load pipe gap position
    ldr x0, =pipe_gap_pos    // Load the stored Y position of the gap
    ldr w0, [x0]             // w0 = Y position of the gap

    // Set loop counter for screen height
    mov w1, #0               // Start from row 0
    mov w3, #24              // Terminal height (adjust based on screen size)

draw_pipe_loop:
    cmp w1, w3              // If w1 >= screen height, exit loop
    bge draw_pipe_done

    cmp w1, w0              // Check if at the gap position
    blt print_pipe          // If below gap, draw pipe
    cmp w1, w0              // If at or above the gap + gap size, continue drawing
    add w4, w0, #5          // Assume gap size of 5 rows
    cmp w1, w4
    bge print_pipe

    b skip_pipe             // Otherwise, skip drawing the pipe here

print_pipe:
    mov x0, w1              // Y position (current row)
    mov x1, w2              // X position (column where pipe is drawn)
    bl move_cursor          // Move cursor to (Y, X)

    ldr x0, =pipe_char    // Load "|" character
    bl print_string         // Print pipe segment

skip_pipe:
    add w1, w1, #1          // Increment row index
    b draw_pipe_loop

draw_pipe_done:
    // Restore registers
    ldp x0, x30, [sp], #16  
    ldp x1, x2, [sp], #16  
    ret

// ==========================
// Function: print_score
// Prints the current score.
// ==========================
print_score:
    ldr x0, =score_msg        // Load score label
    bl print_string           // Print score label
    ldr x0, =score            // Load the score variable
    ldr w1, [x0]              // Load the score value
    mov x0, w1                // Convert score to string and print
    bl print_string           // Print score value
    ret
