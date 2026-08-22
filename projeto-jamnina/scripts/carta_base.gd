extends Control
class_name CartaBase

const TRANSICAO = preload("res://cenas/menu/transicao.tscn")
const FONTE_PADRAO = preload("res://recursos/fontes/Daydream DEMO.otf")

@export_group("Configuração da Carta")
@export_multiline var texto_carta: String = ""
@export var frase_escondida: Array[String] = []
@export var proxima_fase: String = ""
@export var titulo_frase_escondida: String = "Mensagem Secreta:"
@export var mensagem_intro: String = ""

@export_group("Configuração Visual")
@export var tamanho_fonte_carta: int = 16
@export var cor_texto_carta: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var tamanho_pecas_e_slots: Vector2 = Vector2(130, 44)
@export var distancia_snap: float = 60.0

var pedaco_scene = preload("res://cenas/carta/pedaco_carta.tscn")
var slot_scene = preload("res://cenas/carta/slot_carta.tscn")

var slots_resposta: Array[SlotCarta] = []
var slots_carta: Array[SlotCarta] = []
var todos_slots: Array[SlotCarta] = []
var pecas: Array[PedacoCarta] = []

var ultimo_slot_agarrado: SlotCarta = null
var vitoria_concluida: bool = false

func _ready() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	
	if has_node("TextoVitoria"):
		$TextoVitoria.hide()
		
	montar_puzzle_carta()
	
	if not mensagem_intro.strip_edges().is_empty():
		exibir_mensagem_intro()

func exibir_mensagem_intro() -> void:
	var label_intro: Label
	if has_node("TextoIntro"):
		label_intro = $TextoIntro as Label
	else:
		label_intro = Label.new()
		label_intro.name = "TextoIntro"
		label_intro.z_index = 90
		label_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_intro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_intro.anchors_preset = Control.PRESET_CENTER
		label_intro.anchor_left = 0.5
		label_intro.anchor_top = 0.5
		label_intro.anchor_right = 0.5
		label_intro.anchor_bottom = 0.5
		label_intro.offset_left = -400
		label_intro.offset_top = -50
		label_intro.offset_right = 400
		label_intro.offset_bottom = 50
		label_intro.grow_horizontal = Control.GROW_DIRECTION_BOTH
		label_intro.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		var settings = LabelSettings.new()
		settings.font = FONTE_PADRAO
		settings.font_size = 36
		settings.font_color = Color(0.95, 0.85, 0.2, 1.0)
		settings.outline_size = 10
		settings.outline_color = Color("00000092")
		settings.shadow_size = 2
		settings.shadow_color = Color(0.0, 0.0, 0.0, 0.573)
		label_intro.label_settings = settings
		add_child(label_intro)
		
	label_intro.text = mensagem_intro
	label_intro.show()
	label_intro.modulate.a = 0.0
	label_intro.scale = Vector2(0.7, 0.7)
	label_intro.pivot_offset = label_intro.size / 2.0
	
	var tween = create_tween().set_parallel(false)
	tween.set_parallel(true)
	tween.tween_property(label_intro, "modulate:a", 1.0, 1.6)
	tween.tween_property(label_intro, "scale", Vector2(1.0, 1.0), 1.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	tween.set_parallel(false)
	tween.tween_interval(1.8)
	
	tween.set_parallel(true)
	tween.tween_property(label_intro, "modulate:a", 0.0, 2.0)
	tween.tween_property(label_intro, "scale", Vector2(1.15, 1.15), 2.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	tween.set_parallel(false)
	tween.tween_callback(label_intro.hide)

func montar_puzzle_carta() -> void:
	limpar_elementos()
	
	if has_node("MargemCarta/ConteudoCarta/AreaFraseEscondida/LabelFraseEscondida"):
		get_node("MargemCarta/ConteudoCarta/AreaFraseEscondida/LabelFraseEscondida").text = titulo_frase_escondida
	
	var container_texto = obter_container_texto()
	var container_slots_resposta = obter_container_slots()
	var container_pecas = obter_container_pecas()
	
	for palavra_esperada in frase_escondida:
		var slot_resp = slot_scene.instantiate() as SlotCarta
		slot_resp.id_palavra_esperada = palavra_esperada
		slot_resp.eh_slot_resposta = true
		slot_resp.ajustar_tamanho(tamanho_pecas_e_slots)
		container_slots_resposta.add_child(slot_resp)
		slots_resposta.append(slot_resp)
		todos_slots.append(slot_resp)

	var paragrafos = texto_carta.split("\n")
	var pecas_para_posicionar: Array[Dictionary] = []
	
	for paragrafo in paragrafos:
		var flow = HFlowContainer.new()
		flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flow.alignment = FlowContainer.ALIGNMENT_CENTER
		flow.add_theme_constant_override("h_separation", 8)
		flow.add_theme_constant_override("v_separation", 8)
		container_texto.add_child(flow)
		
		if paragrafo.strip_edges().is_empty():
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 16)
			flow.add_child(spacer)
			continue
			
		var tokens = extrair_tokens(paragrafo)
		for token in tokens:
			if token.eh_movel:
				var slot_inline = slot_scene.instantiate() as SlotCarta
				slot_inline.id_palavra_esperada = token.texto
				slot_inline.eh_slot_resposta = false
				slot_inline.ajustar_tamanho(tamanho_pecas_e_slots)
				flow.add_child(slot_inline)
				slots_carta.append(slot_inline)
				todos_slots.append(slot_inline)
				
				var pedaco = pedaco_scene.instantiate() as PedacoCarta
				container_pecas.add_child(pedaco)
				pedaco.set_texto(token.texto, tamanho_pecas_e_slots)

				pedaco.pedaco_agarrado.connect(_on_pedaco_agarrado)
				pedaco.pedaco_solto.connect(_on_pedaco_solto)
				pecas.append(pedaco)
				
				pecas_para_posicionar.append({
					"pedaco": pedaco,
					"slot": slot_inline
				})
			else:
				var label = Label.new()
				label.text = token.texto
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				
				var settings = LabelSettings.new()
				settings.font = FONTE_PADRAO
				settings.font_size = tamanho_fonte_carta
				settings.font_color = cor_texto_carta
				label.label_settings = settings
				
				flow.add_child(label)
				
	await get_tree().process_frame
	await get_tree().process_frame

	for item in pecas_para_posicionar:
		var p = item.pedaco as PedacoCarta
		var s = item.slot as SlotCarta
		p.global_position = s.global_position
		p.slot_atual = s
		p.slot_origem = s
		s.pedaco_encaixado = p

func extrair_tokens(linha: String) -> Array[Dictionary]:
	var tokens: Array[Dictionary] = []
	var i = 0
	var len_linha = linha.length()
	var buffer_fixo = ""
	
	while i < len_linha:
		var char_atual = linha[i]
		
		if char_atual == "[" or char_atual == "{":
			var char_fechamento = "]" if char_atual == "[" else "}"
			var pos_fim = linha.find(char_fechamento, i + 1)
			
			if pos_fim != -1:
				if not buffer_fixo.is_empty():
					tokens.append({"texto": buffer_fixo, "eh_movel": false})
					buffer_fixo = ""
					
				var palavra_movel = linha.substr(i + 1, pos_fim - (i + 1))
				tokens.append({"texto": palavra_movel, "eh_movel": true})
				i = pos_fim + 1
				continue
				
		if char_atual == " ":
			buffer_fixo += " "
			tokens.append({"texto": buffer_fixo, "eh_movel": false})
			buffer_fixo = ""
		else:
			buffer_fixo += char_atual
			
		i += 1
		
	if not buffer_fixo.is_empty():
		tokens.append({"texto": buffer_fixo, "eh_movel": false})
		
	return tokens

func _on_pedaco_agarrado(pedaco: PedacoCarta) -> void:
	ultimo_slot_agarrado = pedaco.slot_atual
	if pedaco.slot_atual != null:
		pedaco.slot_atual.pedaco_encaixado = null
		pedaco.slot_atual = null

func _on_pedaco_solto(pedaco: PedacoCarta) -> void:
	var slot_mais_proximo: SlotCarta = null
	var menor_distancia = distancia_snap
	var centro_pedaco = pedaco.global_position + (pedaco.size / 2.0)
	
	for slot in todos_slots:
		var centro_slot = slot.global_position + (slot.size / 2.0)
		var dist = centro_pedaco.distance_to(centro_slot)
		if dist < menor_distancia:
			menor_distancia = dist
			slot_mais_proximo = slot
			
	if slot_mais_proximo != null:
		if slot_mais_proximo.esta_livre():
			encaixar_pedaco(pedaco, slot_mais_proximo)
		else:
			var outro_pedaco = slot_mais_proximo.pedaco_encaixado
			if ultimo_slot_agarrado != null and ultimo_slot_agarrado.esta_livre():
				encaixar_pedaco(outro_pedaco, ultimo_slot_agarrado)
			else:
				slot_mais_proximo.pedaco_encaixado = null
				outro_pedaco.slot_atual = null
				var tween = create_tween()
				tween.tween_property(outro_pedaco, "global_position", outro_pedaco.global_position + Vector2(0, 50), 0.15)\
					.set_trans(Tween.TRANS_QUAD)\
					.set_ease(Tween.EASE_OUT)
					
			encaixar_pedaco(pedaco, slot_mais_proximo)
	else:
		pedaco.slot_atual = null
		
	ultimo_slot_agarrado = null
	verificar_vitoria()

func encaixar_pedaco(pedaco: PedacoCarta, slot: SlotCarta) -> void:
	slot.pedaco_encaixado = pedaco
	pedaco.slot_atual = slot
	
	var tween = create_tween()
	tween.tween_property(pedaco, "global_position", slot.global_position, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func verificar_vitoria() -> void:
	if vitoria_concluida:
		return
		
	var tudo_certo = true
	var slots_para_validar = slots_resposta
	
	if slots_para_validar.is_empty():
		return
		
	for slot in slots_para_validar:
		if slot.pedaco_encaixado == null:
			tudo_certo = false
			break
		var palavra_colocada = slot.pedaco_encaixado.id_palavra.to_lower().strip_edges()
		var palavra_esperada = slot.id_palavra_esperada.to_lower().strip_edges()
		if palavra_colocada != palavra_esperada:
			tudo_certo = false
			break
			
	if tudo_certo:
		vitoria_concluida = true
		executar_vitoria()

func executar_vitoria() -> void:
	for pedaco in pecas:
		pedaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	if has_node("TextoVitoria"):
		var texto_vitoria = $TextoVitoria as Label
		texto_vitoria.show()
		texto_vitoria.scale = Vector2.ZERO
		texto_vitoria.pivot_offset = texto_vitoria.size / 2.0
		
		var tween = create_tween().set_parallel(false)
		tween.tween_property(texto_vitoria, "scale", Vector2(1.2, 1.2), 0.25)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(texto_vitoria, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
			
	await get_tree().create_timer(1.2).timeout
	var transicao = TRANSICAO.instantiate()
	add_child(transicao)
	var fade = transicao.get_node("fade")
	fade.play('fade')
	await fade.animation_finished
	await get_tree().create_timer(1.0).timeout
	
	if proxima_fase == 'final':
		get_tree().change_scene_to_file("res://cenas/menu.tscn")
	else:
		get_tree().change_scene_to_file("res://cenas/níveis/nível" + proxima_fase + ".tscn")

func obter_container_texto() -> Control:
	if has_node("MargemCarta/ConteudoCarta/TextoCartaContainer"):
		return get_node("MargemCarta/ConteudoCarta/TextoCartaContainer") as Control
	return self

func obter_container_slots() -> Control:
	if has_node("MargemCarta/ConteudoCarta/AreaFraseEscondida/SlotsContainer"):
		return get_node("MargemCarta/ConteudoCarta/AreaFraseEscondida/SlotsContainer") as Control
	if has_node("SlotsContainer"):
		return $SlotsContainer as Control
	return self

func obter_container_pecas() -> Control:
	if has_node("PecasContainer"):
		return $PecasContainer as Control
	return self

func limpar_elementos() -> void:
	slots_resposta.clear()
	slots_carta.clear()
	todos_slots.clear()
	pecas.clear()
	ultimo_slot_agarrado = null
	vitoria_concluida = false
	
	var container_texto = obter_container_texto()
	if container_texto != self:
		for child in container_texto.get_children():
			child.queue_free()
			
	var container_slots = obter_container_slots()
	if container_slots != self:
		for child in container_slots.get_children():
			child.queue_free()
			
	var container_pecas = obter_container_pecas()
	if container_pecas != self:
		for child in container_pecas.get_children():
			child.queue_free()
