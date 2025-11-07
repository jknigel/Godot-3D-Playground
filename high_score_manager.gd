# high_score_manager.gd
extends Node

# A signal to let the UI know when the high score list has changed.
signal scores_updated(scores)

# The maximum number of scores we want to store.
const MAX_SCORES = 3
# The path to our JSON save file. "user://" is the standard place for save data.
const SAVE_PATH = "res://highscores.json"

# This array will hold our list of high scores in memory.
# Each entry will be a dictionary: {"name": "PLAYER", "score": 1234}
var high_scores = []


# This function runs automatically when the game starts (because it's an Autoload).
func _ready():
	load_scores()


# --- Public Functions (callable from anywhere) ---

# Call this from your game over screen to submit a player's score.
# It returns true if the score made it to the list, false otherwise.
func submit_score(player_name, new_score):
	# First, check if this score is high enough to be on the list.
	if not is_high_score(new_score):
		return false # The score wasn't high enough.

	# Create the new entry.
	var new_entry = {"name": player_name, "score": new_score}
	
	# Add the new score to our list.
	high_scores.append(new_entry)
	
	# Sort the list so the highest score is at the top.
	# We use a custom lambda function to tell sort how to compare two dictionaries.
	high_scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Trim the list to make sure it's not longer than MAX_SCORES.
	while high_scores.size() > MAX_SCORES:
		high_scores.pop_back() # Removes the last (lowest) element.
		
	# Save the updated list to the file.
	save_scores()
	# Announce that the scores have been updated for any UI listening.
	scores_updated.emit(high_scores)
	
	return true


# Call this from your UI script to get the current list of scores.
func get_scores():
	return high_scores


# --- Private Helper Functions (for internal use) ---

# Checks if a score is good enough to make the list.
func is_high_score(score):
	# If the list isn't full yet, any score is a high score!
	if high_scores.size() < MAX_SCORES:
		return true
		
	# If the list is full, the new score must be higher than the lowest score on the list.
	# The lowest score is the last one, since we keep the list sorted.
	var lowest_score = high_scores.back().score
	return score > lowest_score


# --- File I/O Functions ---

func load_scores():
	# Check if the save file doesn't exist.
	if not FileAccess.file_exists(SAVE_PATH):
		# Create the placeholder data and save it.
		_create_placeholder_scores()
		save_scores()
		return

	# Open the existing file.
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	
	# Parse the JSON text into Godot data.
	var json_data = JSON.parse_string(content)
	
	# Check if the data is valid. If the file was corrupted, it might be null.
	if typeof(json_data) == TYPE_ARRAY:
		high_scores = json_data
	else:
		# The file was corrupted or empty, so create fresh placeholder data.
		_create_placeholder_scores()
		save_scores()
	
	# Announce the initial scores have been loaded.
	scores_updated.emit(high_scores)


func save_scores():
	# Convert our high_scores array into a nicely formatted JSON string.
	var json_string = JSON.stringify(high_scores, "\t")
	
	# Open the file for writing and save the string.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_string)


func _create_placeholder_scores():
	# Fulfills the request to have one placeholder score to start with.
	high_scores = []
