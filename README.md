# refresherhair
A simple hair system for GMS

Everything is contained within the obj_hair object. Lots of comments trying to explain what is happening, so prepare for a bit of reading.

There's a tiny bit of bloat in the Create Event of obj_hair though. I've pre-configured some points and two arrays (tex_strands and circle_strands) that aren't necessary. Basically, you can delete all the points and both arrays (tex_strands and circle_strands), then set up your own points array and push it into strands. The only other change you should need to make if you do that is to remove the right mouse button check in the Step Event, because that's just swapping between tex_strands and circle_strands.
