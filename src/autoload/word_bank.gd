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
                "question": "选择“%s”对应的英文单词。" % data.get("meaning", ""),
                "options": data.get("meaning_options", _fallback_options(word)),
                "answer": word,
                "success_line": "答对了，书页亮起来了。",
                "failure_line": "字母还在乱飞，再试一次。",
            }
        "spelling":
            return {
                "challenge_type": "spelling",
                "word": word,
                "question": "请输入“%s”对应的英文单词。" % data.get("meaning", ""),
                "answer": word,
                "success_line": "拼写正确，文字回到了书页上。",
                "failure_line": "拼写还不对，再检查一下。",
            }
        "context":
            return {
                "challenge_type": "context",
                "word": word,
                "question": "选择能填入句子的英文单词：\n%s" % data.get("context_prompt", data.get("example", "")),
                "options": data.get("context_options", _fallback_options(word)),
                "answer": word,
                "success_line": "句子恢复完整了。",
                "failure_line": "这个词还不适合这里。",
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
