/// scr_push_state()

key_left = -keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
movement = key_left + key_right;
key_jump = keyboard_check_pressed(vk_space);

if (block && (movement != 0) && !key_jump) {
    image_xscale = -movement;
    if (place_meeting(x + (speed_move * movement), y, par_block) && place_meeting(x, y + 20, obj_ground)) {
        speed_horizontal = speed_move / 2 * movement;
        var itm_block = instance_place(x + (speed_move * movement), y, par_block);
        with (itm_block) {
            obj_char.speed_horizontal = scr_block_move(obj_char.speed_horizontal);
        }
    } else {
        block = false;
        speed_horizontal = 0;
    }
    x += speed_horizontal;
    audio_play_sound(snd_pushing,0,0)
} else {
    state = scr_move_state;
}
