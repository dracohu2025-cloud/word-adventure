extends Node

const DEFAULT_PACK_PATH: String = "res://data/vocabulary/village_a1.json"

var _words_by_id: Dictionary = {}

func _ready() -> void:
    load_pack(DEFAULT_PACK_PATH)

func load_pack(path: String) -> void:
    _words_by_id.clear()
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Unable to open word pack: " + path)
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Invalid word pack: " + path)
        return

    for word_data in parsed.get("words", []):
        var word := String(word_data.get("word", ""))
        if not word.is_empty():
            _words_by_id[word] = word_data

func build_challenge(word: String, challenge_type: String) -> Dictionary:
    var data: Dictionary = _words_by_id.get(word, {})
    if data.is_empty():
        return {}

    match challenge_type:
        "meaning":
            return {
                "challenge_type": "meaning",
                "word": word,
                "question": data.get("meaning", ""),
                "options": data.get("meaning_options", _fallback_options(word)),
                "answer": word,
                "success_line": "The page glows with the correct word.",
                "failure_line": "The letters scatter. Try again.",
            }
        "spelling":
            return {
                "challenge_type": "spelling",
                "word": word,
                "question": data.get("meaning", ""),
                "answer": word,
                "success_line": "The spelling settles into the book.",
                "failure_line": "The inscription is still scrambled.",
            }
        "context":
            return {
                "challenge_type": "context",
                "word": word,
                "question": data.get("context_prompt", data.get("example", "")),
                "options": data.get("context_options", _fallback_options(word)),
                "answer": word,
                "success_line": "The sentence is restored.",
                "failure_line": "That word does not fit here yet.",
            }
    return {}

func has_word(word: String) -> bool:
    return _words_by_id.has(word)

func _fallback_options(answer: String) -> Array[String]:
    var options: Array[String] = [answer]
    for word in _words_by_id.keys():
        if word != answer:
            options.append(word)
        if options.size() >= 4:
            break
    return options
