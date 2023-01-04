tool
extends Node2D

#A nifty tool script that draws a grid of grid_size with an offset of grid_offset
# 2020 Pixelbyte Studios
export(Vector2) var grid_size := Vector2(320,180)
export(Vector2) var offset := Vector2.ZERO
export(Color) var center_grid_color := Color(0,1,1)
export(Color) var grid_color := Color(0.9,0.9,0.9,0.8)
export(bool) var highlight_center := true
export(int) var range_start := -3
export(int) var range_end := 3
export(bool) var enabled := true

var grid_offset : Vector2
var mid_grid :int

func _ready():
	#if we aren't running in the editor, delete this node
	if !Engine.editor_hint:
		queue_free()

func setup():
	mid_grid = range_start + (range_end - range_start) << 1
	grid_offset = -grid_size / 2

func _draw():
	if !enabled:
		return
		
	setup()

	var start = Vector2(range_start * grid_size.x, range_start * grid_size.y)
	var end = Vector2(range_end * grid_size.x, range_end * grid_size.y)
	
	for y in range(range_start, range_end + 1):
		draw_line(grid_offset + Vector2(start.x, y * grid_size.y) + offset, grid_offset + Vector2(end.x, y * grid_size.y) + offset, grid_color, 2)

	for x in range(range_start, range_end + 1):
		draw_line(grid_offset + Vector2(x * grid_size.x, start.y) + offset, grid_offset + Vector2(x * grid_size.x, end.y) + offset, grid_color, 2)

	if highlight_center:
		for i in range(mid_grid, mid_grid + 2):
			draw_line(grid_offset + Vector2(mid_grid * grid_size.x, i * grid_size.y) + offset, grid_offset + Vector2( mid_grid * grid_size.x + grid_size.x, i * grid_size.y) + offset, center_grid_color, 2)
			draw_line(grid_offset + Vector2(i * grid_size.x, mid_grid * grid_size.y) + offset, grid_offset + Vector2(i * grid_size.x, mid_grid * grid_size.y + grid_size.y) + offset, center_grid_color, 2)

func _process(delta):
	update()
