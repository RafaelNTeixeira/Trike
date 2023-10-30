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


## Game Logic

### Internal Game State Representation

GameState is represented as a list with 2 elements, the current Player and the current Board. Board is also represented as a list but it includes sublists that represent rows of the board. Each element of rhose sublists, represents an element in a column. There can be 4 diferent values on the board:

- `0` represents an empty space
- `p` represents a playable space
- `b` represents a space occupied by a black piece
- `w` represents a space occupied by a white piece


Here are some representations of the different states on the game:

##### Initial State
```prolog
GameState = [b, 
    [0],
    [0,0],
    [0,0,0],
    [0,0,0,0],
    [0,0,0,0,0],
    [0,0,0,0,0,0],
    [0,0,0,0,0,0,0],
    [0,0,0,0,0,0],
    [0,0,0,0,0], 
    [0,0,0,0],
    [0,0,0],
    [0,0],
    [0]
].
```

##### Intermediate State
```prolog
GameState = [w, 
    [0],
    [0,b],
    [0,w,0],
    [b,b,0,w],
    [0,0,0,0,0],
    [0,0,0,0,0,0],
    [0,0,0,0,0,0,0],
    [0,0,0,0,0,0],
    [0,0,0,0,0], 
    [0,b,b,0],
    [w,0,w],
    [0,0],
    [0]
].
```

##### Final State
```prolog
GameState = [b, 
    [0],
    [0,b],
    [0,w,0],
    [b,b,0,w],
    [0,0,0,0,0],
    [0,0,0,0,0,0],
    [0,0,0,0,0,0,0],
    [0,0,0,w,0,0],
    [0,0,b,w,b], 
    [0,b,b,w],
    [w,0,w],
    [0,0],
    [0]
].
```
---

### Game State Visualization

##### Game Menu
The game menu is displayed like this:
```prolog
        _________  ______ ______ 
       /_  __/ _ \\/  _/ //_/ __/ 
        / / / , _// // ,< / _/   
       /_/ /_/|_/___/_/|_/___/   

    1. Player Vs Player        
    2. Player Vs Computer (Easy)
    3. Player Vs Computer (Hard)
    4. Computer Vs Computer    
    5. Instructions             
    0. Quit                    
    ___________________________
    SELECT YOUR OPTION!
```
An option is picked by typing a number followed by a `` and pressing the `Enter` key. 

The first 4 options correspond to dynamic stages of the program and the last one to a static page.

By picking the option `0` the following text is displayed:
```prolog
            _________  ______ ______ 
           /_  __/ _ \\/  _/ //_/ __/ 
            / / / , _// // ,< / _/   
           /_/ /_/|_/___/_/|_/___/   

    Thank you for playing. Hope to see you soon

```

##### Board
Once we start a game, the board is displayed like this:

![Board](/docs/board.png)

To display it we use the predicate `display_game(+GameState)`, printing the board and whose turn it is to play.

Also, everytime someone plays, the board is updated to show every move that is possible to take using the predicate `valid_moves(+GameState, +PlayerPos, -ListOfMoves)`:

![BoardPlayables](/docs/boardPlayables.png)

---

### Move Validation and Execution
The `move(+GameState, +Move, -NewGameState)` predicate takes the current game state, the move to take and the new game state resulting from that move. 

Inside that function, we use the predicate `check_if_valid(+Board, +X, +Y)` to check if the move to take is inside the board and if it corresponds to a valid move:

```prolog
check_if_valid(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(X, Board, Row),
    nth0(Y, Row, p).
```

If it is valid, a piece of the corresponding player is placed on the board using the predicate `replace(Board, PointX, PointY, Player, TempBoard)`, the playable moves are remove using the predicate `clean_playables(+TempBoard, -NewBoard)`, the player playing switches and the board with the play made without the possible moves is displayed `display_game(+GameState)`. But, if the move selected isn't valid, a recursive call is made until the player picks a correct play.

For the bot, a predicate `choose_move(+GameState, +Level, -Move)` is called which objective is to pick a valid move using the algorithm according to the difficulty picked initially for the computer.

--- 

### List of Valid Moves

The `valid_moves(+GameState, +PlayerPos, -ListOfMoves)` predicate takes 3 arguments, the current game state, the current player position and a list with all the possible moves that is returned. That list represents the board and is printed showing the player where he can play:
This predicate calls the `swap(+PlayerX, +PlayerY, +Board, -ListOfMoves)` predicate which function is to replace on the board all the empty spaces that could represent a valid move with a `p`. To achieve this, this predicate travels the board vertically, horizontally and diagonally until it reaches the end of the board or finds a `b` or `w`, while replacing every `0` space with a `p`.
```prolog
valid_moves([CurPlayer|Board], [PlayerX, PlayerY], ListOfMoves) :-
    swap(PlayerX, PlayerY, Board, ListOfMoves),
    display_game([CurPlayer|ListOfMoves]).
```


In addition to this, we created a `clean_playables(+Board, -NewBoard)` predicate that replaces every `p` from the board with an empty space `0` so that the players can have an easier view of the current state of the game:
```prolog
clean_playables([], []).
clean_playables([Row|RestOfRows], [NewRow|NewRest]) :-
    replace_p_in_row(Row, NewRow),
    clean_playables(RestOfRows, NewRest).

replace_p_in_row([], []).
replace_p_in_row([p|Rest], [0|NewRest]) :-
    replace_p_in_row(Rest, NewRest).
replace_p_in_row([X|Rest], [X|NewRest]) :-
    X \= p,
    replace_p_in_row(Rest, NewRest).
```

--- 

### End of Game

After the first play, the game is always being ran in a loop inside the predicate `gameplay(+GameState, +PlayerPos, FinalScore, Winner)` or `gameplay_bot(+GameState, +PlayerPos, +Level, -FinalScore, -Winner)` if bots are playing. Inside this predicate there is another predicate that is always checking if the game has ended after every move that was made, namelly `(game_over(GameState)`, that receives the board with all the possible moves:

```prolog
game_over([Player|ListOfMoves]) :-
    check_board(ListOfMoves).
```
- `check_board(ListOfMoves)`: check if there is a 'p' in the board.

 This predicate ends the game if there are no cells marked with `p` (playable spaces) on the board and if this predicate checks for true (there are playable spaces), it means that the game hasn't ended and so the following play is proceeded, but if it checks for false (no playable spaces), the predicate `calculate_final_score(+GameState], +PlayerPos, -FinalScore, -Winner)` is called, identifying the player who won and retrieving the final score that corresponds the number of pieces belonging to that player which are below or around the last piece played.

---


### Computer Plays

All the bots resort to the predicate `choose_move(+GameState, +Level, -Move)` to pick a valid move according to the difficulty (Level) picked at the game menu:

```prolog
choose_move([Player|Board], Level, [PointX, PointY]) :-
    ((Level = 2) -> choose_random_p(Board, PointX, PointY);
        find_p_with_more_w_and_b(Board, PointX, PointY)
    ).
```
If `Level` corresponds to `2`, the `choose_random_p(+Board, -PointX, -PointY)` predicate is called, picking a playable space, marked with `p`, randomly.
Oherwise, the `find_p_with_more_w_and_b(+Board, -PointX, -PointY)` predicate is called to run the algorithm with hardest difficulty available on the game.

To make up a good strategy for an algorithm, after playing and studying the game Trike a bit, we realised that one of best possible moves to make was to place a piece right next to our lastly played piece so that we can always keep the maximum number of checkers around us since the winner is determined by that condition.
With that, we decided to implement our hardest algorithm around that strategy, so the predicate `find_p_with_more_w_and_b(+Board, -PointX, -PointY)` does exactly what was mentioned before:

```prolog
find_p_with_more_w_and_b(Board, Row, Col) :-
    get_p_coordinates(Board, PList),
    process_elements(PList, Board, Results),
    find_max_position(Results, Pos),
    custom_nth1(Pos, PList, (Row, Col)).
```

- `get_p_coordinates(Board, PList)`: checks all the cells of the board and returns all the playable ones (marked with `p`)
- `process_elements(PList, Board, Results)`: process each element in the list and store the scores in a new list. Score is determined by the number of pieces of the player that are around each playable space
- `find_max_position(Results, Pos)`: find the position of the maximum value on the list with the scores
- `custom_nth1(Pos, PList, (Row, Col)`: retrieve the position of the element with the maximum score

--- 

### Conclusions

We are satisfied with the final result of this project, since at the start of the development of this game we felt pressed about how much time we had to finish it but thankfully we ended up completing all the main functionalities that were planned, even if it took us a lot of time and work.
The major difficulties encountered by us while making the project were creating an intuitive board in the SicStus terminal since we don't have many options for how to display it, the debugging of the code since it gets stressful in this programming language and the implementation of some predicates with higher complexity.
Regardless, the development of this game enriched our knowledge in prolog development and made us realize that it was important for us to confront such a different programming environment since it helped us understand how to approach complex problems and structure code in a more logical and rule-driven manner.

#### Possible improvements
If we had more time, we would like to have:

- Implemented the choice of playing in different board sizes
- Improved the algorithm for hard bot difficulty so that it could detect when the opponent could trap it's pieces and prevent it

---


### Bibliography

- Slides from the teorical lessons
- https://sicstus.sics.se/sicstus/docs/latest4/html/sicstus.html/

---


### Sources

> **Game Website and Rules:** (https://boardgamegeek.com/boardgame/307379/trike)

> **Online Gameplay:** (https://pt.boardgamearena.com/gamepanel?game=trike)
