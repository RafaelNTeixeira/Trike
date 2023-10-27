:- use_module(library(lists)).
:- use_module(library(random)).

/* -------------------------------------------------------------- */

% Custom predicate to flatten a nested list.
custom_flatten([], []).
custom_flatten([Head|Rest], FlatList) :-
    is_list(Head),
    custom_flatten(Head, FlatHead),
    custom_flatten(Rest, FlatRest),
    append(FlatHead, FlatRest, FlatList).
custom_flatten([Head|Rest], [Head|FlatRest]) :-
    \+ is_list(Head),
    custom_flatten(Rest, FlatRest).

/* -------------------------------------------------------------- */

% [[b],[0, 0],[0, p, 0],[0, p, 0, 0],[p, 0, b, 0, b],[0, p, 0, b, 0, p],[0, 0, 0, 0, 0, 0, p],[w, p, w, 0, 0, p],[0, 0, w, p, 0],[0, p, p, 0],[0, p, 0],[0, p],[p]]

% Define the game board.
/*
board([[b],
       [0, 0],
       [0, p, 0],
       [0, p, 0, 0],
       [p, 0, b, 0, b],
       [0, p, 0, b, 0, p],
       [0, 0, 0, 0, 0, 0, p],
       [w, p, w, 0, 0, p],
       [0, 0, w, p, 0],
       [0, p, p, 0],
       [0, p, 0],
       [0, p],
       [p]]).
*/

% Predicate to choose a random position with 'p' from the board and return its coordinates.
choose_random_p(Board, PRow, PCol) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, p), nth1(Row, Board, RowList), nth1(Col, RowList, p), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomPRow-RandomPCol),
    PRow is RandomPRow - 1,
    PCol is RandomPCol - 1.

/*
Bot Hard
Vai jogar sempre na posição onde tem mais peças há volta.
*/

/* -------------------------------------------------------------- */
% Predicate to get the coordinates of all 'p' positions in the board.
get_p_coordinates(Board, PList) :-
    get_p_coordinates(Board, 0, [], PList).

get_p_coordinates([], _, PList, PList).
get_p_coordinates([Row|Rest], RowIndex, Acc, PList) :-
    get_row_p_coordinates(Row, 0, RowIndex, Acc, NewAcc),
    NextRowIndex is RowIndex + 1,
    get_p_coordinates(Rest, NextRowIndex, NewAcc, PList).

get_row_p_coordinates([], _, _, Acc, Acc).
get_row_p_coordinates([p|Rest], ColumnIndex, RowIndex, Acc, PList) :-
    append(Acc, [(RowIndex, ColumnIndex)], NewAcc),
    NextColumnIndex is ColumnIndex + 1,
    get_row_p_coordinates(Rest, NextColumnIndex, RowIndex, NewAcc, PList).
get_row_p_coordinates([_|Rest], ColumnIndex, RowIndex, Acc, PList) :-
    NextColumnIndex is ColumnIndex + 1,
    get_row_p_coordinates(Rest, NextColumnIndex, RowIndex, Acc, PList).

/* -------------------------------------------------------------- */

print_p_coordinates([]).
print_p_coordinates([(Row, Col)|Rest]) :-
    format("p at row ~d, column ~d~n", [Row, Col]),
    print_p_coordinates(Rest).

/* -------------------------------------------------------------- */
/* Função para saber qual é o p com mais peças há volta */

/* -------------------------------------------------------------- */
test(Board, PList) :- get_p_coordinates(Board, PList),
                      print_p_coordinates(PList).
