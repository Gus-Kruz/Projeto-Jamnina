extends PanelContainer
class_name SlotCarta

@export var id_palavra_esperada: String = ""
var pedaco_encaixado: PedacoCarta = null

func esta_livre() -> bool:
	return pedaco_encaixado == null
