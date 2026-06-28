extends Node2D
var carta = false
@export var caminho :String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play('parado')
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("baixo") and carta:
		pass
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	$Label.visible = true
	carta = true

	
		
		
	
