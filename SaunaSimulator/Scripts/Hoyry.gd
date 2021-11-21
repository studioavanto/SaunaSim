extends Sprite

var hoyry_speed = 3.0
var direction = 1
var x_min = -100
var x_max = 100

func _ready():
	direction = 2 * (randi() % 2) - 1
	hoyry_speed += rand_range(-2.5, 2.5) 

func _process(delta):
	position.x += direction * hoyry_speed * delta
	if position.x <= x_min:
		direction = 1
	elif position.x >= x_max:
		direction = -1
