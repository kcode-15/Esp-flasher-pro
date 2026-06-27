import board
import neopixel

# Define the pin and number of pixels
pixels = neopixel.NeoPixel(board.NEOPIXEL, 1)

while True:
    pixels[0] = (255, 0, 0) # Set first pixel to Red (R, G, B)
