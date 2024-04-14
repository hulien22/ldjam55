class_name kill_feed_item
extends Panel

var killer_text = "some text"
var killed_text = "some text"

func _ready():
	$killer_text.text = "[right]" + killer_text
	$killed_text.text = killed_text

func set_data(killer: npc_base_stats, killed: npc_base_stats):
	killer_text = get_text(killer)
	killed_text = get_text(killed)

func get_text(contestant: npc_base_stats):
	return contestant.first_name + " '" + str(contestant.number)  + "' " + contestant.last_name
	#return "Contestant " + str(contestant.number) + "\n" + contestant.first_name + " " + contestant.last_name
