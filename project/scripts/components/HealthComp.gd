class_name HealthComp
extends ObservableInt

signal health_changed(prev, current, max_health, percent, was_healed)
signal health_depleted()

export(int) var max_health :int = 5 setget set_max_health, get_max_health
func get_max_health() -> int: return max_health
func set_max_health(val:int):
	max_health = val
	if health > max_health:
		health = max_health

var health :int = 0 setget set_health, get_health
func get_health() -> int: return self.val
func set_health(val:int):
	var prev_health := health
	self.val = clamp(val, 0, max_health)
	emit_signal("health_changed", prev_health, self.val, max_health, self.health_percent, prev_health < self.val)
	if self.val == 0 && !_has_died:
		_has_died = true
		emit_signal("health_depleted")

var is_alive :bool setget ,get_is_alive
func get_is_alive() -> bool: return !_has_died && health > 0

var health_percent:float setget ,get_health_percent
func get_health_percent() -> float: return health / float(max_health) if max_health > 0 else 0

var _has_died :bool

func _ready() -> void:
	init_health()

func init_health():
	self.health = max_health
	
func damage(amount: int):
	self.health -= amount
	
func heal(amount:int):
	#allow a heal to resurrect
	if _has_died && amount > 0:
		_has_died = false
	damage(-amount)
