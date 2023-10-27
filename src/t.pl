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
:- use_module(library(lists)).

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
    swapDiagonal4(Row, Col, TempBoard7, NewBoard),
    print_board(NewBoard).

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
replace_p_with_zero([], []).
replace_p_with_zero([Row|RestOfRows], [NewRow|NewRest]) :-
    replace_p_in_row(Row, NewRow),
    replace_p_with_zero(RestOfRows, NewRest).

replace_p_in_row([], []).
replace_p_in_row([p|Rest], [0|NewRest]) :-
    replace_p_in_row(Rest, NewRest).
replace_p_in_row([X|Rest], [X|NewRest]) :-
    X \= p,
    replace_p_in_row(Rest, NewRest).
    
% Example usage:
% Define the initial board
% 



















