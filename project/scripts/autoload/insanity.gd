extends Node

# Define the signal
signal insanity_changed(new_insanity)

# Define an enum for insanity levels
enum insanity_level {LOW, MEDIUM, HIGH}

# Property to store the insanity level
var insanity: float = 0.0

# Timer to increase insanity level
@onready var insanity_timer: Timer = Timer.new()

@export var insanity_min: float = 0.0
@export var insanity_max: float = 1.8

#@onready var camera_shaker: AnimationPlayer = get_parent().get_node("Node2D/CameraShaker")
var camera_shaker: AnimationPlayer = null
func shake_camera():
	if camera_shaker:
		camera_shaker.play("shake_high")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up the timer
	insanity_timer.wait_time = 0.2
	insanity_timer.autostart = true
	insanity_timer.one_shot = false
	add_child(insanity_timer)
	insanity_timer.connect("timeout", Callable(self, "_on_insanity_timer_timeout"))

	Global.map_changed.connect(Callable(self, "_on_map_changed"))

# Function to handle insanity hit
func insanity_hit(hit_level: insanity_level) -> void:
	match hit_level:
		insanity_level.LOW:
			#print("Insanity hit: LOW")
			increase_insanity(0.10)
		insanity_level.MEDIUM:
			#print("Insanity hit: MEDIUM")
			increase_insanity(0.20)
		insanity_level.HIGH:
			#print("Insanity hit: HIGH")
			increase_insanity(0.30)
	
	if insanity >= insanity_max - 0.3:
		camera_shaker.play("shake_high")

# Private function to increase insanity
func increase_insanity(amount: float) -> void:
	if (insanity + amount) < 0.0:
		return

	insanity += amount
	on_insanity_changed(insanity)
	
	if insanity >= insanity_max:
		GameManager.game_over()
		insanity = 0.0

# Function called when the timer times out
func _on_insanity_timer_timeout() -> void:
	if insanity < 0.7:
		increase_insanity(-0.007) 
	elif insanity < 1.2:
		increase_insanity(-0.01)
	elif insanity < 2.0:
		increase_insanity(-0.02)
	
func on_insanity_changed(new_insanity: float) -> void:
	print("Insanity changed to: ", new_insanity)
	emit_signal("insanity_changed", new_insanity)
	RenderingServer.global_shader_parameter_set("insanity", new_insanity)

# Function to handle map change
func _on_map_changed(_new_map_path: String):
	insanity = 0.0
	on_insanity_changed(insanity)
