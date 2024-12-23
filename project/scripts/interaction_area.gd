extends Area2D
class_name InteractionArea

@export var interaction_text: String = "interact"

# Define the signal
signal interacted()

var interact: Callable = func():
	emit_signal("interacted")

func _ready() -> void:
	pass
	# self.body_entered.connect(_on_body_entered)
	# self.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	InteractionManager.register_area(self)

func _on_body_exited(body: Node) -> void:
	InteractionManager.unregister_area(self)
