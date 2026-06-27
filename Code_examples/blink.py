import time
import board
import digitalio

# Configure GPIO10 (D10) as an output
led = digitalio.DigitalInOut(board.D21)
led.direction = digitalio.Direction.OUTPUT

while True:
    led.value = True  # Turn on
    time.sleep(2)   # Wait 0.5s
    led.value = False # Turn off
    time.sleep(2)   # Wait 0.5s
