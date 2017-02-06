/// scr_ledge_grab_state()

/// Read movement keys

/* 
    This code determines all actions that the player will complete at each 'step'. 
    This includes jumps, moves, pushes, etc.
*/

key_right = keyboard_check(vk_right); // Instantiates action for right keyboard click.
key_left = -keyboard_check(vk_left); // Instantiates action for left keyboard click.
key_jump = keyboard_check_pressed(vk_space);
key_down = keyboard_check(vk_down);

/// Execute movement actions
if (key_jump) {
    speed_vertical = -speed_jump;
    state = scr_move_state;
} else if (key_down != 0) {
    state = scr_move_state;
}
