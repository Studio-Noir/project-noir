/// scr_ladder_state()

key_up = keyboard_check(vk_up);
key_down = keyboard_check(vk_down);
key_jump = keyboard_check_pressed(vk_space);

if (key_jump) {
    if (place_meeting(x, y+1, obj_ground) || place_meeting(x, y+1, par_block)) {
        speed_vertical = -100;//-speed_jump;//key_jump * -speed_jump; 
        sprite_state = STATE_JUMP;
    }
    ladder = false;
    state = scr_move_state;
}

if (light_or_dark == 1) {
    dir = -1;
} else {
    dir = 1;
}

with (instance_nearest(x, y, par_ladder)) {
    other.x = x + 46 * other.dir;
    other.image_xscale = other.dir;
}

if (ladder) {
    if (key_up && !place_meeting(x, y-1, obj_ground)) { speed_vertical = -5; } 
    if (key_down && !place_meeting(x, y+1, obj_ground)) { speed_vertical = 5; }
    if (!place_meeting(x, y, par_ladder)) { ladder = false; }
    if (key_down && place_meeting(x, y+1, obj_ground)) { state = scr_move_state; }
    if (speed_vertical != 0) {
        sprite_index = spr_char_ladder;
    } else {
        sprite_index = spr_char_ladder_static;
    }
    y += speed_vertical;
    speed_vertical = 0;
    if (!audio_is_playing(snd_vine)) {
    audio_play_sound(snd_vine,0,0)
    }
} else {
    state = scr_move_state;
}
