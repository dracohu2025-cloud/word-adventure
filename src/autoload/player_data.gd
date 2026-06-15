extends Node

var player_name: String = "Apprentice"
var level: int = 1
var experience: int = 0
var vocation: String = "warrior"

# Primary attributes
var strength: int = 10
var agility: int = 8
var intellect: int = 6
var stamina: int = 12
var spirit: int = 8

# Equipment & inventory
var inventory: Array[Dictionary] = []
var equipment: Dictionary = {}

# Vocabulary progress: word -> { mastery, next_review }
var vocabulary: Dictionary = {}

func _ready() -> void:
    print("PlayerData initialized")

func add_experience(amount: int) -> void:
    experience += amount
    # TODO: level up logic
