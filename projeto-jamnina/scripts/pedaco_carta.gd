extends PanelContainer
class_name PedacoCarta

signal pedaco_solto(pedaco)

@export var id_palavra: String = ""
var dragging: bool = false
var offset_drag: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Força o mouse_filter para STOP ou PASS para pegar o clique
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				offset_drag = get_global_mouse_position() - global_position
				z_index = 10 # Traz para frente
			else:
				dragging = false
				z_index = 0
				pedaco_solto.emit(self)
				
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset_drag

func set_texto(texto: String) -> void:
	id_palavra = texto
	if has_node("Label"):
		$Label.text = texto
