# avrpong-hackaday
Final project of the AVR Architecture Course - HackadayU
Check out project page at [Hackaday](https://hackaday.io/project/177973-avr-pong-in-assembly).

### Project Requirements

Create a PONG game. The game has three elements: user paddle, ball, and the computer's paddle. The ball should bounce when it hits the paddle. If the ball misses the paddle, the game is over. The user's paddle is controlled by two pushbuttons, and the computer's paddle is controlled automatically by your code.

The game has to be written entirely in AVR assembly, without relying on any of Arduino's built-in library functions.

### source
Contains the .ino and assembly file used in the project

Check out the simulation at [Wokwi](https://wokwi.com/arduino/projects/291850570244817417).

Shoutout to Wokwi - an amazing Arduino simulator that is wayyy better than Proteus

### misc
Contains a program I wrote to make my time learning AVR assembly easier :D

Calculates the registers used by the arduino compiler to pass arguments in a function
