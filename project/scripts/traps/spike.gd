extends InteractableDevice
class_name Spike

@export_group("Spike")
@export var autostart: bool = true
@export var active: bool = false
@export var damage: Insanity.insanity_level = Insanity.insanity_level.LOW
@export var timer_duration: float = 1.8
@export var impulse_strength: float = 400.0

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = timer_duration
	if autostart:
		timer.start(timer_duration)

	if	active:
		enable()
	else:
		disable()

func toggle() -> void:
	active = !active
	if active:
		enable()
	else:
		disable()

func _on_timer_timeout() -> void:
	toggle();

func enable():
	animation_player.play("enable")

func disable():
	animation_player.play("disable")

func _interact():
	toggle()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		damage_player(body)
		apply_impulse_to_player(body)

func apply_impulse_to_player(body):
	if body is CharacterBody2D:
		var direction = (body.global_position - global_position).normalized()
		body.apply_impulse(direction, impulse_strength)

func damage_player(body: CharacterBody2D) -> void:
	body.call_deferred("deal_damage", damage)
	apply_impulse_to_player(body)
