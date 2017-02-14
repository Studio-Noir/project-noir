/// scr_ladder_state()

key_up = keyboard_check(vk_up);
key_down = keyboard_check(vk_down);
key_jump = keyboard_check_pressed(vk_space);

if (key_jump) {
    if (place_meeting(x, y+1, obj_ground) || place_meeting(x, y+1, par_block)) {
        speed_vertical = key_jump * -speed_jump; 
        sprite_state = STATE_JUMP;
    }
    ladder = false;
    statte = scr_move_state;
    audio_play_sound(snd_vine,0,0)
}

if (ladder) {
    if (key_up && !place_meeting(x, y-1, obj_ground)) { speed_vertical = -5; } 
    if (key_down && !place_meeting(x, y+1, obj_ground)) { speed_vertical = 5; }
    if (!place_meeting(x, y, par_ladder)) { ladder = false; }
    if (key_down && place_meeting(x, y+1, obj_ground)) { state = scr_move_state; }
    y += speed_vertical;
    speed_vertical = 0;
} else {
    state = scr_move_state;
}
