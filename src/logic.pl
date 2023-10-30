initial_player(b).

switch_player(b, w).
switch_player(w, b).

print_indication :-
    write('============================================'), nl,
    write('Player b = Player with the black pieces (b)'), nl,
    write('Player w = Player with the white pieces (w)'), nl,
    write('============================================'), nl, nl,
    write('\nPlayer 1 starts with the black pieces\n'),
    write('Player 2 starts with the white pieces\n'), nl.

play_game_bot(Level) :-
    initial_state(8,GameState),
    print_indication,
    pie_rule_bot(GameState, PlayerPos, NewGameState),
    gameplay_bot(NewGameState, PlayerPos, Level, FinalScore, Winner),
    report_winner(FinalScore, Winner).


play_game :- 
    initial_state(8, GameState),
    print_indication,
    pie_rule(GameState, PlayerPos, NewGameState),
    gameplay(NewGameState, PlayerPos, FinalScore, Winner), % play_game
    write('gameplay\n'),
    report_winner(FinalScore, Winner),
    write('report_winner\n').

gameplay([Player|Board], PlayerPos, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    ((game_over([Player|ListOfMoves]))-> 
        write('Player '), write(Player), write(', choose an X starting point:'),
        read(PointX),
        write('Player '), write(Player), write(', now choose an Y starting point: '),
        read(PointY),
        Move = ([PointX, PointY]),
        move([Player|ListOfMoves], Move, [NewPlayer|NewBoard]), 
        gameplay([NewPlayer|NewBoard], Move, FinalScore, Winner);

        calculate_final_score([Player|Board], PlayerPos, FinalScore, Winner)
    ).

game_over([Player|ListOfMoves]) :-
    check_board(ListOfMoves).

valid_moves([CurPlayer|Board], [PlayerX, PlayerY], ListOfMoves) :-
    swap(PlayerX, PlayerY, Board, ListOfMoves),
    display_game([CurPlayer|ListOfMoves]).
    
calculate_final_score([Player|Board], [PlayerX, PlayerY], Score, Winner) :-
    count_around_end(Board, PlayerX, PlayerY, [0,0], ListOfScores),
    find_max(ListOfScores, Score),
    find_max_position(ListOfScores, Res),
    ((Res = 0) -> Winner = w;
        (Res = 1) -> Winner = b;
            Winner = t   
    ).


/*------------------------------------------------------------------------------------*/

increment_first([OldFirst | Rest], [NewFirst | Rest]) :-
    NewFirst is OldFirst + 1.

increment_second(List, NewList) :-
    increment_second_helper(List, NewList, 0).

increment_second_helper([], [], _).
increment_second_helper([H|T], [NewH|T], Index) :-
    Index =:= 1, % Check if the current index is 1 (the second element)
    NewH is H + 1.
increment_second_helper([H|T], [H|NewT], Index) :-
    Index \= 1, % Index is not 1, so keep the element as is
    NewIndex is Index + 1,
    increment_second_helper(T, NewT, NewIndex).

/*------------------------------------------------------------------------------------*/

count_around_end(Board, Row, Col, Start, ListOfScores) :-
    count_around_end_up(Board, Row, Col, Start, Temp1),
    count_around_end_down(Board, Row, Col, Temp1, Temp2),
    count_around_end_left(Board, Row, Col, Temp2, Temp3),
    count_around_end_right(Board, Row, Col, Temp3, Temp4),
    count_around_end_diagonal1(Board, Row, Col, Temp4, Temp5),
    count_around_end_diagonal2(Board, Row, Col, Temp5, Temp6),
    count_around_end_diagonal3(Board, Row, Col, Temp6, Temp7),
    count_around_end_diagonal4(Board, Row, Col, Temp7, Temp8),
    count_around_end_under(Board, Row, Col, Temp8, ListOfScores).
    % print_list(ListOfScores).

count_around_end_up(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ((RowAbove < 0) -> ListOfScores = Start; 
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(Col, RowAboveList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_down(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    ((RowBelow > 12) -> ListOfScores = Start;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(Col, RowBelowList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_left(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    ((ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(ColLeft, RowList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_right(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    length(RowList, Len),
    Len1 is Len - 1,
    ColRight is Col + 1,
    ((ColRight > Len1) -> ListOfScores = Start;
        custom_nth1(ColRight, RowList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_diagonal1(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    ((RowAbove < 0 ; ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(ColLeft, RowAboveList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_diagonal2(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    ((RowBelow > 12 ; ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(ColLeft, RowBelowList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

count_around_end_diagonal3(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ColRight is Col + 1,
    ((RowAbove < 0) -> ListOfScores = Start;
        custom_nth1(RowAbove, Board, RowAboveList), 
        length(RowAboveList, Len),
        Len1 is Len - 1,
        (ColRight > Len1) -> ListOfScores = Start;
            custom_nth1(ColRight, RowAboveList, Elem),
            ((Elem = w) -> increment_first(Start, ListOfScores);
                (Elem = b) -> increment_second(Start, ListOfScores);
                    ListOfScores = Start
            )
    ).

count_around_end_diagonal4(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    ColRight is Col + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    length(RowBelowList, Len),
    Len1 is Len - 1,
    ((RowBelow > 12 ; ColRight > Len1) -> ListOfScores = Start;
        custom_nth1(ColRight, RowBelowList, Elem),
        ((Elem = w) -> increment_first(Start, ListOfScores);
            (Elem = b) -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).


count_around_end_under(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    custom_nth1(Col, RowList, Elem),
    ((Elem = w) -> increment_first(Start, ListOfScores);
        (Elem = b) -> increment_second(Start, ListOfScores);
            ListOfScores = Start
    ).

/*------------------------------------------------------------------------------------*/
% Base case: If the list contains only one element, its position is 0.
max_position([MaxValue], 0) :- !.

% Recursive case:
% - Find the maximum position of the tail of the list.
% - If the head of the list is greater than or equal to the maximum of the tail,
%   the maximum position of the list is 0 (the current position).
% - If the head of the list is less than the maximum of the tail,
%   the maximum position of the list is the maximum position of the tail + 1.

max_position([Head | Tail], MaxPosition) :-
    max_position(Tail, TailMaxPosition),
    find_max(Tail, TailMax),
    Head >= TailMax,
    MaxPosition is 0, !.

max_position([Head | Tail], MaxPosition) :-
    max_position(Tail, TailMaxPosition),
    find_max(Tail, TailMax),
    Head < TailMax,
    MaxPosition is TailMaxPosition + 1.

% Predicate to find the position of the maximum value in a list.
find_max_position(List, MaxPosition) :-
    max_position(List, MaxPosition).

/* -------------------------------------------------------------- */
% Base case: If the list contains only one element, the maximum is that element.
max_in_list([X], X) :- !.

% Recursive case:
% - If the head of the list is greater than or equal to the maximum of the tail,
%   the maximum of the list is the head.
% - If the head of the list is less than the maximum of the tail,
%   the maximum of the list is the maximum of the tail.
max_in_list([Head | Tail], Max) :-
    max_in_list(Tail, TailMax),
    Head >= TailMax,
    Max is Head, !.
max_in_list([Head | Tail], Max) :-
    max_in_list(Tail, TailMax),
    Head < TailMax,
    Max is TailMax.

% Predicate to find the maximum value in a list.
find_max(List, Max) :-
    max_in_list(List, Max).
/*------------------------------------------------------------------------------------*/
/*
calculate_final_score([Player|Board], Score) :-
    write('here'), nl,
    findall(Point, adjacent_or_under(Board, 0, 0, Player, Point), Points),
    length(Points, Score). % guarda em score o tamanho de Points (peças que servem para pontuação)
*/
/*------------------------------------------------------------------------------------*/
% Define a predicate to check if there is a 'p' in a list.
contains_p([p|_]).
contains_p([_|T]) :- contains_p(T).

% Define a predicate to check if there is a 'p' in the board.
check_board(Board) :- 
    member(Row, Board),  % Get a row from the board.
    contains_p(Row).    % Check if the row contains 'p'.


can_move(Board, X, Y) :- is_empty(Board, X, Y).
can_move(Board, X, Y, Player) :- 
    is_empty(Board, X, Y), 
    checkers_around(Board, X, Y, Player, _).

% Check if there are adjacent checkers of the same color.
checkers_around(Board, X, Y, Player, Checkers) :-
    findall(Point, adjacent_or_under(Board, X, Y, Player, Point), Checkers),
    length(Checkers, Count),
    Count >= 2. % There must be at least 2 adjacent checkers to make a move.
    
move([Player|Board], [PointX, PointY], [NewPlayer|NewBoard]) :- 
    (check_if_valid(Board, PointX, PointY) ->
        replace(Board, PointX, PointY, Player, TempBoard),
        clean_playables(TempBoard, NewBoard),
        switch_player(NewPlayer, Player),
        display_game([NewPlayer|NewBoard]); % tem que ser display do board sem os ps
        write('Invalid move. Try again.\n'),
        write('Player '), write(Player), write(', choose an X starting point:'),
        read(PointX),
        write('Player '), write(Player), write(', now choose an Y starting point: '),
        read(PointY),
        Move = [PointX, PointY],
        move(Board, Move, NewBoard)
    ).

% Checks if a point is playable.
check_if_valid(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(X, Board, Row),
    nth0(Y, Row, p).

update_board_first_play(Board, Player, PointX, PointY, NewBoard) :-
    replace(Board, PointX, PointY, Player, NewBoard),
    display_game_pie_rule(Board).

update_board(Board, Player, PointX, PointY, NewBoard) :-
    replace(Board, PointX, PointY, Player, TempBoard),
    % print do board sem as jogaveis possiveis e com a nova peça inserida
    display_game([Player|Board]),
    % move_pawn(TempBoard, PointX, PointY, NewBoard, Opponent), % é preciso???
    write('move_pawn\n'),
    % display_game([Board|TempBoard]),
    write('display_game\n').

% Replace a cell in the board with a new value.
replace([Row | Rest], 0, Y, NewValue, [NewRow | Rest]) :-
    replace_in_row(Row, 0, Y, NewValue, NewRow).
replace([Row | Rest], X, Y, NewValue, [Row | NewRest]) :-
    X > 0,
    X1 is X - 1,
    replace(Rest, X1, Y, NewValue, NewRest).

replace_in_row([_ | Rest], 0, Y, NewValue, [NewValue | Rest]) :-
    Y = 0; Y = p.
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

pie_rule([Player|Board], PlayerPos, [CurPlayer|NewBoard]) :-
    display_game_pie_rule(Board),
    write('Player 1\'s turn:'), nl, nl,
    write('Player '), write(Player), write(', choose an X starting point:'),
    read(PointX),
    write('Player '), write(Player), write(', now choose an Y starting point: '),
    read(PointY),
    (is_empty(Board, PointX, PointY) ->
        replace(Board, PointX, PointY, Player, TempBoard), % Player = b
        nl, nl,
        write('Player 1\'s play:\n'),
        display_game_pie_rule(TempBoard),
        write('Player Whites, do you want to switch colors?\n'),
        write('1. Yes'), nl, write('2. No'), nl,
        read(Choice),
        CurPlayer = w,
        write('\nPlayer 2\'s play:\n'),
        update_board_first_play(TempBoard, Player, PointX, PointY, NewBoard),
        (Choice =:= 1 -> 
            write('\nPlayer 1 is now playing with the white pieces\n'),
            write('Player 2 is now playing with the black pieces\n'), nl; true),
        PlayerPos = [PointX, PointY];
        write('Invalid choice. Try again.\n'),
        pie_rule([Player|Board], PlayerPos, [CurPlayer|NewBoard])
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

adjacent_or_under(Board, X, Y, Player, Point) :-
    adjacent(Board, X, Y, Player, Point).
adjacent_or_under(Board, X, Y, Player, Point) :-
    under(Board, X, Y, Player, Point).

% Check if a point is adjacent to the given player checker.
adjacent(Board, X, Y, Player, Point) :- % pode n estar correto as coordenadas. Objetivo é verificar numa row se tem lá o símbolo do player e guardar esse ponto
    is_adjacent(X, Y, AdjX, AdjY),
    is_inside(Board, AdjX, AdjY),
    nth0(AdjX, Board, Row),
    nth0(AdjY, Row, Player),
    Point = [AdjX, AdjY].

is_adjacent(X1, Y1, X2, Y2) :-
    (X1 =:= X2, Y1 =:= Y2 - 1) ;
    (X1 =:= X2, Y1 =:= Y2 + 1) ;
    (X1 =:= X2 - 1, Y1 =:= Y2) ;
    (X1 =:= X2 + 1, Y1 =:= Y2).

% Check if a point is under the given player checker.
under(Board, X, Y, Player, Point) :- % pode n estar correto. Objetivo é verificar se em rows em baixo encontra-se uma peça do player especificado
    X1 is X + 1,
    is_inside(Board, X1, Y),
    nth0(X1, Board, Row),
    nth0(Y, Row, Player),
    Point = [X1, Y].

% Report the winner of the game.
report_winner(Score, Winner) :-
    (Winner \= t ->
        write('Player '), write(Winner), write('is the winner!!!\n'),
        write('Player with the most adjacent or under checkers wins.\n'),
        write('Player with '),
        write(Score),
        write(' points wins the game.\n');
        write('It\'s a draw! No one wins.')
    ).

% ----------------------------------------------------------------------------------------------------------------------------
/*
[
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
]

[[b],[0, 0],[0, p, 0],[0, p, 0, 0],[p, 0, b, 0, b],[0, p, 0, b, 0, p],[0, 0, 0, 0, 0, 0, p],[w, p, w, 0, 0, p],[0, 0, w, p, 0],[0, p, p, 0],[0, p, 0],[0, p],[p]]

*/

/*------------------------------------------------------------------------------------*/
print_list([]).
print_list([H|T]) :-
    write(H),           % Print the current element
    write(' '),                 % Newline for formatting
    print_list(T).       % Recursively print the rest of the list

/*------------------------------------------------------------------------------------*/
print_board([]).
print_board([Row|Rest]) :-
    print_row(Row),
    nl,  % New line for the next row
    print_board(Rest).

print_row([]).
print_row([X|Rest]) :-
    write(X),  % Print the current element
    write(' '),  % Add a space between elements for formatting
    print_row(Rest).

/*------------------------------------------------------------------------------------*/

% custom_nth1(+Index, +List, -Element)
custom_nth1(0, [Element|_], Element).
custom_nth1(Index, [_|Rest], Element) :-
    Index > 0,
    NextIndex is Index - 1,
    custom_nth1(NextIndex, Rest, Element).

/*------------------------------------------------------------------------------------*/

elem_belongs_to_both(Elem) :-
    Elem = b,
    Elem = w.

/*------------------------------------------------------------------------------------*/
% Swap 0 with p in all directions from X
swap(Row, Col, Board, NewBoard) :-
    % swapRight(Row, Col, Board, NewBoard),
    % print_board(NewBoard).
    swapInDirection(Row, Col, Board, NewBoard).

% Swap 0 with p in all directions (up, down, left, right, and diagonals)
swapInDirection(Row, Col, Board, NewBoard) :-
    swapUp(Row, Col, Board, TempBoard1),
    swapDown(Row, Col, TempBoard1, TempBoard2),
    swapLeft(Row, Col, TempBoard2, TempBoard3),
    swapRight(Row, Col, TempBoard3, TempBoard4),
    swapDiagonal1(Row, Col, TempBoard4, TempBoard5),
    swapDiagonal2(Row, Col, TempBoard5, TempBoard6),
    swapDiagonal3(Row, Col, TempBoard6, TempBoard7),
    swapDiagonal4(Row, Col, TempBoard7, NewBoard).
    % print_board(NewBoard).

/*---------------- Swap Up -------------------------*/
% Swap 0 with p in the up direction
swapUp(Col, Col, Board, NewBoard) :-
    NewBoard = Board.

swapUp(Row, Col, Board, NewBoard) :-
    RowAbove is Row - 1,
    custom_nth1(RowAbove, Board, RowAboveList),
    custom_nth1(Col, RowAboveList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) ->
        replace_swap(Col, RowAboveList, p, NewRowAbove),
        replace_swap(RowAbove, Board, NewRowAbove, TempBoard),
        swapUp(RowAbove, Col, TempBoard, NewBoard);
    NewBoard = Board). % Default case when Elem is something else, no change

/*---------------- Swap Down -------------------------*/
% Swap 0 with p in the down direction
swapDown(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

swapDown(Row, Col, Board, NewBoard) :-
    RowBelow is Row + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    custom_nth1(Col, RowBelowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) -> 
        replace_swap(Col, RowBelowList, p, NewRowBelow),
        replace_swap(RowBelow, Board, NewRowBelow, TempBoard),
        swapDown(RowBelow, Col, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Left -------------------------*/
% Swap 0 with p in the left direction
swapLeft(Row, 0, Board, NewBoard) :-
    NewBoard = Board.

swapLeft(Row, Col, Board, NewBoard) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    custom_nth1(ColLeft, RowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) -> 
        replace_swap(ColLeft, RowList, p, NewRowLeft),
        replace_swap(Row, Board, NewRowLeft, TempBoard),
        swapLeft(Row, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Right -------------------------*/
% Swap 0 with p in the right direction
swapRight(Row, Row, Board, NewBoard) :-
    NewBoard = Board.

swapRight(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

swapRight(Row, Col, Board, NewBoard) :-
    custom_nth1(Row, Board, RowList),
    ColRight is Col + 1,
    custom_nth1(ColRight, RowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) ->  
        replace_swap(ColRight, RowList, p, NewRowRight),
        replace_swap(Row, Board, NewRowRight, TempBoard),
        swapRight(Row, ColRight, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Diagonal1 (Up and Left)-------------------------*/
% Swap 0 with p in the first diagonal direction (top-left to bottom-right)
swapDiagonal1(Row, 0, Board, NewBoard) :-
    NewBoard = Board.

swapDiagonal1(Row, Col, Board, NewBoard) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    custom_nth1(RowAbove, Board, RowAboveList),
    custom_nth1(ColLeft, RowAboveList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) ->  
        replace_swap(ColLeft, RowAboveList, p, NewTopLeft),
        replace_swap(RowAbove, Board, NewTopLeft, TempBoard),
        swapDiagonal1(RowAbove, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Diagonal2 (Low and Left)-------------------------*/
% Swap 0 with p in the second diagonal direction (top-right to bottom-left)
swapDiagonal2(Row, 0, Board, NewBoard) :-
    NewBoard = Board.

swapDiagonal2(Row, Col, Board, NewBoard) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    custom_nth1(ColLeft, RowBelowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; % Stop the loop if Elem is 'w' or 'b'
    (Elem = 0) ->  
        replace_swap(ColLeft, RowBelowList, p, NewBottomLeft),
        replace_swap(RowBelow, Board, NewBottomLeft, TempBoard),
        swapDiagonal2(RowBelow, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Diagonal3 (Up and Right)-------------------------*/
swapDiagonal3(Col, Col, Board, NewBoard) :-
    NewBoard = Board.

swapDiagonal3(Row, Col, Board, NewBoard) :-
    Row - Col =:= 1,
    NewBoard = Board.

swapDiagonal3(Row, Col, Board, NewBoard) :-
    RowAbove is Row - 1,
    ColRight is Col + 1, 
    custom_nth1(RowAbove, Board, RowAboveList),
    custom_nth1(ColRight, RowAboveList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board;
    (Elem = 0) ->  
        replace_swap(ColRight, RowAboveList, p, NewTopRight),
        replace_swap(RowAbove, Board, NewTopRight, TempBoard),
        swapDiagonal3(RowAbove, ColRight, TempBoard, NewBoard);
    NewBoard = Board).

/*---------------- Swap Diagonal4 (Low and Right)-------------------------*/
swapDiagonal4(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

swapDiagonal4(Row, Col, Board, NewBoard) :-
    Row + Col =:= 11,
    NewBoard = Board.

swapDiagonal4(Row, Col, Board, NewBoard) :-
    RowBelow is Row + 1,
    ColRight is Col + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    custom_nth1(ColRight, RowBelowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board;
    (Elem = 0) ->  
        replace_swap(ColRight, RowBelowList, p, NewBottomRight),
        replace_swap(RowBelow, Board, NewBottomRight, TempBoard),
        swapDiagonal4(RowBelow, ColRight, TempBoard, NewBoard);
    NewBoard = Board).

/*------------------ Replace ------------------*/
% Replace an element at a specific index in a list
replace_swap(0, [_|Rest], Element, [Element|Rest]).

replace_swap(Index, [X|Rest], Element, [X|NewRest]) :-
    Index > 0,
    NewIndex is Index - 1,
    replace_swap(NewIndex, Rest, Element, NewRest).
    
/* Function to replace the ps with zeros */
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
    
% Example usage:
% Define the initial board
% [[0],[0, 0],[0, b, 0],[0, 0, w, 0],[w, 0, 0, 0, 0],[0, w, 0, 0, 0, 0],[0, w, b, b, w, 0, 0],[0, b, w, w, 0, 0],[0, b, 0, 0, 0],[0, w, w, b],[0, 0, 0],[0, b],[b]]

% ---------------------------------------------------------------------------------------------------