extends Node2D

const TRANSICAO = preload("res://cenas/menu/transicao.tscn")

@onready var button_voltar : TextureButton = $Fundo/MarginContainer/MenuOptions/Voltar
@onready var buttons : Array[TextureButton] = [
	button_voltar
]

func transicao(caminho: String):
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	fade.play('fade')
	await fade.animation_finished
	get_tree().change_scene_to_file(caminho)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	fade.play_backwards('fade')
	await fade.animation_finished
	get_node("transicao").queue_free()
	
	setup_buttons()

func setup_buttons() -> void:
	
	for button in buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))
		button.focus_entered.connect(_on_button_hover.bind(button))
		button.focus_exited.connect(_on_button_unhover.bind(button))

	await get_tree().process_frame

	for button in buttons:
		button.pivot_offset = button.size / 2.0

	button_voltar.grab_focus()

func _on_button_hover(button: TextureButton) -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_SINE)

	tween.tween_property(button, "modulate", Color(1.136, 0.29, 0.42, 1.0), 0.15)

func _on_button_unhover(button: TextureButton) -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)

	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_voltar_pressed() -> void:
	transicao("res://cenas/menu/menu.tscn")
