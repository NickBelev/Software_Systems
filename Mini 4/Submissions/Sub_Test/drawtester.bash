#!/bin/bash

# Nicholas Belev
# nicholas.belev@mail.mcgill.ca
# Faculty of Science - Computer Science
# DRAWTESTER for ASCII DRAW C PROGRAM

# checks if asciidraw.c exists
if [[ ! -f asciidraw.c ]]
then
	echo "ERROR: Could not locate asciidraw.c"
	exit 1
fi

# compiles in correct format
gcc -o asciidraw asciidraw.c -lm
rc=$?

# if warnings, shows them and exists with the warning code
if [[ $rc -ne 0 ]]
then
	echo "There were errors/warnings upon attempting GCC compilation. Warning Code: $rc"
	exit $rc
fi

#Test 1 - Print a blank canvas
echo ""
echo '---------------------'
echo "TEST 1 - BLANK CANVAS"
echo '---------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
GRID 5 5
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GRID 5 5
DISPLAY
END
ENDOFCMDS

#Test 2 - Some risky commands and potential edge cases 
echo ""
echo '---------------------'
echo "TEST 2 - ODD COMMANDS"
echo '---------------------'
echo "Tests point-rectangles, point-lines, point-circles, shapes that exceed 
the max canvas, off-grid shapes, and partially-on-grid shapes."
echo '---------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
CHAR ^
GRID 200 90
LINE 9,20 8000,4001
LINE 5,5 5,5
CIRCLE 100,38 0
CIRCLE 57,38 2
CHAR O
CIRCLE 72,20 1
RECTANGLE 1,300 80,45
CIRCLE 500,500 200
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
CHAR ^
GRID 200 90
LINE 9,20 8000,4001
LINE 5,5 5,5
CIRCLE 100,38 0
CIRCLE 57,38 2
CHAR O
CIRCLE 72,20 1
RECTANGLE 1,300 80,45
CIRCLE 500,500 200
DISPLAY
END
ENDOFCMDS

#Test 3 - Prints different types of lines
echo ""
echo '----------------------'
echo "TEST 3 - VARIOUS LINES"
echo '----------------------'
echo "Includes sloped and straight lines as well as calling the same line
from coodinates given in two separate orders."
echo '----------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
CHAR x
GRID 80 60
LINE 0,60 40,30
LINE 10,10 10,50
LINE 4,0 1000,0
LINE 20,20 73,42
LINE 73,42 20,20
LINE 5,10 10,15
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
CHAR x
GRID 80 60
LINE 0,60 40,30
LINE 10,10 10,50
LINE 4,0 1000,0
LINE 20,20 73,42
LINE 73,42 20,20
LINE 5,10 10,15
DISPLAY
END
ENDOFCMDS

#Test 4 - Prints concentric circles and 2 crossing lines
echo ""
echo '-----------------------'
echo "TEST 4 - CROSSED CIRCLE"
echo '-----------------------'
echo "Concentric circles created with an X formed by lines."
echo '---------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
CHAR @
GRID 50 50
CIRCLE 25,25 0
CIRCLE 25,25 5
CIRCLE 25,25 16
CHAR 6
LINE 12,14 36,36
LINE 36,14 12,36
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
CHAR @
GRID 50 50
CIRCLE 25,25 0
CIRCLE 25,25 5
CIRCLE 25,25 16
CHAR 6
LINE 12,14 36,36
LINE 36,14 12,36
DISPLAY
END
ENDOFCMDS

#Test 5 - Swapping charaters and drawing the letter N
echo ""
echo '------------------------------------'
echo "TEST 5 - LETTER \"N\" & CHAR CHANGES"
echo '------------------------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
GRID 40 20
CHAR +
LINE 0,19 0,0
CHAR o
LINE 0,19 7,19
CHAR #
LINE 7,12 7,0
CHAR %
LINE 0,0 7,0
CHAR (
LINE 39,0 39,19
CHAR _
LINE 32,7 32,19
CHAR !
LINE 39,19 32,19
CHAR W
LINE 39,0 32,0
CHAR >
LINE 32,0 7,12
CHAR ?
LINE 7,19 32,7
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GRID 40 20
CHAR +
LINE 0,19 0,0
CHAR o
LINE 0,19 7,19
CHAR #
LINE 7,12 7,0
CHAR %
LINE 0,0 7,0
CHAR (
LINE 39,0 39,19
CHAR _
LINE 32,7 32,19
CHAR !
LINE 39,19 32,19
CHAR W
LINE 39,0 32,0
CHAR >
LINE 32,0 7,12
CHAR ?
LINE 7,19 32,7
DISPLAY
END
ENDOFCMDS

#Test 6 - Random shape filler test
echo ""
echo '-----------------------------------------'
echo "TEST 6 - SHAPES, LINES, CHAR SWITCH COMBO"
echo '-----------------------------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
GRID 40 40
LINE 20,20 25,30
CHAR +
CIRCLE 25,25 10
LINE 10,10 15,20
CHAR %
RECTANGLE 30,45 35,35
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GRID 40 40
LINE 20,20 25,30
CHAR +
CIRCLE 25,25 10
LINE 10,10 15,20
CHAR %
RECTANGLE 30,45 35,35
DISPLAY
END
ENDOFCMDS

#Test 7 - Raising input errors
echo ""
echo '------------------------------'
echo "TEST 7 - HANDLING BAD COMMANDS"
echo '------------------------------'
echo "Tests handling bad input or commands that cannot be used before
GRID is set, and ensures program still works."
echo '---------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
GriD 40 50
chArrrgh +
Do you copy?
DISPLAY
CHAR +
CHAR *
GRID 20 10
display
CHAR +
CIRCLE 10,10 10

DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GriD 40 50
chArrrgh +
Do you copy?
DISPLAY
CHAR +
CHAR *
GRID 20 10
display
CHAR +
CIRCLE 10,10 10

DISPLAY
END
ENDOFCMDS

#Test 8 - Print a tic-tac-toe like board with shapes on it
echo ""
echo '--------------------------'
echo "TEST 8 - TIC-TAC-TOE BOARD"
echo '--------------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
CHAR |
LINE 9,0 9,59
LINE 19,0 19,59
CHAR -
LINE 0,19 29,19
LINE 0,39 29,39
CHAR o
CIRCLE 14,29 6
CIRCLE 4,9 6
CIRCLE 24,49 6
CHAR x
LINE 10,1 18,18
LINE 10,18 18,1
LINE 20,1 28,18
LINE 20,18 28,1
LINE 20,20 28,38
LINE 20,38 28,20
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GRID 60 30
CHAR |
LINE 19,0 19,29
LINE 39,0 39,29
CHAR -
LINE 0,9 59,9
LINE 0,19 59,19
CHAR o
CIRCLE 29,14 6
CIRCLE 9,4 6
CIRCLE 49,24 6
CHAR x
LINE 20,1 38,8
LINE 20,8 38,1
LINE 40,1 58,8
LINE 40,8 58,1
LINE 40,10 58,18
LINE 40,18 58,10
DISPLAY
END
ENDOFCMDS

#Test 9 - Huge and off-grid shapes
echo ""
echo '-----------------------------'
echo "TEST 9 - OUT-OF-BOUNDS SHAPES"
echo '-----------------------------'
echo "Tests printing of exclusively out-of-bounds shapes that
may or may not partially be visible on display area."
echo '---------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
GRID 140 70
LINE 20,20 7000,8053
CHAR |
RECTANGLE 80,1000 150,26
CHAR o
CIRCLE 500,500 600
CIRCLE 0,0 17
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
GRID 140 70
LINE 20,20 7000,8053
CHAR |
RECTANGLE 80,1000 150,26
CHAR o
CIRCLE 500,500 600
DISPLAY
END
ENDOFCMDS

#Test 10 - Print a big smiley face
echo ""
echo '--------------------'
echo "TEST 10 - SMILEY FACE"
echo '--------------------'
echo '
~~~~~~~~~~~~~~~~~~
  COMMANDS GIVEN:
~~~~~~~~~~~~~~~~~~
CHAR -
GRID 100 50
CIRCLE 50,25 20
CHAR v
LINE 37,17 49,10
LINE 49,10 63,17
CHAR 0
RECTANGLE 45,24 55,20
CHAR +
CIRCLE 43,31 5
CIRCLE 58,31 5
CHAR x
CIRCLE 43,31 0
CIRCLE 58,31 0
DISPLAY
END
~~~~~~~~~~~~~~~~~~

'
./asciidraw <<ENDOFCMDS
CHAR -
GRID 100 50
CIRCLE 50,25 20
CHAR v
LINE 37,17 49,10
LINE 49,10 63,17
CHAR 0
RECTANGLE 45,24 55,20
CHAR +
CIRCLE 43,31 5
CIRCLE 58,31 5
CHAR x
CIRCLE 43,31 0
CIRCLE 58,31 0
DISPLAY
END
ENDOFCMDS
