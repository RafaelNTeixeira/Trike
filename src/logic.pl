initial_player(b).

switch_player(b, w).
switch_player(w, b).

% play_game will receive Level variable
play_game :- 
    initial_state(8, GameState),
    initial_player(Player),
    write('\nPlayer 1 starts with the black pieces\n'), nl,
    write('Player 2 starts with the white pieces\n'), nl,
    pie_rule(GameState, NewBoard),
    switch_player(Player, Opponent),
    % gameplay(NewBoard, Opponent, Player, FinalScore), % play_game
    write('gameplay\n'),   
    % report_winner(FinalScore),
    write('report_winner\n').

update_board_first_play(Board, Player, PointX, PointY, NewBoard) :-
    replace(Board, PointX, PointY, Player, NewBoard),
    display_board(NewBoard).

update_board(Board, Player, PointX, PointY, NewBoard) :-
    replace(Board, PointX, PointY, Player, TempBoard),
    display_board(TempBoard),
    move_pawn(TempBoard, PointX, PointY, NewBoard, Opponent),
    write('move_pawn\n'),
    display_board(NewBoard),
    write('display_board\n').

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

move_pawn(Board, PointX, PointY, NewBoard, Opponent) :-
    replace(Board, PointX, PointY, neutral, TempBoard),
    write('X position to place your piece: '),
    read(NewY), 
    write('Y position to place your piece: '),
    read(NewX),
    (can_move_pawn(TempBoard, PointX, PointY, NewX, NewY) ->
        write('can move pawn\n'),
        replace(TempBoard, NewX, NewY, neutral, NewBoard),
        write('can replace pawn\n');
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

pie_rule([Player|Board], NewBoard) :-
    display_board(Board),
    write('Player '), write(Player), write(', choose an X starting point:'),
    read(PointX),
    write('Player '), write(Player), write(', now choose an Y starting point: '),
    read(PointY),
    (is_empty(Board, PointX, PointY) ->
        replace(Board, PointX, PointY, Player, TempBoard),
        nl, nl,
        write('Player 1\'s play:\n'),
        display_board(TempBoard),
        write('Player Whites, do you want to switch colors?\n'),
        write('1. Yes'), nl, write('2. No'), nl,
        read(Choice),
        (Choice =:= 1 -> CurPlayer = b; Choice =:= 2 -> CurPlayer = w; CurPlayer = w), % fazer função que faz a troca
        switch_player(CurPlayer, Opponent), nl,
        write('\nPlayer 2\'s play:\n'),
        update_board_first_play(TempBoard, CurPlayer, PointX, PointY, NewBoard),
        (Choice =:= 1 -> 
            write('\nPlayer 1 is now playing with the white pieces\n'),
            write('Player 2 is now playing with the black pieces\n'); true);
        write('Invalid choice. Try again.\n'),
        pie_rule([Player|Board], NewBoard)
    ).

% Checks if a point is empty.
is_empty(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(X, Board, Col),
    nth0(Y, Col, 0).

% Check if a point is inside the board.
is_inside(Board, X, Y) :-
    length(Board, Rows),
    X >= 0,
    X < Rows,
    nth0(X, Board, Row),
    length(Row, Cols),
    Y >= 0,
    Y < Cols.

/*
checkificanplay(GameState, Row, Column) :- 
    Row1 is Row - 48, % 0 is 48.
    Column1 is Column - 97, % a is 97.
    get_element_at_index(GameState, Row, RowList),
    get_element_at_index(RowList, Column, Elem),
    is_zero(Elem).
*/

/*
chooseposition(GameState, Row, Column) :-
    repeat,
    write("Choose the starting position."),
    write("Choose Row (The row between 1 - 8): "),
    read(Row),
    write("Choose Column (The column between a - o): "),
    read(Column),
    checkificanplay(GameState, Row, Column).
*/

% play_game
gameplay(Board, Player, LastPlayer, FinalScore) :-
    (game_over(Board, LastPlayer) ->
        calculate_final_score(Board, Player, FinalScore);
        make_move(Board, Player, NewBoard),
        switch_player(Player, NextPlayer),
        gameplay(NewBoard, NextPlayer, Player, FinalScore)
    ).

game_over(Board, LastPlayer) :-
    \+ can_move(Board, 0, 0), % If the pawn can't move from the center, it's trapped.
    switch_player(LastPlayer, LastOpponent),
    can_move(Board, 0, 0, LastOpponent). % Check if the opponent can make any move.

can_move(Board, X, Y) :- is_empty(Board, X, Y).
can_move(Board, X, Y, Player) :- 
    is_empty(Board, X, Y), 
    checkers_around(Board, X, Y, Player, _).

calculate_final_score(Board, Player, Score) :-
    findall(Point, adjacent_or_under(Board, 0, 0, Player, Point), Points),
    length(Points, Score).

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

is_adjacent(X1, Y1, X2, Y2) :-
    (X1 =:= X2, Y1 =:= Y2 - 1) ;
    (X1 =:= X2, Y1 =:= Y2 + 1) ;
    (X1 =:= X2 - 1, Y1 =:= Y2) ;
    (X1 =:= X2 + 1, Y1 =:= Y2).

% Check if a point is under the given player checker.
under(Board, X, Y, Player, Point) :-
    Y1 is Y + 1,
    is_inside(Board, X, Y1),
    nth0(Y1, Board, Row),
    nth0(X, Row, Player),
    Point = [X, Y1].

% Report the winner of the game.
report_winner(Score) :-
    (Score > 0 ->
        write('Player with the most adjacent or under checkers wins.\n'),
        write('Player with '),
        write(Score),
        write(' points wins the game.\n');
        write('It\'s a draw! No one wins.')
    ).