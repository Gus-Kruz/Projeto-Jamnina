extends CharacterBody2D

@export var patrol_path : Path2D
@onready var anim_state = $AnimatedSprite2D.get("andar1")

var run_speed = 200

enum states {PATROL, CHASE}
var state = states.PATROL
var target = null
var player = null
var current_patrol_point = 0
var patrol_points = []

func _ready():
	if patrol_path:
		patrol_points = patrol_path.curve.get_baked_points()

func _physics_process(delta):
	velocity = Vector2.ZERO
	choose_action()
	if target:
		if target.x > position.x:
			$AnimatedSprite2D.scale.x = 1
			$DetectRadius/Visao.scale.x = 1
		elif target.x < position.x:
			$AnimatedSprite2D.scale.x = -1
			$DetectRadius/Visao.scale.x = -1
		velocity = position.direction_to(target) * run_speed

	move_and_slide()

func choose_action():
	match state:
		states.PATROL:
			if !patrol_path:
				anim_state.travel("andar1")
				target = null
				return
			target = patrol_points[current_patrol_point]
			if position.distance_to(target) < 5:
				current_patrol_point = wrapi(current_patrol_point + 1, 0, patrol_points.size())
		states.CHASE:
			target = player.position

func _on_detect_radius_body_entered(body):
	player = body
	state = states.CHASE

func _on_detect_radius_body_exited(body):
	player = null
	state = states.PATROL
