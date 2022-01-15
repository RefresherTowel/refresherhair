/// @description Insert description here
// You can write your code in this editor

if (mouse_check_button_released(mb_left)) {
	//	Swap the facing direction when the left mouse button is pressed
	global.facing *= -1;
}

if (mouse_check_button_released(mb_right)) {
	//	Swap the draw type when the right mouse button is pressed
	if (draw_type == draw_types.CIRCLE) {
		draw_type = draw_types.TEX;
		strands = tex_strands;
	}
	else {
		draw_type = draw_types.CIRCLE;
		strands = circle_strands;
	}
}

//	Run the Update() method, which automatically goes through and does the positioning for the points
Update();