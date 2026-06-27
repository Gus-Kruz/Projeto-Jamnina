extends CharacterBody2D

var SPEED = 500.0
const JUMP_VELOCITY = -8000.0
var dash = false
var pode
var dentro
var inside

func _physics_process(delta: float) -> void:
	if inside:
		if Input.is_action_just_pressed("baixo"):
			inside = false
			$AnimatedSprite2D.z_index = 2
			$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
	if not is_on_floor() and not dash:
		velocity += get_gravity() * delta * 1.9
		
	# Handle jump.
	if Input.is_action_just_pressed("cima") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_on_floor():
		pode = true
	if Input.is_action_just_pressed("baixo") and dentro and is_on_floor():
		velocity.x = 0
		velocity.y = 0
		pode = false
		inside = true
		$AnimatedSprite2D.modulate = Color(0.353, 0.353, 0.353, 1.0)
		$AnimatedSprite2D.z_index = -1
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
	
	if not is_on_floor() == true:
		$AnimatedSprite2D.play('pular')
	elif direcao == "direita":
		$AnimatedSprite2D.flip_h = false 
		$AnimatedSprite2D.play('andar')
	elif direcao == "esquerda":
		$AnimatedSprite2D.flip_h = true 
		$AnimatedSprite2D.play('andar')
	else:
		$AnimatedSprite2D.play('parado')
		
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


func _on_barraca_entrou() -> void:
	dentro = true


func _on_barraca_saiu() -> void:
	dentro = false
