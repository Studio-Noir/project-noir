/// scr_ladder_state()

key_up = keyboard_check(vk_up);
key_down = keyboard_check(vk_down);
key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);

key_jump = keyboard_check_pressed(vk_space);

//Camera action

//Orb Mechanics still function on ledge
key_orb1_prev = key_orb1;
key_orb2_prev = key_orb2;
key_orb1 = keyboard_check(ord('Z')) or keyboard_check(ord('H')) or keyboard_check_pressed(ord('1'));
key_orb2 = keyboard_check(ord('X')) or keyboard_check(ord('J')) or keyboard_check_pressed(ord('2'));

//Movement
movement = keyboard_check(vk_right) - keyboard_check(vk_left);

//Decrement orb cooldown if still in effect
if(orb_cooldown > 0){
    orb_cooldown--;
}

/// Setup dropping orb 
if(orb_cooldown <= 0){
    if (key_orb1 and !key_orb1_prev) {
        if (global.ORBCOUNT_CURRENT > 0) {
            global.ORBCOUNT_CURRENT--;
            orb_cooldown = orb_cooldown_max;
            //Action should only work with sufficient orbs.
            //Drop orb in place, thrown down with velocity
            var inst = instance_create(x, y - sprite_height/2, obj_orb);
            inst.direction = 270;
            inst.speed = 15;
            inst.orb_value = 1;
            audio_play_sound(snd_lightorb,0,0); // THIS ONE WORKS FINE.
        }
    }
    if (!key_orb2 and key_orb2_prev) {
        //Action should only work with sufficient orbs.
        if (global.ORBCOUNT_CURRENT > 0) {
            global.ORBCOUNT_CURRENT --;
            orb_cooldown = orb_cooldown_max;
            //Calculate direction of throw: 30 degree angle upwards from the ground
            if(lob_power > 5){
                lob_direction = direction;
                if(image_xscale > 0){
                    lob_direction = 150;
                }else{
                    lob_direction = 30;
                }
            }else{
                lob_direction = 270;
                lob_power = 15;
            }
            //Lob orb forwards at calculated angle
            var inst;
            inst = instance_create(x, y - sprite_height/2, obj_orb);
            inst.speed = lob_power;
            inst.direction = lob_direction;
            inst.orb_value = 1;
            audio_play_sound(snd_lightorb,0,0); // THIS ONE WORKS FINE.
        }    
    }
    else if (key_orb2) {
        //Action should only work with sufficient orbs.
        if (global.ORBCOUNT_CURRENT > 0) {
            if(lob_power < lob_power_max){
                lob_power += 0.5;
            }
        }    
    }
    else
    {
        lob_power = 0;
    }
}

if (key_jump && movement != 0) {     
    speed_vertical = -13;//-speed_jump;//key_jump * -speed_jump; 
    speed_horizontal = movement * 10;
    sprite_state = STATE_JUMP;
    ladder = false;
    state = scr_move_state;
} else if (movement != 0 && place_meeting(x, y + 50, obj_ground)) {
    speed_horizontal = movement * 10;
    sprite_state = STATE_WALK;
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
    if (key_up && !place_meeting(x, y-1, obj_ground) && !place_meeting(x,y-10,obj_inv_blc)){ speed_vertical = -5; } 
    if (key_down && !place_meeting(x, y+1, obj_ground)) { speed_vertical = 5; }
    if (!place_meeting(x, y, par_ladder)) { ladder = false; }
    if (key_down && place_meeting(x, y+1, obj_ground)) { state = scr_move_state; }
    if (speed_vertical != 0) {
        if (global.bear_present) {
            sprite_index = spr_char_ladder;
        } else {
            sprite_index = spr_char_ladder_nobear;
        }
    } else {
        if (global.bear_present) {
            sprite_index = spr_char_ladder_static;
        } else {
            sprite_index = spr_char_ladder_static_nobear;
        }
    }
    audio_stop_sound(snd_walking);
    if (!audio_is_playing(snd_vine) && (speed_vertical != 0)) {
        audio_play_sound(snd_vine,0,0)
    } else if (speed_vertical == 0) {
        audio_stop_sound(snd_vine);
    }
    y += speed_vertical;
    speed_vertical = 0;
} else {
    state = scr_move_state;
}
