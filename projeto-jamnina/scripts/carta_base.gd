extends Control

const TRANSICAO =  preload("res://cenas/menu/transicao.tscn")

@export var frase_alvo: Array[String] = []
@export var frase_inicial: Array[String] = []
@export var proxima_fase: String

var pedaco_scene = preload("res://cenas/carta/pedaco_carta.tscn")
var slot_scene = preload("res://cenas/carta/slot_carta.tscn")

var slots: Array[SlotCarta] = []
var pecas: Array[PedacoCarta] = []

func _ready() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	if frase_alvo.size() > 0:
		iniciar_puzzle(frase_alvo)

func iniciar_puzzle(palavras: Array[String]) -> void:
	for child in $SlotsContainer.get_children():
		child.queue_free()
	for child in $PecasIniciais.get_children():
		child.queue_free()
	
	slots.clear()
	pecas.clear()
	
	for palavra in palavras:
		var slot = slot_scene.instantiate() as SlotCarta
		slot.id_palavra_esperada = palavra
		$SlotsContainer.add_child(slot)
		slots.append(slot)

	await get_tree().process_frame

	var palavras_iniciais = frase_inicial.duplicate()
	if palavras_iniciais.size() != palavras.size():
		palavras_iniciais = palavras.duplicate()
		palavras_iniciais.shuffle()

	for i in range(palavras_iniciais.size()):
		var palavra = palavras_iniciais[i]
		var pedaco = pedaco_scene.instantiate() as PedacoCarta
		$PecasIniciais.add_child(pedaco)
		pedaco.set_texto(palavra)

		if i < slots.size():
			pedaco.global_position = slots[i].global_position
			slots[i].pedaco_encaixado = pedaco
		
		pedaco.pedaco_solto.connect(_on_pedaco_solto)
		pecas.append(pedaco)
		
	$TextoVitoria.hide()

func _on_pedaco_solto(pedaco: PedacoCarta) -> void:
	var snap_distance = 50.0

	for s in slots:
		if s.pedaco_encaixado == pedaco:
			s.pedaco_encaixado = null

	for slot in slots:
		if slot.esta_livre():
			var dist = pedaco.global_position.distance_to(slot.global_position)
			if dist < snap_distance:
				var tween = create_tween()
				tween.tween_property(pedaco, "global_position", slot.global_position, 0.1)
				slot.pedaco_encaixado = pedaco
				break

	verificar_vitoria()

func verificar_vitoria() -> void:
	var tudo_certo = true
	
	for slot in slots:
		if slot.pedaco_encaixado == null:
			tudo_certo = false
			break
		if slot.pedaco_encaixado.id_palavra != slot.id_palavra_esperada:
			tudo_certo = false
			break
			
	if tudo_certo and slots.size() > 0:
		$TextoVitoria.show()
		$TextoVitoria.scale = Vector2.ZERO
		$TextoVitoria.pivot_offset = $TextoVitoria.size / 2
	
		var tween = create_tween().set_parallel(false)
		tween.tween_property($TextoVitoria, "scale", Vector2(1.2, 1.2), 0.25)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property($TextoVitoria, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		var transicao = TRANSICAO.instantiate()
		add_child(transicao)
		var fade = transicao.get_node("fade")
		await get_tree().create_timer(1).timeout
		fade.play('fade')
		await fade.animation_finished
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://cenas/níveis/nível" + "proxima_fase"+".tscn")
	else:
		$TextoVitoria.hide()
