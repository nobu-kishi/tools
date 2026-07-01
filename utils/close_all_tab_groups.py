import pyautogui
import time
import threading
from pynput import keyboard

pyautogui.FAILSAFE = True

STEPS = [
    ("① 3点リーダー（...）ボタン",   "メニューを閉じた状態でボタンの上にマウスを移動", 0.5),
    ("② 「タブ グループ」メニュー項目", "3点リーダーを開き「タブ グループ」の上へ移動",   0.5),
    ("③ 先頭のタブグループ名",         "サブメニューが開いたら先頭のグループ名の上へ移動", 0.4),
    ("④ 「削除」ボタン",               "そのまま「削除」の上へ移動",                       0.8),
]


def record_position(label, hint):
    print(f"\n▶ {label}\n  {hint}")
    for i in range(5, 0, -1):
        print(f"\r  {i}秒後に記録...", end="", flush=True)
        time.sleep(1)
    x, y = pyautogui.position()
    print(f"\r  → ({x}, {y}) 記録完了          ")
    return (x, y)


def run_automation(positions, stop):
    count = 0
    try:
        while not stop.is_set():
            for (label, _, delay), pos in zip(STEPS, positions):
                pyautogui.click(*pos)
                if stop.wait(delay):
                    return
            count += 1
            print(f"削除 {count} 件目")
    except pyautogui.FailSafeException:
        print("\n緊急停止（画面左上端）")
    finally:
        stop.set()
        print(f"\n完了: {count} 件削除しました")


def main():
    print("=== タブグループ一括削除ツール ===\n")
    print("4箇所のクリック位置を順番に記録します（各5秒）\n")
    input("Enterで開始...")
    print("\n  ※②以降はメニューを開いてナビゲートしながら記録します")

    positions = [record_position(label, hint) for label, hint, _ in STEPS]

    print("\n記録完了。Escapeキーで停止できます。")
    print("（マウスを画面左上端へ移動でも緊急停止）\n")

    stop = threading.Event()

    def on_press(key):
        if key == keyboard.Key.esc:
            stop.set()
            return False

    listener = keyboard.Listener(on_press=on_press)
    listener.start()
    run_automation(positions, stop)
    listener.stop()


if __name__ == "__main__":
    main()
