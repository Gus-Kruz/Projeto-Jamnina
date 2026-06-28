extends Node2D
var carta = false
@export var caminho :String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play('parado')
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("baixo") and carta:
		$Label.visible = false
		get_tree().change_scene_to_file("res://cenas/carta/carta" + caminho + ".tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("amaciado"):
		$Label.text = 'Entregue a carta'
		carta = true
	else:
		$Label.text = 'Pegue o doce'
