extends Node2D

const TRANSICAO =  preload("res://cenas/menu/transicao.tscn")
const CARTA_TEXTURE = preload("res://artes/menu/Carta.png")
const QTD_CARTAS = 20

var cartas_container : Control
var cartas : Array[TextureRect] = []
var screen_size : Vector2 = Vector2(1920, 1080)
var time_elapsed : float = 0.0

@onready var button_jogar : TextureButton = $Fundo/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Jogar
@onready var button_creditos : TextureButton = $Fundo/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Creditos
@onready var button_sair : TextureButton = $Fundo/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Sair
@onready var logo : TextureRect = $Fundo/MarginContainer/HBoxContainer/VBoxContainer/Logo
@onready var versao : TextureRect = $Fundo/MarginContainer/HBoxContainer/VBoxContainer/Versão

@onready var buttons : Array[TextureButton] = [
	button_jogar,
	button_creditos,
	button_sair
]

func transicao(caminho: String):
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	fade.play('fade')
	await fade.animation_finished
	get_tree().change_scene_to_file(caminho)

func _ready() -> void:

	cartas_container = Control.new()
	cartas_container.name = "CartasContainer"
	cartas_container.anchors_preset = Control.PRESET_FULL_RECT
	cartas_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if has_node("Fundo"):
		var fundo = $Fundo
		fundo.add_child(cartas_container)
		fundo.move_child(cartas_container, 0)
		screen_size = fundo.size
	else:
		add_child(cartas_container)
		screen_size = get_viewport_rect().size

	for i in range(QTD_CARTAS):
		criar_carta(true)

	setup_buttons()

func setup_buttons() -> void:
	button_jogar.focus_neighbor_top = button_sair.get_path()
	button_jogar.focus_neighbor_bottom = button_creditos.get_path()
	
	button_creditos.focus_neighbor_top = button_jogar.get_path()
	button_creditos.focus_neighbor_bottom = button_sair.get_path()
	
	button_sair.focus_neighbor_top = button_creditos.get_path()
	button_sair.focus_neighbor_bottom = button_jogar.get_path()
	
	for button in buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))
		button.focus_entered.connect(_on_button_hover.bind(button))
		button.focus_exited.connect(_on_button_unhover.bind(button))

	await get_tree().process_frame

	for button in buttons:
		button.pivot_offset = button.size / 2.0

	button_jogar.grab_focus()

func criar_carta(random_y: bool = false) -> void:
	var carta = TextureRect.new()
	carta.texture = CARTA_TEXTURE
	carta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta.stretch_mode = TextureRect.STRETCH_SCALE
	
	var tex_size = CARTA_TEXTURE.get_size()
	carta.size = tex_size
	carta.pivot_offset = tex_size / 2.0
	
	cartas_container.add_child(carta)
	reset_carta(carta, random_y)
	cartas.append(carta)

func reset_carta(carta: TextureRect, random_y: bool = false) -> void:
	var scale_mult = randf_range(1.0, 2.5)
	carta.scale = Vector2(scale_mult, scale_mult)
	
	if random_y:
		carta.global_position = Vector2(
			randf_range(-250, screen_size.x),
			randf_range(-250, screen_size.y)
		)
	else:
		if randf() > 0.5:
			carta.global_position = Vector2(
				randf_range(-400, screen_size.x - 400),
				-250.0
			)
		else:
			carta.global_position = Vector2(
				-250.0,
				randf_range(-400, screen_size.y - 400)
			)
			
	var speed_mult = randf_range(0.8, 1.4)
	var vel_x = randf_range(70.0, 130.0) * speed_mult
	var vel_y = randf_range(110.0, 190.0) * speed_mult
	
	carta.set_meta("vel_x", vel_x)
	carta.set_meta("vel_y", vel_y)
	carta.set_meta("rot_speed", randf_range(1.5, 3.0))
	carta.set_meta("rot_offset", randf_range(0.0, PI * 2))

func _process(delta: float) -> void:
	time_elapsed += delta
	
	if has_node("Fundo"):
		screen_size = $Fundo.size
		
	for carta in cartas:
		var vel_x = carta.get_meta("vel_x") as float
		var vel_y = carta.get_meta("vel_y") as float
		var rot_speed = carta.get_meta("rot_speed") as float
		var rot_offset = carta.get_meta("rot_offset") as float
		
		carta.global_position.x += vel_x * delta
		carta.global_position.y += vel_y * delta
		
		var max_rotation_rad = deg_to_rad(30.0)
		carta.rotation = max_rotation_rad * sin(time_elapsed * rot_speed + rot_offset)
		
		if carta.global_position.y > screen_size.y + 100 or carta.global_position.x > screen_size.x + 100:
			reset_carta(carta, false)

func _on_button_hover(button: TextureButton) -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_SINE)

	tween.tween_property(button, "modulate", Color(1.136, 0.29, 0.42, 1.0), 0.15)

func _on_button_unhover(button: TextureButton) -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)

	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func _on_creditos_pressed() -> void:
	transicao("res://cenas/menu/creditos2.tscn")

func _on_jogar_pressed() -> void:
	transicao("res://cenas/níveis/nível1.tscn")
	
func _on_sair_pressed() -> void:
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	fade.play('fade')
	await fade.animation_finished
	get_tree().quit()
