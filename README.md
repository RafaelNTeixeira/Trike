# Trike

**Group:** Trike_1

- João Pedro Moreira Costa (up202108714@.up.pt)
- Rafael Neves Teixeira (up202108831@up.pt)

## Installation and Execution
To play the game it is required to have installed at least the 4.8.0 version of SICStus Prolog and the folder `src` that contains the code for the game functioning.

After having the requirements mentioned previously, on the SICStus interpreter, we need to consult the `play.pl` file located in the folder src:

```prolog
?- consult('play.pl').
```
If using Windows, we can click on the options `File` -> `Consult` -> select the `play.pl` file and then run the play predicate in the interpreter:

```prolog
?- play.
```


## Description of the Game

-  `Game Board:` Trike is played on an equilateral triangular hexagon-tessellated grid but since there isn't a good way to represent it in code language we had to opt out for a pyramid grid.
- `Number of Players:` The game is played by 2 players who choose which colour they want to play with, black or white.
- `Game Components:` The game employs a pinned checker (the current last placed checker) either black or white whether it was the player playing with black or white checkers who placed it (represented as `b` or `w`, respectively) and black/white checkers to represent the two players (represented as `B` and `W`, respectively).
- `Game Objective:` The primary objective is to trap the pinned checker, and at the end of the game, accumulate as many points as possible.
- `Movement:` Players take turns moving the pinned checker around the board. Passing is not allowed. The pawn can move any number of empty points in a straight line, in any direction, but cannot land on or jump over occupied points.
- `Game Progression:` When a player moves the pawn, they must first place a checker of their own colour onto the destination point and then move the pawn on top of it.
- `Winning:` The game ends when the pawn becomes trapped. The player with the most points wins.
- `Scoring:` At the game's conclusion, each player scores one point for every checker of their own colour that is adjacent to or underneath the pawn.
- `Pie Rule:` Before the game begins, the first player selects a colour and places a checker on any point of the board, with the pawn on top. At this point, the second player has a one-time opportunity to switch sides rather than make a regular move.

> **Game Website and Rules:** (https://boardgamegeek.com/boardgame/307379/trike)

> **Online Gameplay:** (https://pt.boardgamearena.com/gamepanel?game=trike)



## Game Logic
