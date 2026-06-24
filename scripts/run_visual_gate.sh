#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-word_castle_portrait}"

if [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
  GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN="$(command -v godot)"
else
  echo "未找到 Godot。请安装 Godot，或把 godot 加入 PATH。" >&2
  exit 1
fi

case "$TARGET" in
  pc_village)
    TEST_SCENES=(
      "res://scenes/tests/test_main_menu.tscn"
      "res://scenes/tests/test_village_visual_pass.tscn"
    )
    CAPTURE_SCENES=(
      "res://scenes/tests/capture_main_menu_visual.tscn"
      "res://scenes/tests/capture_village_visual.tscn"
    )
    OUTPUT_FILES=(
      "${ROOT}/.tmp_assets/main_menu_visual_pass.png"
      "${ROOT}/.tmp_assets/village_visual_pass.png"
    )
    ;;
  word_castle_portrait)
    TEST_SCENES=("res://scenes/tests/test_word_castle_portrait_prototype.tscn")
    CAPTURE_SCENES=("res://scenes/tests/capture_word_castle_portrait_prototype.tscn")
    OUTPUT_FILES=("${ROOT}/.tmp_assets/word_castle_portrait_prototype.png")
    ;;
  *)
    echo "未知视觉验收目标：${TARGET}" >&2
    echo "可用目标：pc_village, word_castle_portrait" >&2
    exit 1
    ;;
esac

cd "$ROOT"

echo "==> Godot import"
"$GODOT_BIN" --headless --path "$ROOT" --import

for test_scene in "${TEST_SCENES[@]}"; do
  echo "==> Behavior/layout regression: ${test_scene}"
  "$GODOT_BIN" --headless --path "$ROOT" --scene "$test_scene"
done

for capture_scene in "${CAPTURE_SCENES[@]}"; do
  echo "==> Visual capture: ${capture_scene}"
  "$GODOT_BIN" --path "$ROOT" --scene "$capture_scene"
done

for output_file in "${OUTPUT_FILES[@]}"; do
  if [[ ! -s "$output_file" ]]; then
    echo "截图未生成或为空：${output_file}" >&2
    exit 1
  fi

  echo "==> 截图已生成：${output_file}"
done

echo "请人工检查：文字出框、按钮遮挡、容器素材化、构图、可玩区视觉焦点。"
