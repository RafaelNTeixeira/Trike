/* -------------------------------------------------------------- */

random_choice_pie_rule_bot(Choice) :-
    random(1, 3, Choice).

/* -------------------------------------------------------------- */

% pie_rule(+GameState, -PlayerPos, -NewGameState)
% Aplicar a Pie Rule no modo Player Vs Player
% Um jogador escolhe aleatoriamente a jogada inicial e o outro se quer ou não trocar de cor.
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

% gameplay_bot(+GameState, +PlayerPos, +Level, -FinalScore, -Winner)
% Ciclo de jogo para o Player Vs Bot.
% Exibe as jogadas válidas e, a cada movimento de um jogador, o ciclo prossegue, a menos que o jogo tenha terminado. Se o jogo terminar, calcula o resultado final e identifica o vencedor.
gameplay_bot([Player|Board], PlayerPos, Level, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    (game_over([Player|ListOfMoves]) ->
        ((Player = b)  ->
            write('Player '), write(Player), write(', choose an X starting point:'),
            read(PointX),
            write('Player '), write(Player), write(', now choose a Y starting point: '),
            read(PointY),
            Move1 = [PointX, PointY],
            move([Player|ListOfMoves], Move1, Move, [NewPlayer|NewBoard]),
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

% choose_move(+GameState, +Level, -Move)
% De acordo com o Level recebido (2-fácil ou 3-difícil), o algoritmo de jogabilidade do bot é escolhido.
% Após percorrer o algoritmo, uma jogada é decidida.
choose_move([Player|Board], Level, [PointX, PointY]) :-
    ((Level = 2) -> choose_random_p(Board, PointX, PointY);
        find_p_with_more_w_and_b(Board, Player, PointX, PointY)
    ).

/* -------------------------------------------------------------- */

% pie_rule_bot_vs_bot(+GameState, -PlayerPos, -NewGameState)
% Aplicar a Pie Rule no modo Bot Vs Bot
% Um bot escolhe aleatoriamente a jogada inicial e o outro se quer ou não trocar de cor.
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
% choose_random_zero(+Board, -Row, -Col)
% Escolhe aleatoriamente uma célula do board
choose_random_zero(Board, Row, Col) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, 0), nth1(Row, Board, RowList), nth1(Col, RowList, 0), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomRow-RandomCol),
    PRow is RandomRow - 1,
    PCol is RandomCol - 1.


/* -------------------------------------------------------------- */

% gameplay_bot_vs_bot(+GameState, +PlayerPos, -FinalScore, -Winner)
% Ciclo de jogo para o Bot Vs Bot.
% Exibe as jogadas válidas e, a cada movimento de um bot, o ciclo prossegue, a menos que o jogo tenha terminado. Se o jogo terminar, calcula o resultado final e identifica o vencedor.
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

% move_bot(+GameState, +Move, -NewGameState)
% Aplica a jogada do bot no board e troca de jogador após essa jogada
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

% custom_flatten(+Board, -FlatBoard)
% Predicado personalizado para achatamento de uma nested list.
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

% choose_random_p(+Board, -PRow, -PCol)
% Predicado para escolher uma posição aleatória com um `p` (espaço jogável) do board e retornar as suas coordenadas
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

% get_p_coordinates(+Board, -PList)
% Predicado para recolher all coordenadas de todas as células `p` (células jogáveis) do board.
% Predicate to get the coordinates of all 'p' positions in the board.
get_p_coordinates(Board, PList) :-
    get_p_coordinates(Board, 0, [], PList).

% get_p_coordinates(+Board, +RowIndex, +Acc, -PList)
% Percorre todas as linhas do board e guarda numa lista as posições das células `p` (células jogáveis)
% RowIndex é o índice da linha atual, Acc é a lista acumuladora de coordenadas e PList é a lista final de coordenadas.
get_p_coordinates([], _, PList, PList).
get_p_coordinates([Row|Rest], RowIndex, Acc, PList) :-
    get_row_p_coordinates(Row, 0, RowIndex, Acc, NewAcc),
    NextRowIndex is RowIndex + 1,
    get_p_coordinates(Rest, NextRowIndex, NewAcc, PList).

% get_row_p_coordinates(+Row, +ColumnIndex, +RowIndex, +Acc, -PList)
% Retorna as coordenadas das células `p` de uma row do board
get_row_p_coordinates([], _, _, Acc, Acc).
get_row_p_coordinates([p|Rest], ColumnIndex, RowIndex, Acc, PList) :-
    append(Acc, [(RowIndex, ColumnIndex)], NewAcc),
    NextColumnIndex is ColumnIndex + 1,
    get_row_p_coordinates(Rest, NextColumnIndex, RowIndex, NewAcc, PList).

% Predicado que lida com as células que não são `p`. Simplesmente aumenta o índice da coluna e continua a processar as próximas células na linha
get_row_p_coordinates([_|Rest], ColumnIndex, RowIndex, Acc, PList) :-
    NextColumnIndex is ColumnIndex + 1,
    get_row_p_coordinates(Rest, NextColumnIndex, RowIndex, Acc, PList).

/* -------------------------------------------------------------- */
/* Função para saber quantos w ou b tem há volta de uma certa posição */

% count_around_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Predicado coordenada a contagem de células nas oito direções ao redor da coordenada fornecida
count_around_p(Row, Col, Board, Player, Count, Res) :-
    count_up_p(Row, Col, Board, Player, Count, TempCount1),
    count_down_p(Row, Col, Board, Player, TempCount1, TempCount2),
    count_left_p(Row, Col, Board, Player, TempCount2, TempCount3),
    count_right_p(Row, Col, Board, Player, TempCount3, TempCount4),
    count_diagnal1_p(Row, Col, Board, Player, TempCount4, TempCount5),
    count_diagnal2_p(Row, Col, Board, Player, TempCount5, TempCount6),
    count_diagnal3_p(Row, Col, Board, Player, TempCount6, TempCount7),
    count_diagnal4_p(Row, Col, Board, Player, TempCount7, Res).

% count_up_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis acima da coordenada fornecida no board
count_up_p(Row, Col, Board, Player, Count, Res) :-
    RowAbove is Row - 1,
    ((RowAbove < 0) -> Res = Count;  % Check if RowAbove is less than 0
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(Col, RowAboveList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_down_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis abaixo da coordenada fornecida no board
count_down_p(Row, Col, Board, Player, Count, Res) :-
    RowBelow is Row + 1,
    ((RowBelow > 12) -> Res = Count;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(Col, RowBelowList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_left_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis à esquerda da coordenada fornecida no board
count_left_p(Row, Col, Board, Player, Count, Res) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    ((ColLeft < 0) -> Res = Count;
        custom_nth1(ColLeft, RowList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_right_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis à direita da coordenada fornecida no board
count_right_p(Row, Col, Board, Player, Count, Res) :-
    custom_nth1(Row, Board, RowList),
    length(RowList, Len),
    Len1 is Len - 1,
    ColRight is Col + 1,
    ((ColRight > Len1) -> Res = Count;
        custom_nth1(ColRight, RowList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_diagnal1_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis na diagonal superior esquerda da coordenada fornecida no board
count_diagnal1_p(Row, Col, Board, Player, Count, Res) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    ((RowAbove < 0 ; ColLeft < 0) -> Res = Count;
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(ColLeft, RowAboveList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_diagnal2_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis na diagonal inferior esquerda da coordenada fornecida no board
count_diagnal2_p(Row, Col, Board, Player, Count, Res) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    ((RowBelow > 12 ; ColLeft < 0) -> Res = Count;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(ColLeft, RowBelowList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

% count_diagnal3_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis na diagonal superior direita da coordenada fornecida no board
count_diagnal3_p(Row, Col, Board, Player, Count, Res) :-
    RowAbove is Row - 1,
    ColRight is Col + 1,
    ((RowAbove < 0) -> Res = Count;
        custom_nth1(RowAbove, Board, RowAboveList), 
        length(RowAboveList, Len),
        Len1 is Len - 1,
        (ColRight > Len1) -> Res = Count;
            custom_nth1(ColRight, RowAboveList, Elem),
            ((Elem = Player) -> Res is Count + 1;
                Res = Count
            )
    ).

% count_diagnal4_p(+Row, +Col, +Board, +Player, +Count, -Res)
% Conta as células jogáveis na diagonal inferior direita da coordenada fornecida no board
count_diagnal4_p(Row, Col, Board, Player, Count, Res) :-
    RowBelow is Row + 1,
    ColRight is Col + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    length(RowBelowList, Len),
    Len1 is Len - 1,
    ((RowBelow > 12 ; ColRight > Len1) -> Res = Count;
        custom_nth1(ColRight, RowBelowList, Elem),
        ((Elem = Player) -> Res is Count + 1;
            Res = Count
        )
    ).

/* -------------------------------------------------------------- */
% process_elements(+PList, +Board, +Player, -Results)
% Processa cada elemento na lista e armazena os resultados numa nova lista
process_elements([], _, []).
process_elements([(Row, Col)|Rest], Board, Player, [Result|Results]) :-
    count_around_p(Row, Col, Board, Player, 0, Result),
    process_elements(Rest, Board, Player, Results).


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
% find_p_with_more_w_and_b(+Board, +Player, -Row, -Col)
% Identifica qual a célula `p` (célula jogável) que em seu redor possui mais peças pertencentes ao Player definido.
find_p_with_more_w_and_b(Board, Player, Row, Col) :-
    get_p_coordinates(Board, PList),
    process_elements(PList, Board, Player, Results),
    print_degub(PList, Results), nl,
    find_max_position(Results, Pos),
    custom_nth1(Pos, PList, (Row, Col)).



