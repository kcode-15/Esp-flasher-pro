import board
import digitalio

button = digitalio.DigitalInOut(board.BUTTON_A) # Pin depends on board
button.direction = digitalio.Direction.INPUT
button.pull = digitalio.Pull.DOWN # Or Pull.UP based on wiring

led = digitalio.DigitalInOut(board.LED)
led.direction = digitalio.Direction.OUTPUT

while True:
    led.value = button.value # LED turns on while button is held
