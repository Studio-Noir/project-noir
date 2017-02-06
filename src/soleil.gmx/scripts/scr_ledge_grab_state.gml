/// scr_ledge_grab_state()

/// Read movement keys

/* 
    This code determines all actions that the player will complete at each 'step'. 
    This includes jumps, moves, pushes, etc.
*/

key_right = keyboard_check(vk_right); // Instantiates action for right keyboard click.
key_left = -keyboard_check(vk_left); // Instantiates action for left keyboard click.
key_up = keyboard_check(vk_up);
key_jump = keyboard_check_pressed(vk_space);
key_down = keyboard_check(vk_down);

/// Execute movement actions
if (key_jump) {
    speed_vertical = -speed_jump;
    state = scr_move_state;
} else if (key_down != 0) {
    state = scr_move_state;
} else if (key_up != 0) {
    speed_ledge = -5;
}

/// If Soleil is past the ledge, resume walking
if (!place_meeting(x + (10 * direction_horizontal), y, obj_ground)) {
    x = x + 30;
    state = scr_move_state;
}


y = y + speed_ledge;
if (speed_ledge != 0) {
    sprite_index = spr_char_ledge;
} else {
    sprite_index = spr_char_ledge_static;
}
