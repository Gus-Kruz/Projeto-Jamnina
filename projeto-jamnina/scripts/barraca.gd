extends Node2D

@export var cor : Color = Color.WHITE

@onready var teto_tenda : Sprite2D = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	teto_tenda.modulate = cor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


signal entrou
signal saiu

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "carteiro":
		entrou.emit()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "carteiro":
		saiu.emit()
