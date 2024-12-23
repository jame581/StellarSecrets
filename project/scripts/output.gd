@tool
extends InteractableDevice
class_name OutputDevice

@export var enabledColor: Color = Color("#a8ca58")
@export var disabledColor: Color = Color("#cf573c")

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# duplicate shader so every output uses unique shader
	if sprite.material is ShaderMaterial:
		sprite.material = sprite.material.duplicate()

func _process(_delta):
	#pass
	if Engine.is_editor_hint():
		update_state()

func update_state():
	if sprite.material is ShaderMaterial:
		var shader_material = sprite.material
		var color = enabledColor if enabled else disabledColor
		
		shader_material.set_shader_parameter("tint_color", color)
		shader_material.set_shader_parameter("enabled", 1.0)

func _on_interacted():
	enabled = !enabled
	update_state()