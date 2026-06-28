extends Node2D
const TRANSICAO =  preload("res://cenas/menu/transicao.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	await get_tree().create_timer(1).timeout
	fade.play_backwards('fade')
	await fade.animation_finished
	await get_tree().create_timer(2).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
