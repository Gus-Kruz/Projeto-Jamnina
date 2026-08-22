extends PanelContainer
class_name SlotCarta

@export var id_palavra_esperada: String = ""
@export var eh_slot_resposta: bool = false

var pedaco_encaixado: PedacoCarta = null

func esta_livre() -> bool:
	return pedaco_encaixado == null

func ajustar_tamanho(tamanho: Vector2) -> void:
	custom_minimum_size = tamanho

func destacar(ativo: bool) -> void:
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var novo_style = style.duplicate()
		if ativo:
			novo_style.border_color = Color(0.85, 0.65, 0.1, 0.9)
			novo_style.bg_color = Color(1.0, 0.95, 0.5, 0.2)
		else:
			if eh_slot_resposta:
				novo_style.border_color = Color(0.25, 0.18, 0.1, 0.6)
				novo_style.bg_color = Color(0.0, 0.0, 0.0, 0.06)
			else:
				novo_style.border_color = Color(0.4, 0.3, 0.2, 0.35)
				novo_style.bg_color = Color(0.0, 0.0, 0.0, 0.03)
		add_theme_stylebox_override("panel", novo_style)
