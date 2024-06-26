class_name npc_audio
extends AudioStreamPlayer2D

@export var attack_streams: Array[AudioStream]
@export var hurt_streams: Array[AudioStream]
@export var death_streams: Array[AudioStream]

var dying = false

func play_death():
	if dying:
		return
	dying = true
	connect("finished", on_finished)
	var grand_parent = get_parent().get_parent()
	var parent = get_parent()
	get_parent().remove_child(self)
	grand_parent.add_child(self)
	position = parent.position
	var audio = death_streams[randi_range(0, len(death_streams)-1)]
	stream = audio
	play()

func on_finished():
	queue_free()

func play_hurt():
	if dying:
		return
	var audio = hurt_streams[randi_range(0, len(hurt_streams)-1)]
	stream = audio
	play()

func play_attack():
	if dying:
		return
	var audio = attack_streams[randi_range(0, len(attack_streams)-1)]
	stream = audio
	play()
