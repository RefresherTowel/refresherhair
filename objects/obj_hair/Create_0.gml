/// @description Insert description here
// You can write your code in this editor

enum draw_types {
	TEX,
	CIRCLE
}

///@func	Point(offsetx,offsety,max_dist,x,y,radius)
///@param	{real}	offsetx		The x offset for the point
///@param	{real}	offsety		The y offset for the point
///@param	{real}	max_dist	The maximum distance the point can be from it's owner
///@param	{real}	x			The x position of the point
///@param	{real}	y			The y position of the point
///@param	{int}	radius		The radius of the point
///@desc	Creates a new point struct
Point = function(_offsetx,_offsety,_max_dist,_x,_y,_radius) constructor {
	x = _x;
	y = _y;
	static wind_count = 0;
	offsetx = _offsetx;
	offsety = _offsety;
	wind_offsetx = 0;
	wind_offsety = 0;
	max_dist = _max_dist;
	radius = _radius;
	
	///@func	UpdatePos(x,y,use_offset?)
	///@param	{real}	x			The x position to set the point to
	///@param	{real}	y			The y position to set the point to
	///@param	{bool}	static		Whether the point should move with the wind
	///@desc	Updates the position for the point
	UpdatePos = function(_x,_y,_static = false) {
		if (!_static) {
			x = _x + (offsetx * global.facing) + wind_offsetx;
			y = _y + (offsety + wind_offsety);
		}
		else {
			x = _x + (offsetx * global.facing);
			y = _y + (offsety);
		}
	}
	
	///@func	DrawPoint()
	///@desc	Draws the individual point
	DrawPoint = function() {
		draw_circle(x,y,radius,false);
	}
}

//	Set up the strands for the textured version of the hair
tex_strands = [];

var points = [
	new Point(0,		0,		0,		0,		0,		4),
	new Point(-8,		4,		2,		0,		0,		3),
	new Point(-8,		6,		1,		0,		0,		2),
	new Point(-6,		8,		1,		0,		0,		1),
];

array_push(tex_strands,points);

var points = [
	new Point(9,		-10,	0,		0,		0,		2),
	new Point(-10,		2,		2,		0,		0,		1),
	new Point(-8,		4,		1,		0,		0,		1),
	new Point(-6,		6,		1,		0,		0,		1),
];

array_push(tex_strands,points);

var points = [
	new Point(-6,		9,		0,		0,		0,		3),
	new Point(-6,		4,		3,		0,		0,		3),
	new Point(-5,		6,		2,		0,		0,		2),
	new Point(-4,		4,		2,		0,		0,		1),
];

array_push(tex_strands,points);

//	Set up the strands for the "circle" version of the hair (similar to Celeste)
circle_strands = [];

var points = [
	new Point(3,		9,		0,		0,		0,		15),
	new Point(-4,		6,		10,		0,		0,		13),
	new Point(-5,		4,		9,		0,		0,		11),
	new Point(-4,		4,		8,		0,		0,		8),
	new Point(-3,		3,		7,		0,		0,		5),
	new Point(-2,		2,		4,		0,		0,		3),
];

array_push(circle_strands,points);

// Set the actual strands that are going to be displayed to the tex_strands array to begin with
strands = tex_strands;

//	So all the strands and points above might seem a little confusing, but basically, I set it up
//	so that you can have more than one "strand" of hair and each strand requires a series of points.
//	I've also made it so that you can switch between the texture vertex version or a simple circle
//	drawing. Because of that, I've set up two different sets of strands, tex_strands and circle_strands.
//	The normal strands is the array that will actually be read.

//	Basically, the hair is composed of a series of points. These points are stored in an array. They have
//	6 values: offsetx, offsety, max distance, x, y and radius. Each point corresponds to a "section" of the hair.
//	The offsetx and offsety are how much each point should be offset from the previous one, max distance is the
//	maximum distance the point can be from it's previous point, x and y are the positions of the point and radius
//	is how "wide" the hair should be at that point.

//	draw_type is how we determine if we're drawing texture vertices or plain circles
draw_type = draw_types.TEX;

///@func	Update()
///@desc	The update function should be run each step, it loops through the points and sets their positions accordingly
Update = function() {
	
	//	Run through each "strand"
	for (var k=0;k<array_length(strands);k++) {
		//	And grab the points array from that strand
		var points = strands[k];
		var _points_len = array_length(points);
		
		//	This loop does some positioning stuff, we run it backwards so that each point gets set
		//	to the position of the previous point one frame behind, which introduces a nice little
		//	lag effect that makes the hair more flowy. If we ran it from 0 to _points_len instead,
		//	it would lose a bit of it's motion
		for (var i=_points_len-1;i>=0;i--) {
			
			//	This is just some mathy stuff to make the wind move the points up and down in a varied and semi-realistic way
			points[i].wind_offsety = sin(degtorad((count*(i+1))+((i*10)*(k*5)))*1);
			
			//	Uncomment bellow to have the wind move the points horizontally
			//points[i].wind_offsetx = sin(degtorad(random(3)+count+(i*5)*k)*1);
			
			//	Here we are updating the positions for each point, there's a method in the Point constructor called
			//	UpdatePos() which sets the x and y position for that point. Have a look at the method inside the constructor
			//	at the top of this event for a more full description of it
			if (i == 0) {
				//	The initial point is set to the mouse positiono
				points[i].UpdatePos(mouse_x,mouse_y,true);
			}
			else {
				//	Then all subsequent points are set to the x and y of the previous point
				points[i].UpdatePos(points[i-1].x,points[i-1].y);
			}
		}
		
		//	Now we run through the loop forwards so that we can do a distance check and make
		//	sure none of the points are further away than their max distance from the previous
		//	point. This makes sure the points don't lag way far behind if there's a big movement
		for (var i=0;i<_points_len;i++) {
			if (i == 0) { // Skip the first point
				continue;
			}
			var _prev_point = points[i-1];
			with (points[i]) {
				var _offx = offsetx * global.facing + wind_offsetx;
				var _offy = offsety + wind_offsety;
				var xx = _prev_point.x + _offx;
				var yy = _prev_point.y + _offy;
				var _dist = point_distance(x,y,xx,yy);
				if (_dist > max_dist) {
					var _dir = point_direction(xx,yy,x,y);
					var _x = lengthdir_x(max_dist,_dir);
					var _y = lengthdir_y(max_dist,_dir);
					UpdatePos(_prev_point.x+_x,_prev_point.y+_y);
				}
			}
		}
	}
	count++;
}

///@func	Draw()
///@desc	The draw function draws the all the points for the hair
Draw = function(_sprite = undefined) {
	for (var k=0;k<array_length(strands);k++) {
		
		//	Loop through all the "strands" and grab the points array for each strand
		var points = strands[k];
		var _points_len = array_length(points);
		
		switch(draw_type) {
			case draw_types.TEX:
			
				//	First we check to see if an argument has been provided for the Draw function
				//	If it hasn't, we'll be drawing non-textured primitives
				if (_sprite == undefined) {
					
					draw_primitive_begin(pr_trianglestrip);
					
					//	Loop through all the points and draw the vertices for them
					for (var i=0;i<_points_len-1;i++) {
						var _np = points[i+1];
						with (points[i]) {
							//	We want the final vertex draw to come to a point, so we check to see if we're drawing the last one
							if (i < _points_len-2) {
								
								//	If we're not drawing the last one, we draw as normal. Basically, we are drawing squares
								//	composed of two triangles, which have three vertex draws each. We get the corners of 
								//	each point by projecting (using lengthdir) directly up and down from the y position 
								//	at a length of radius. This gives us the first two corners, then the second two corners
								//	are the same thing done to the next point, which ensures the square regions for each point
								//	is always connected to the next point
								
								var _len = lengthdir_y(radius,90);
								var _np_len = lengthdir_y(_np.radius,90);
								var x1 = x;
								var y1 = y+_len;
								var x2 = x1;
								var y2 = y-_len;
								if (i == 0) {
									x1 = x;
									y1 = y;
									x2 = x1;
									y2 = y1;
								}
								var x3 = _np.x;
								var y3 = _np.y+_np_len;
								var x4 = x3;
								var y4 = _np.y-_np_len;
								draw_vertex(x1,y1);
								draw_vertex(x3,y3);
								draw_vertex(x2,y2);
								draw_vertex(x2,y2);
								draw_vertex(x3,y3);
								draw_vertex(x4,y4);
							}
							else {
								//	If we are about to connect to the last point, we draw the first two vertices (x1,y1,x2,y2) as normal
								//	but then we set both x3,y3 and x4,y4 directly to the bottom left corner of the final point, ensuring
								//	the final square region comes to a point rather than ending in a square
								var x1 = x;
								var y1 = y+lengthdir_y(radius,90);
								var x2 = x;
								var y2 = y-lengthdir_y(radius,90);
								var x3 = _np.x;
								var y3 = _np.y-lengthdir_y(_np.radius,90);
								var x4 = x3;
								var y4 = y3;
								var x5 = x;
								var y5 = y;
								draw_vertex(x1,y1);
								draw_vertex(x5,y5);
								draw_vertex(x3,y3);
								draw_vertex(x5,y5);
								draw_vertex(x2,y2);
								draw_vertex(x4,y4);
							}
						}
					}
					draw_primitive_end();
				}
				else {
					
					//	As above, so below, but this time pulling the texture data from the supplied sprite and using that to draw
					var _tex = sprite_get_texture(_sprite,0);
					draw_primitive_begin_texture(pr_trianglestrip,_tex);
					for (var i=0;i<_points_len-1;i++) {
						var _np = points[i+1];
						with (points[i]) {
							if (i < _points_len-2) {
								var _len = lengthdir_y(radius,90);
								var _np_len = lengthdir_y(_np.radius,90);
								var x1 = x;
								var y1 = y+_len;
								var x2 = x1;
								var y2 = y-_len;
								var x3 = _np.x;
								var y3 = _np.y+_np_len;
								var x4 = x3;
								var y4 = _np.y-_np_len;
								draw_vertex_texture(x1,y1,0,0);
								draw_vertex_texture(x3,y3,1,0);
								draw_vertex_texture(x2,y2,0,1);
								draw_vertex_texture(x2,y2,0,1);
								draw_vertex_texture(x3,y3,1,0);
								draw_vertex_texture(x4,y4,1,1);
							}
							else {
								var x1 = x;
								var y1 = y+lengthdir_y(radius,90);
								var x2 = x;
								var y2 = y-lengthdir_y(radius,90);
								var x3 = _np.x;
								var y3 = _np.y-lengthdir_y(_np.radius,90);
								var x4 = x3;
								var y4 = y3;
								draw_vertex_texture(x1,y1,0,0);
								draw_vertex_texture(x2,y2,0,1);
								draw_vertex_texture(x3,y3,1,0);
								draw_vertex_texture(x2,y2,0,1);
								draw_vertex_texture(x3,y3,1,0);
								draw_vertex_texture(x4,y4,1,1);
							}
						}
					}
					draw_primitive_end();
					
				}
			break;
			case draw_types.CIRCLE:
			
				//	The circle mode is much simpler, we just run the DrawPoint() method from the Point constructor
				//	which simply draws a circle at the x and y position for each point, with the radius that the point
				//	was given. Creates a hair effect very similar to Celeste.
				draw_set_color($202747);
				for (var i=0;i<_points_len;i++) {
					strands[k][i].DrawPoint();
				}
				
			break;
		}
	}
	//	Draw the silly head over everything
	draw_sprite_ext(spr_head,0,strands[0][0].x-strands[0][0].offsetx*global.facing,strands[0][0].y-strands[0][0].offsety,global.facing,1,0,c_white,1);
}

//	Count is just used in the wind effect that makes the hair move up and down and left and right, it's a simple counter
count = 0;
//	We need some way of telling which way the character is facing and it should be global so it can be easily accessed
//	inside of the Point structs. 1 is facing right, -1 is facing left.
global.facing = 1;