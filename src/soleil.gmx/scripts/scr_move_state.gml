/// scr_move_state()

if (keyboard_check(ord('A'))) {
    game_restart();
} else if (keyboard_check(ord('P'))) { // artificially simulate grabbing ledge. Used for debugging.
    state = scr_ledge_grab_state;
    exit;
}

/// Read movement keys

/* 
    This code determines all actions that the player will complete at each 'step'. 
    This includes jumps, moves, pushes, etc.
*/

key_right = keyboard_check(vk_right); // Instantiates action for right keyboard click.
key_left = -keyboard_check(vk_left); // Instantiates action for left keyboard click.
key_jump = keyboard_check_pressed(vk_space);
key_up = keyboard_check_direct(vk_up);
key_down = keyboard_check_direct(vk_down);
key_orb1_prev = key_orb1;
key_orb2_prev = key_orb2;
key_orb1 = keyboard_check(ord('Z')) or keyboard_check(ord('H')) or keyboard_check_pressed(ord('1'));
key_orb2 = keyboard_check(ord('X')) or keyboard_check(ord('J')) or keyboard_check_pressed(ord('2'));

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

/// Execute movement actions

/*
    This code responds to the inputs pressed.
*/

move = key_left + key_right;
speed_horizontal = move * speed_move;

if (speed_vertical < 10) { // Vertical speed affected by gravity; limited to 10 downwards.
    speed_vertical += physics_gravity;
    sprite_state = STATE_JUMP;
} 
if (place_meeting(x, y+1, obj_ground) || place_meeting(x, y+1, par_block)) {
    speed_vertical = key_jump * -speed_jump; 
    sprite_state = STATE_JUMP;
}

if (speed_horizontal != 0) {
    direction_horizontal = sign(speed_horizontal);
}

/*
    Block Interaction
*/
if (move != 0 && place_meeting(x, y + 1, obj_ground)) {
    if (place_meeting(x + speed_horizontal, y, par_block)) {
        block = true;
        image_xscale = direction_horizontal;
        sprite_index = spr_char_push;
        state = scr_push_state;
        exit;
    }
}

/*
    Orb Interaction
*/
if (place_meeting(x, y + 1, obj_orb_pickup)) {
    var itm_orb = instance_place(x, y + 1, obj_orb_pickup);
    with (itm_orb) {
        instance_destroy();
    }
    global.ORBCOUNT_TOTAL++;
    global.ORBCOUNT_CURRENT++;
    audio_play_sound(snd_lightorb,0,0); // THIS ONE WORKS FINE.
}

/* 
    Ladder Interaction
*/

if (light_or_dark == 1) {
    dir = 1;
} else {
    dir = -1;
}

if (key_up || key_down) {
    if (place_meeting(x + 30 * dir, y, par_ladder) && place_meeting(x + 30 * dir, y - 150, par_ladder)) {
        ladder = true;
        sprite_index = spr_char_ladder;
        state = scr_ladder_state;
        exit;
    }
}


/* 
    Collision Detection
*/

is_climb = false;
if (place_meeting(x+speed_horizontal, y, obj_ground) || place_meeting(x+speed_horizontal, y - 10, par_block)) {
    y_iter = 0;
    while (place_meeting(x+speed_horizontal, y-y_iter, obj_ground) && y_iter <= abs(3 * speed_horizontal)) { // Walking on hill
        y_iter += 1;
    }
    if (place_meeting(x+speed_horizontal, y-y_iter, obj_ground) || place_meeting(x+speed_horizontal, y-y_iter, par_block)) { // We've hit a wall, don't want to climb
        while(!(place_meeting(x+sign(speed_horizontal),y, obj_ground) || place_meeting(x+sign(speed_horizontal), y, par_block))) {
            x += sign(speed_horizontal);
        }
        speed_horizontal = 0;
    } else {
        y -= y_iter;
        is_climb = true;
    }
} 

/*

    Edgewise Fixing

*/

if (place_meeting(x+speed_horizontal, y+speed_vertical, obj_ground) || place_meeting(x, y+speed_vertical, par_block)) {
    while(!(place_meeting(x+speed_horizontal,y+sign(speed_vertical), obj_ground) || place_meeting(x+speed_horizontal,y+sign(speed_vertical), par_block))) {
        y += sign(speed_vertical);
    }
    speed_vertical = 0;
}

/*
    Movement Processing
*/

if ((speed_vertical != 0 && !is_climb) || !(place_meeting(x, y+speed_vertical+10, obj_ground) || place_meeting(x, y+speed_vertical+34, par_block))) {
    sprite_state = STATE_JUMP;
    if (speed_vertical <=-1) {
    audio_stop_sound(snd_walking);
    if (!audio_is_playing(snd_jumping)) {
        audio_play_sound(snd_jumping,0,false); 
    }
    }
} else if (speed_horizontal != 0) {
    //if(speed_vertical == 0) {
        sprite_state = STATE_WALK;
        if (!audio_is_playing(snd_walking)) {
            audio_play_sound(snd_walking,0,false);
        }
    //}
} else {
    sprite_state = STATE_STAND;
}

x += speed_horizontal;
y += speed_vertical;

x = clamp(x, 0, room_width); // Can't leave the room.
y = clamp(y, 0, room_height);

/*
    Ledge Climb
*/

var right_was_free = !place_meeting(x + (10 * direction_horizontal), yprevious - 170, obj_ground);
var right_is_not_free = place_meeting(x + (10 * direction_horizontal), y-130, obj_ground);
if (right_was_free && right_is_not_free && (yprevious <= y)) {
    speed_horizontal = 0;
    speed_vertical = 0;
    sprite_index = spr_char_ledge_static;
    image_xscale = direction_horizontal;
    state = scr_ledge_grab_state;
    audio_stop_sound(snd_walking);
    speed_ledge = 0;
    exit;
}


/*
    Adjust sprite on movement
*/
    
if (move > 0) {
    image_xscale = -1;
} else if (move < 0) {
    image_xscale = 1;
} 

if (sprite_state == STATE_JUMP) {
    if (place_meeting(x, y + 20, obj_ground)) {
        if (is_climb) {
            sprite_index = spr_char_walk;
        }
    } else {
        sprite_index = spr_char_jump;
        audio_stop_sound(snd_walking);
    }
} else if (sprite_state == STATE_WALK) {
    if (!(place_meeting(x+speed_horizontal, y - 50, obj_ground))) { // if space above is free
        while (place_meeting(x, y, obj_ground)) {
            y = y - 1;
        }
    } else {
        // shift back to original position
        if (!(place_meeting(x + 10 * -move, y, obj_ground))) {
            x = x + 10 * -move;
        } else if (!(place_meeting(x + 10 * move, y, obj_ground))) {
            x = x + 10 * move;
        }
    }
    sprite_index = spr_char_walk;
    image_speed = 0.7; 
} else {
    if (!(place_meeting(x, y - 50, obj_ground))) { // if space above is free
        while (place_meeting(x, y, obj_ground)) {
            y = y - 1;
        }
    } else {
        // shift back to original position
        if (!(place_meeting(x + 10 * -5, y - 10, obj_ground))) {
            x = x + 10 * -5;
        } else if (!(place_meeting(x + 10 * 5, y - 10, obj_ground))) {
            x = x + 10 * 5;
        }
    }
    sprite_index = spr_char;
    audio_stop_sound(snd_walking);
}


