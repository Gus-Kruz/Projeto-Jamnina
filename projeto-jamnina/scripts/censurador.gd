extends CharacterBody2D

@export_range(1, 3) var sprite_number : int = 1
@export var walk_speed : float = 80.0
@export var run_speed : float = 200.0
@export var chase_distance : float = 300.0
@export var patrol_path : Path2D

@onready var animated_sprite : AnimatedSprite2D = $Animacoes
@onready var visao : CollisionShape2D = $DetectRadius/Visao
@onready var alcance : CollisionShape2D = $PegacaoArea/Alcance

enum States { PATROL, CHASE }
var state : States = States.PATROL

var target : Vector2 = Vector2.ZERO
var player : CharacterBody2D = null
var current_patrol_point : int = 0
var patrol_points : Array[Vector2] = []
var dentro = false
var walk_anim : String
var run_anim : String

func _ready() -> void:
	walk_anim = "andar" + str(sprite_number)
	run_anim = "correr" + str(sprite_number)

	animated_sprite.play(walk_anim)

	if patrol_path:
		var local_points = patrol_path.curve.get_baked_points()
		for p in local_points:
			patrol_points.append(patrol_path.to_global(p))
		
		if patrol_points.size() > 0:
			target = patrol_points[current_patrol_point]

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	if not is_on_floor():
		velocity += get_gravity() * delta * 1.9

	if state == States.CHASE:
		if player:

			if global_position.distance_to(player.global_position) > chase_distance or dentro:
				player = null
				state = States.PATROL
			else:
				target = player.global_position
				move_towards_target(run_speed, run_anim, true)
		else:
			state = States.PATROL

	if state == States.PATROL:
		if patrol_points.size() > 0:
			target = patrol_points[current_patrol_point]

			if global_position.distance_to(target) < 10.0:
				current_patrol_point = wrapi(current_patrol_point + 1, 0, patrol_points.size())
				target = patrol_points[current_patrol_point]
				
			move_towards_target(walk_speed, walk_anim, false)
		else:
			animated_sprite.play(walk_anim)
			
	move_and_slide()

func move_towards_target(speed: float, anim: String, use_deadzone: bool) -> void:
	var dist_x = target.x - global_position.x
	
	if use_deadzone and abs(dist_x) < 10.0:
		velocity.x = 0
		animated_sprite.play(anim)
		return
		
	update_facing(target, use_deadzone)
	var dir_x = sign(dist_x)
	velocity.x = dir_x * speed
	animated_sprite.play(anim)

func update_facing(target_pos: Vector2, use_deadzone: bool) -> void:
	if use_deadzone and abs(target_pos.x - global_position.x) < 10.0:
		return
		
	if target_pos.x > global_position.x:
		animated_sprite.scale.x = 2.0
		visao.scale.x = 1.0
		alcance.scale.x = 1.0
	elif target_pos.x < global_position.x:
		animated_sprite.scale.x = -2.0
		visao.scale.x = -1.0
		alcance.scale.x = -1.0

func _on_detect_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Carteiro"):
		player = body as CharacterBody2D
		state = States.CHASE

func _on_pegacao_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Carteiro"):
		get_tree().reload_current_scene()


func _on_carteiro_entrou() -> void:
	dentro = true


func _on_carteiro_saiu() -> void:
	dentro = false
