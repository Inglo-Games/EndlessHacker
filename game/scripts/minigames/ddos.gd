extends Minigame

const START_VALUE = 50.0
const DRAIN_VALUE = 12.0
const PING_VALUE = 9.0

onready var prog_bar = $minigame/vbox/bar
onready var btn = $minigame/vbox/btn

var running = false

func _ready():
	btn.connect("button_up", self, "_on_ping_btn_pressed")
	prog_bar.value = START_VALUE

func _process(delta):
	if running:
		prog_bar.value -= DRAIN_VALUE * delta
	
	if prog_bar.value <= 0:
		running = false
		emit_signal("game_lost")
	elif prog_bar.value >= 99:
		running = false
		emit_signal("game_won")

func start_minigame():
	btn.grab_focus()
	running = true

func _on_ping_btn_pressed():
	prog_bar.value += PING_VALUE
