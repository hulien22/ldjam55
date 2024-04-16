extends Node

@export var combat_music: AudioStream
@export var serenity: AudioStream
@export var background: AudioStream

@export var pop: AudioStream
@export var countdown_beep: AudioStream
@export var countdown_final_beep: AudioStream

@onready var sound_effects = $SoundEffects
#@onready var background_sound = $background

var music_state

func _ready():
	#background_sound.stream = background
	#background_sound.play()
	music_state = 0

func change_music(combat: bool, boss: bool):
	if (music_state == 1 and !combat and !boss) or (music_state == 2 and combat and !boss) or (music_state == 3 and combat and boss):
		return
	if combat:
		if boss:
			#stream = boss_music
			music_state = 3
		else:
			#stream = combat_music
			music_state = 2
	else:
		#stream = serenity
		music_state = 1
	#play()

func play_pop():
	sound_effects.volume_db = 0
	sound_effects.stream = pop
	sound_effects.play()

func play_click():
	pass
	#sound_effects.stream = concrete
	#sound_effects.play()

func play_success():
	pass
	#trumpet_sound_effects.stream = trumpet_success
	#trumpet_sound_effects.play()
	
func play_fail():
	pass
	#trumpet_sound_effects.stream = trumpet_fail
	#trumpet_sound_effects.play()

func play_countdown_high():
	sound_effects.volume_db = -7
	sound_effects.stream = countdown_final_beep
	sound_effects.play()
	
func play_countdown_low():
	#print("yep playing")
	sound_effects.volume_db = -7
	sound_effects.stream = countdown_beep
	sound_effects.play()
