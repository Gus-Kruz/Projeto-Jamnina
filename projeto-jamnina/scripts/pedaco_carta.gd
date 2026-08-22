extends PanelContainer
class_name PedacoCarta

signal pedaco_agarrado(pedaco)
signal pedaco_solto(pedaco)

@export var id_palavra: String = ""
var dragging: bool = false
var offset_drag: Vector2 = Vector2.ZERO

var slot_atual: SlotCarta = null
var slot_origem: SlotCarta = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				offset_drag = get_global_mouse_position() - global_position
				z_index = 50
				scale = Vector2(1.05, 1.05)
				pedaco_agarrado.emit(self)
			else:
				if dragging:
					dragging = false
					scale = Vector2(1.0, 1.0)
					pedaco_solto.emit(self)
				
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset_drag

func set_texto(texto: String, tamanho: Vector2 = Vector2(130, 44)) -> void:
	id_palavra = texto
	if has_node("Label"):
		$Label.text = texto
	definir_tamanho_fixo(tamanho)

func definir_tamanho_fixo(tamanho: Vector2) -> void:
	custom_minimum_size = tamanho
	size = tamanho

