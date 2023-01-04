class_name Dir

#author: Pixelbyte studios

const VonNeumann:Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
const Diag:Array = [Vector2.ONE, -Vector2.ONE, Vector2(-1, 1), Vector2(1, -1)]
const Moore:Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2(1,1), Vector2(-1,1), Vector2(1, -1), Vector2(-1,-1)]

const Compass:Dictionary = {
	0 : Vector2.RIGHT,
	1 : Vector2(1, 1),
	2 : Vector2.DOWN,
	3 : Vector2(-1, 1),
	4 : Vector2.LEFT,
	5 : Vector2(-1, -1),
	6 : Vector2.UP ,
	7 : Vector2(1, -1)
}

static func mirror(dir:Vector2) -> Vector2: return -dir

static func to_compass(dir: Vector2) -> Vector2:
	var compass = (int(round(atan2(dir.y, dir.x) / (TAU / 8))) + 8) % 8
	#print("%s %s" % [compass, Compass[compass]])
	return Compass[compass]

static func to_von_neumann(dir: Vector2) -> Vector2:
	var compass = (int(round(atan2(dir.y, dir.x) / (TAU / 8))) + 8) % 8
	
	#even numbers are von-neumann directions
	if compass % 2 == 0:
		return Compass[compass]
	else:
		return Vector2.ZERO
	
static func random_dir_moore() -> Vector2:
	return Moore[randi() % 8]
	
static func random_dir_diag() -> Vector2:
	return Diag[randi() % 4]

static func random_dir_von() -> Vector2:
	return VonNeumann[randi() % 4]
