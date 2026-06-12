extends Node3D
@onready var label = $Label3D
var card_value: int = 0
var is_flipped: bool = false
func set_value(val: int):
	card_value = val
	label.text = str(val)
func flip():
	if is_flipped: return
	is_flipped = true
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:z", 180.0, 0.4).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.2).timeout
	label.show()
