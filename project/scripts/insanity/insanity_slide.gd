@tool
extends InsanityJump
class_name InsanitySlide


@export_enum("Left", "Right", "Both") var Detection: int = 0

@onready var animation_slide_player: AnimationPlayer = $AnimationPlayer


func _ready():
	super._ready()

func _on_right_body_entered(body:Node2D):
	if body.is_in_group("player") && ( Detection == 1 || Detection == 2):
		animation_slide_player.play("to_right")
		disable_and_die(body)
		

func _on_left_body_entered(body:Node2D):
	if body.is_in_group("player") && ( Detection == 0 || Detection == 2):
		animation_slide_player.play("to_left")
		disable_and_die(body)

func disable_and_die(body:Node2D):
	$Right.set_deferred("monitoring",false)
	$Left.set_deferred("monitoring",false)
	damage_player(body)
	await get_tree().create_timer(1.0).timeout
	queue_free()