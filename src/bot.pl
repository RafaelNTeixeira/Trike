/* -------------------------------------------------------------- */

random_choice_pie_rule_bot(Choice) :-
    random(1, 3, Choice).

/* -------------------------------------------------------------- */
pie_rule_bot([Player|Board], PlayerPos, [CurPlayer|NewBoard]) :-
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
        random_choice_pie_rule_bot(Choice),
        write('Player Whites choose: '), write(Choice), nl,
        CurPlayer = w,
        write('\nPlayer 2\'s play:\n'),
        update_board_first_play(TempBoard, Player, PointX, PointY, NewBoard),
        (Choice =:= 1 -> 
            write('\nPlayer 1 is now playing with the white pieces\n'),
            write('Player 2 is now playing with the black pieces\n'), nl; true),
        PlayerPos = [PointX, PointY];
        write('Invalid choice. Try again.\n'),
        pie_rule_bot([Player|Board], PlayerPos, [CurPlayer|NewBoard])
    ).

/* -------------------------------------------------------------- */

gameplay_bot([Player|Board], PlayerPos, Level, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    (game_over([Player|ListOfMoves]) ->
        ((Player = b)  ->
            write('Player '), write(Player), write(', choose an X starting point:'),
            read(PointX),
            write('Player '), write(Player), write(', now choose a Y starting point: '),
            read(PointY),
            Move1 = [PointX, PointY],
            move([Player|ListOfMoves], Move1, Move,[NewPlayer|NewBoard]),
            gameplay_bot([NewPlayer|NewBoard], Move, Level, FinalScore, Winner)
        ;
            choose_move([Player|ListOfMoves], Level, Move),
            move_bot([Player|ListOfMoves], Move, [NewPlayer|NewBoard]),
            gameplay_bot([NewPlayer|NewBoard], Move, Level, FinalScore, Winner)
        )
    ;
    calculate_final_score([Player|Board], PlayerPos, FinalScore, Winner)
    ).

/* -------------------------------------------------------------- */
choose_move([Player|Board], Level, [PointX, PointY]) :-
    ((Level = 2) -> choose_random_p(Board, PointX, PointY);
        find_p_with_more_w_and_b(Board, PointX, PointY)
    ).

/* -------------------------------------------------------------- */

pie_rule_bot_vs_bot([Player|Board], PlayerPos, [CurPlayer|NewBoard]) :-
    display_game_pie_rule(Board),
    choose_random_zero(Board, PointX, PointY),
    replace(Board, PointX, PointY, Player, TempBoard), 
    nl, nl,
    write('Player 1\'s play:\n'),
    display_game_pie_rule(TempBoard),
    write('Player Whites, do you want to switch colors?\n'),
    write('1. Yes'), nl, write('2. No'), nl,
    random_choice_pie_rule_bot(Choice),
    write('Player Whites choose: '), write(Choice), nl,
    CurPlayer = w,
    write('\nPlayer 2\'s play:\n'),
    update_board_first_play(TempBoard, Player, PointX, PointY, NewBoard),
    (Choice =:= 1 -> 
        write('\nPlayer 1 is now playing with the white pieces\n'),
        write('Player 2 is now playing with the black pieces\n'), nl; true),
    PlayerPos = [PointX, PointY].

/* -------------------------------------------------------------- */

choose_random_zero(Board, Row, Col) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, 0), nth1(Row, Board, RowList), nth1(Col, RowList, 0), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomRow-RandomCol),
    PRow is RandomRow - 1,
    PCol is RandomCol - 1.


/* -------------------------------------------------------------- */

gameplay_bot_vs_bot([Player|Board], PlayerPos, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    (game_over([Player|ListOfMoves]) ->
        (Player = b  ->
            choose_move([Player|ListOfMoves], 3, Move),
            move_bot([Player|ListOfMoves], Move, [NewPlayer|NewBoard]),
            gameplay_bot_vs_bot([NewPlayer|NewBoard], Move, FinalScore, Winner)
        ;
            choose_move([Player|ListOfMoves], 2, Move),
            move_bot([Player|ListOfMoves], Move, [NewPlayer|NewBoard]),
            gameplay_bot_vs_bot([NewPlayer|NewBoard], Move, FinalScore, Winner)
        )
    ;
    calculate_final_score([Player|Board], PlayerPos, FinalScore, Winner)
    ).

/* -------------------------------------------------------------- */

move_bot([Player|Board], [PointX, PointY], [NewPlayer|NewBoard]) :-
    replace(Board, PointX, PointY, Player, TempBoard),
    clean_playables(TempBoard, NewBoard),
    switch_player(NewPlayer, Player),
    write('Move Bot'), nl,
    display_game([NewPlayer|NewBoard]).

/* -------------------------------------------------------------- */
/*
Bot Easy
Vai jogar numa posição random.
*/

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

% Predicate to choose a random position with 'p' from the board and return its coordinates.
choose_random_p(Board, PRow, PCol) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, p), nth1(Row, Board, RowList), nth1(Col, RowList, p), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomPRow-RandomPCol),
    PRow is RandomPRow - 1,
    PCol is RandomPCol - 1.

/* -----------------------------------------------------------------*/


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
/* Função para saber quantos w ou b tem há volta de uma certa posição */

count_around_p(Row, Col, Board, Count, Res) :-
    count_up_p(Row, Col, Board, Count, TempCount1),
    count_down_p(Row, Col, Board, TempCount1, TempCount2),
    count_left_p(Row, Col, Board, TempCount2, TempCount3),
    count_right_p(Row, Col, Board, TempCount3, TempCount4),
    count_diagnal1_p(Row, Col, Board, TempCount4, TempCount5),
    count_diagnal2_p(Row, Col, Board, TempCount5, TempCount6),
    count_diagnal3_p(Row, Col, Board, TempCount6, TempCount7),
    count_diagnal4_p(Row, Col, Board, TempCount7, Res).


count_up_p(Row, Col, Board, Count, Res) :-
    RowAbove is Row - 1,
    ((RowAbove < 0) -> Res = Count;  % Check if RowAbove is less than 0
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(Col, RowAboveList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_down_p(Row, Col, Board, Count, Res) :-
    RowBelow is Row + 1,
    ((RowBelow > 12) -> Res = Count;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(Col, RowBelowList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_left_p(Row, Col, Board, Count, Res) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    ((ColLeft < 0) -> Res = Count;
        custom_nth1(ColLeft, RowList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_right_p(Row, Col, Board, Count, Res) :-
    custom_nth1(Row, Board, RowList),
    length(RowList, Len),
    Len1 is Len - 1,
    ColRight is Col + 1,
    ((ColRight > Len1) -> Res = Count;
        custom_nth1(ColRight, RowList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_diagnal1_p(Row, Col, Board, Count, Res) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    ((RowAbove < 0 ; ColLeft < 0) -> Res = Count;
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(ColLeft, RowAboveList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_diagnal2_p(Row, Col, Board, Count, Res) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    ((RowBelow > 12 ; ColLeft < 0) -> Res = Count;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(ColLeft, RowBelowList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

count_diagnal3_p(Row, Col, Board, Count, Res) :-
    RowAbove is Row - 1,
    ColRight is Col + 1,
    ((RowAbove < 0) -> Res = Count;
        custom_nth1(RowAbove, Board, RowAboveList), 
        length(RowAboveList, Len),
        Len1 is Len - 1,
        (ColRight > Len1) -> Res = Count;
            custom_nth1(ColRight, RowAboveList, Elem),
            ((Elem = w ; Elem = b) -> Res is Count + 1;
                Res = Count
            )
    ).

count_diagnal4_p(Row, Col, Board, Count, Res) :-
    RowBelow is Row + 1,
    ColRight is Col + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    length(RowBelowList, Len),
    Len1 is Len - 1,
    ((RowBelow > 12 ; ColRight > Len1) -> Res = Count;
        custom_nth1(ColRight, RowBelowList, Elem),
        ((Elem = w ; Elem = b) -> Res is Count + 1;
            Res = Count
        )
    ).

/* -------------------------------------------------------------- */
% Process each element in the list and store the results in a new list.
process_elements([], _, []).
process_elements([(Row, Col)|Rest], Board, [Result|Results]) :-
    count_around_p(Row, Col, Board, 0, Result),
    process_elements(Rest, Board, Results).


/* -------------------------------------------------------------- */

print_p_coordinates([]).
print_p_coordinates([(Row, Col)|Rest]) :-
    format("(~d,~d), ", [Row, Col]),
    print_p_coordinates(Rest).

/* -------------------------------------------------------------- */

print_degub([], []).
print_degub([(Row, Col)|Rest], [H|T]):-
    format("(~d,~d): ~d, ", [Row, Col, H]), 
    print_degub(Rest, T).

/* -------------------------------------------------------------- */
/* Função para dizer qual é o p com mais w e b há volta */
% find_p_with_more_w_and_b(+Board, -Row, -Col)
find_p_with_more_w_and_b(Board, Row, Col) :-
    get_p_coordinates(Board, PList),
    process_elements(PList, Board, Results),
    print_degub(PList, Results), nl,
    find_max_position(Results, Pos),
    custom_nth1(Pos, PList, (Row, Col)).



