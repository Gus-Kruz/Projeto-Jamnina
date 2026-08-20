extends Sprite2D

var i = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = Vector2(0, 2*sin(i))
	i += 0.02
