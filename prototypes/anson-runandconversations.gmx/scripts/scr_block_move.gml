/// scr_block_move(speed_horizontal)
var speed_horizontal = argument[0];

if (place_meeting(x+speed_horizontal, y, obj_ground)) { // We've hit a wall, don't want to climb
    while(!(place_meeting(x+sign(speed_horizontal),y, obj_ground))) {
        x += sign(speed_horizontal);
    }
    speed_horizontal = 0;
}

x += speed_horizontal;
return speed_horizontal;
