#!/usr/bin/env python3
import time
import glob
import sys
import subprocess


def get_port():
   ##get searial port
    if sys.platform.startswith('darwin'):  # Mac
        ports = glob.glob('/dev/cu.usb*')
    else:
        ports = glob.glob('/dev/ttyUSB*') + glob.glob('/dev/ttyACM*')
    return ports[0] if ports else None


def esp_flasher():
    logo = r"""
        _____ ____  ____  _____ _        _    ____  _   _ _____ ____  
       | ____/ ___||  _ \|  ___| |      / \  / ___|| | | | ____|  _ \ 
       |  _| \___ \| |_) | |_  | |     / _ \ \___ \| |_| |  _| | |_) |
       | |___ ___) |  __/|  _| | |___ / ___ \ ___) |  _  | |___|  _ < 
       |_____|____/|_|   |_|   |_____/_/   \_\____/|_| |_|_____|_| \_\
       """

    welcome_message = """
       =====================================================================
       |                     Welcome to Espflasher                         |
       =====================================================================
       """
    info_message = """
       ======================================================================
       |              Use this tool to flash Circuitpython                  |
       ======================================================================
          """

    first_question = "What script would you like to use? "

    print(welcome_message)
    print(logo)
    print(info_message)

    # wait for board to be found
    usb_port = None
    print("🔍 Searching for board... (Plug me in now)")

    while not usb_port:
        usb_port = get_port()
        if not usb_port:
            time.sleep(1)  # check every second
        else:
            print(f"✅ Board detected on: {usb_port}")


    while True:
        # define the scripts
        scripts = {
            "blink": ["cp", "Code_examples/neopixel.py", "/Volumes/CIRCUITPY"],
            "button and led": ["cp", "Code_examples/neopixel.py", "/Volumes/CIRCUITPY"],
            "neopixel": ["cp", "Code_examples/neopixel.py", "/Volumes/CIRCUITPY"],
            "i2c scan": ["cp", "Code_examples/scan_i2c_devices.py", "/Volumes/CIRCUITPY"],
            "buzzer": ["cp", "Code_examples/buzzer.py", "/Volumes/CIRCUITPY"],
            "install tio": ["brew", "install", "tio"],
            "exit": None
        }

        print("\n" + "=" * 40)
        print(f"Available: {', '.join(scripts.keys())}")
        choice = input("What script would you like to use? ").strip().lower()

        if choice == "exit":
            print("Exiting...")
            break

        if choice in scripts:
            print(f"\n⚡ Running {choice}...")
            try:
                subprocess.run(scripts[choice], check=True)
                print("✨ Done.now if your script requires output use wizard to install tio then reset board and in the terminal use tio")
            except Exception as e:
                print(f"❌ Error: {e}")
        else:
            print("❓ Unknown script.")


if __name__ == "__main__":
    try:
        esp_flasher()
    except KeyboardInterrupt:
        print("\nGoodbye!")
        sys.exit()
