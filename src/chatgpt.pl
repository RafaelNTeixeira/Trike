% Trike game with pie rule

% Define the initial game state with an empty board and a neutral pawn.
initial_board([
    [empty, empty, empty],
    [empty, empty, empty, empty],
    [empty, empty, empty, empty, empty],
    [empty, empty, empty, empty],
    [empty, empty, empty],
    [empty, empty, empty]
]).

% Define the initial player who chooses the color.
initial_player(black).

% Define the main game loop.
play :-
    initial_board(Board),
    initial_player(Player),
    display_board(Board),
    play_game(Board, Player, black, FinalScore),
    report_winner(FinalScore).

% Display the current state of the board.
display_board(Board) :-
    nl,
    display_rows(Board, 0),
    nl.

display_rows([], _).
display_rows([Row | Rest], N) :-
    print_padding(N),
    display_row(Row, N),
    NextN is N + 1,
    display_rows(Rest, NextN).

display_row([], _).
display_row([Cell | Rest], N) :-
    write(Cell),
    write(' '),
    display_row(Rest, N).

print_padding(N) :-
    N > 0,
    write(' '),
    NextN is N - 1,
    print_padding(NextN).
print_padding(0).

% Check if a point is inside the board.
is_inside(Board, X, Y) :-
    length(Board, Rows),
    Y >= 0,
    Y < Rows,
    nth0(Y, Board, Row),
    length(Row, Cols),
    X >= 0,
    X < Cols.

% Check if a point is empty.
is_empty(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(Y, Board, Row),
    nth0(X, Row, empty).

% Apply the pie rule. The first player chooses a starting point.
apply_pie_rule(Board, Player, NewBoard) :-
    display_board(Board),
    write('Player '), write(Player), write(', choose a starting point (X Y): '),
    read(PointX), read(PointY),
    (is_empty(Board, PointX, PointY) ->
        update_board(Board, Player, PointX, PointY, NewBoard);
        write('Invalid choice. Try again.\n'),
        apply_pie_rule(Board, Player, NewBoard)
    ).

% Play the game.
play_game(Board, Player, LastPlayer, FinalScore) :-
    (game_over(Board, LastPlayer) ->
        calculate_final_score(Board, Player, FinalScore);
        make_move(Board, Player, NewBoard),
        switch_player(Player, NextPlayer),
        play_game(NewBoard, NextPlayer, Player, FinalScore)
    ).

% Check if the game is over (the pawn is trapped).
game_over(Board, LastPlayer) :-
    \+ can_move(Board, 0, 0), % If the pawn can't move from the center, it's trapped.
    switch_player(LastPlayer, LastOpponent),
    can_move(Board, 0, 0, LastOpponent). % Check if the opponent can make any move.

% Calculate the final score at the end of the game.
calculate_final_score(Board, Player, Score) :-
    findall(Point, adjacent_or_under(Board, 0, 0, Player, Point), Points),
    length(Points, Score).

% Check if a player can move the pawn to a different location.
can_move(Board, X, Y) :- is_empty(Board, X, Y).
can_move(Board, X, Y, Player) :- is_empty(Board, X, Y), checkers_around(Board, X, Y, Player, _).

% Make a move by placing a checker and moving the pawn.
make_move(Board, Player, NewBoard) :-
    display_board(Board),
    write('Player '), write(Player), write(', make a move (X Y): '),
    read(PointX), read(PointY),
    (valid_move(Board, Player, PointX, PointY) ->
        update_board(Board, Player, PointX, PointY, NewBoard);
        write('Invalid move. Try again.\n'),
        make_move(Board, Player, NewBoard)
    ).

% Check if a move is valid.
valid_move(Board, Player, PointX, PointY) :-
    is_empty(Board, PointX, PointY),
    \+ game_over(Board, Player), % Check if the game is not over.
    checkers_around(Board, PointX, PointY, Player, _). % Check if there are adjacent checkers of the same color.

% Update the board with a new move.
update_board(Board, Player, PointX, PointY, NewBoard) :-
    switch_player(Player, Opponent),
    replace(Board, PointX, PointY, Player, TempBoard),
    move_pawn(TempBoard, PointX, PointY, NewBoard, Opponent).

% Replace a cell in the board with a new value.
replace([Row | Rest], 0, Y, NewValue, [NewRow | Rest]) :-
    replace_in_row(Row, 0, Y, NewValue, NewRow).
replace([Row | Rest], X, Y, NewValue, [Row | NewRest]) :-
    X > 0,
    X1 is X - 1,
    replace(Rest, X1, Y, NewValue, NewRest).

replace_in_row([_ | Rest], 0, Y, NewValue, [NewValue | Rest]) :-
    Y = 0.
replace_in_row([Value | Rest], X, Y, NewValue, [Value | NewRest]) :-
    Y > 0,
    Y1 is Y - 1,
    replace_in_row(Rest, X, Y1, NewValue, NewRest).

% Move the pawn to a new location.
move_pawn(Board, PointX, PointY, NewBoard, Opponent) :-
    replace(Board, PointX, PointY, neutral, TempBoard),
    write('Move the pawn to (X Y): '),
    read(NewX), read(NewY),
    (can_move_pawn(TempBoard, PointX, PointY, NewX, NewY) ->
        replace(TempBoard, NewX, NewY, neutral, NewBoard);
        write('Invalid pawn move. Try again.\n'),
        move_pawn(Board, PointX, PointY, NewBoard, Opponent)
    ).

% Check if the pawn can move to a new location.
can_move_pawn(Board, X, Y, NewX, NewY) :-
    is_empty(Board, NewX, NewY),
    (X =:= NewX ; Y =:= NewY ; abs(X - NewX) =:= abs(Y - NewY)),
    \+ jump_over_checkers(Board, X, Y, NewX, NewY).

% Check if the pawn can jump over checkers.
jump_over_checkers(_, X, Y, X, Y).
jump_over_checkers(Board, X, Y, NewX, NewY) :-
    (X =:= NewX, Y < NewY - 1, Y1 is Y + 1 ; Y =:= NewY, X < NewX - 1, X1 is X + 1 ; X < NewX - 1, Y < NewY - 1, X1 is X + 1, Y1 is Y + 1),
    is_empty(Board, X1, Y1),
    jump_over_checkers(Board, X1, Y1, NewX, NewY).

% Check if there are adjacent checkers of the same color.
checkers_around(Board, X, Y, Player, Checkers) :-
    findall(Point, adjacent_or_under(Board, X, Y, Player, Point), Checkers),
    length(Checkers, Count),
    Count >= 2. % There must be at least 2 adjacent checkers to make a move.

% Find all adjacent or under checkers of the same color.
adjacent_or_under(Board, X, Y, Player, Point) :-
    adjacent(Board, X, Y, Player, Point).
adjacent_or_under(Board, X, Y, Player, Point) :-
    under(Board, X, Y, Player, Point).

% Check if a point is adjacent to the given player checker.
adjacent(Board, X, Y, Player, Point) :-
    is_adjacent(X, Y, AdjX, AdjY),
    is_inside(Board, AdjX, AdjY),
    nth0(AdjY, Board, Row),
    nth0(AdjX, Row, Player),
    Point = [AdjX, AdjY].

% Check if a point is under the given player checker.
under(Board, X, Y, Player, Point) :-
    Y1 is Y + 1,
    is_inside(Board, X, Y1),
    nth0(Y1, Board, Row),
    nth0(X, Row, Player),
    Point = [X, Y1].

% Helper to determine if two points are adjacent.
is_adjacent(X1, Y1, X2, Y2) :-
    (X1 =:= X2, Y1 =:= Y2 - 1) ;
    (X1 =:= X2, Y1 =:= Y2 + 1) ;
    (X1 =:= X2 - 1, Y1 =:= Y2) ;
    (X1 =:= X2 + 1, Y1 =:= Y2).

% Switch the current player.
switch_player(black, white).
switch_player(white, black).

% Start the game.
start :-
    initial_board(Board),
    initial_player(Player),
    apply_pie_rule(Board, Player, NewBoard),
    switch_player(Player, Opponent),
    play_game(NewBoard, Opponent, Player, FinalScore),
    report_winner(FinalScore).

% Report the winner of the game.
report_winner(Score) :-
    (Score > 0 ->
        write('Player with the most adjacent or under checkers wins.\n'),
        write('Player with '),
        write(Score),
        write(' points wins the game.\n');
        write('It\'s a draw! No one wins.')
    ).

% Start the game when the script is run.
:- start.
