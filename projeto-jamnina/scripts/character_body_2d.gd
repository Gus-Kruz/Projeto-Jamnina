extends CharacterBody2D


var SPEED = 500.0
const JUMP_VELOCITY = -800.0
var dash = false
var pode
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not dash:
		velocity += get_gravity() * delta * 1.9
	# Handle jump.
	if Input.is_action_just_pressed("cima") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if is_on_floor():
		pode = true
	var direcao
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not dash:
		var direction := Input.get_axis("esquerda", "direita")
		if direction:
			velocity.x = direction * SPEED
			if direction > 0:
				direcao = "direita"
			else:
				direcao = "esquerda"
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	if Input.is_action_just_pressed("dash") and pode:
			$Timer.start()
			pode = false
			dash = true
			velocity.y = 0
			SPEED *= 7
			if direcao == "direita":
				velocity.x = SPEED
			elif direcao == "esquerda":
				velocity.x = -SPEED
	move_and_slide()


func _on_timer_timeout() -> void:
	SPEED = 500
	dash = false
