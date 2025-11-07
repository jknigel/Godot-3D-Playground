extends ColorRect
# In your high_score_menu.gd script
@onready var score_container = $ScoreListContainer # A container for the labels

func _ready():
	# Connect to the manager's signal to automatically update when scores change.
	HighScoreManager.scores_updated.connect(update_display)
	# Update the display with the scores that were loaded at the start.
	update_display(HighScoreManager.get_scores())

func update_display(scores):
	# First, clear out any old score labels.
	for child in score_container.get_children():
		child.queue_free()

	# Create a new label for each score in the list.
	for entry in scores:
		var username = entry.name
		var score = entry.score
		
		var new_label = Label.new()
		new_label.text = "%s - %d" % [username, score]
		score_container.add_child(new_label)
