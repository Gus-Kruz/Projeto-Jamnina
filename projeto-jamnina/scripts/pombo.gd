extends CharacterBody2D

var carta = false
var velocidade = 10
var direcao = Vector2(-1,-1)
@export var caminho :String

func _ready() -> void:
	$AnimatedSprite2D.play('parado')
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("baixo") and carta:
		$Label.visible = false
		$AnimatedSprite2D.play('voando')
		position = direcao * velocidade
		get_tree().change_scene_to_file("res://cenas/carta/carta" + caminho + ".tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("amaciado"):
		$Label.text = 'Entregue a carta'
		carta = true
	else:
		$Label.text = 'Pegue o doce'
