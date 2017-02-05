/// scr_move_state()

if (keyboard_check(ord('A'))) {
    game_restart();
} else if (keyboard_check(ord('P'))) { // artificially simulate grabbing ledge. Used for debugging.
    state = scr_ledge_grab_state;
    exit;
}

/// Setup dropping orb 
/// FIXME: Implementation currently isn't there. This simply shows off the GUI
if (keyboard_check_pressed(ord('1')) || keyboard_check_pressed(ord('2'))) {
    if (global.ORBCOUNT_CURRENT > 0) {
        global.ORBCOUNT_CURRENT--;
    }    
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
if (place_meeting(x, y + 1, obj_orb)) {
    var itm_orb = instance_place(x, y + 1, obj_orb);
    with (itm_orb) {
        instance_destroy();
    }
    global.ORBCOUNT_TOTAL++;
    global.ORBCOUNT_CURRENT++;
}

/* 
    Ladder Interaction
*/
if (key_up || key_down) {
    if (place_meeting(x, y, par_ladder)) {
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
if (place_meeting(x+speed_horizontal, y, obj_ground)) {
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

if (place_meeting(x, y+speed_vertical, obj_ground) || place_meeting(x, y+speed_vertical, par_block)) {
    while(!(place_meeting(x,y+sign(speed_vertical), obj_ground) || place_meeting(x,y+sign(speed_vertical), par_block))) {
        y += sign(speed_vertical);
    }
    speed_vertical = 0;
}

/*
    Movement Processing
*/

if (speed_vertical != 0 && !is_climb) {
    sprite_state = STATE_JUMP;
} else if (speed_horizontal != 0) {
    sprite_state = STATE_WALK;
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

var right_was_free = !place_meeting(x + (10 * direction_horizontal), yprevious - 70, obj_ground);
var right_is_not_free = place_meeting(x + (10 * direction_horizontal), y-30, obj_ground);
if (right_was_free && right_is_not_free && (yprevious <= y)) {
    speed_horizontal = 0;
    speed_vertical = 0;
    sprite_index = spr_char_ledge;
    image_xscale = direction_horizontal;
    state = scr_ledge_grab_state;
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
    sprite_index = spr_char_jump;
} else if (sprite_state == STATE_WALK) {
    sprite_index = spr_char_walk;
} else {
    sprite_index = spr_char;
}

