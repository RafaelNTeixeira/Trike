% random_choice_pie_rule_bot(-Choice)
% Escolhe 1 ou 2 para o bot escolher uma opção na pie rule.
random_choice_pie_rule_bot(Choice) :-
    random(1, 3, Choice).


% pie_rule_bot(+GameState, -PlayerPos, -NewGameState)
% Aplicar a Pie Rule no modo Player Vs Bot
% Um jogador escolhe a jogada inicial e o bot escolhe aleatoriamente se quer ou não trocar de cor.
pie_rule_bot([Player|Board], PlayerPos, [CurPlayer|NewBoard]) :-
    display_game_pie_rule(Board),
    write('\nPlayer 1\'s turn:'), nl, nl,
    write('Player '), write(Player), write(', choose an X starting point:'),
    read(PointX),
    write('Player '), write(Player), write(', now choose an Y starting point: '),
    read(PointY),
    (is_empty(Board, PointX, PointY) ->
        replace(Board, PointX, PointY, Player, TempBoard), % Player = b
        nl, nl,
        write('Player 1\'s play:\n'),
        display_game_pie_rule(TempBoard),
        write('\nPlayer Whites, do you want to switch colors?\n'),
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


% choose_move(+GameState, +Level, -Move)
% De acordo com o Level recebido (2-fácil ou 3-difícil), o algoritmo de jogabilidade do bot é escolhido.
% Após percorrer o algoritmo, uma jogada é decidida.
choose_move([_Player|Board], Level, [PointX, PointY]) :-
    ((Level = 3) ->
        count_p(Board, Count),
        ((Count = 1) -> get_p_coordinates(Board, [(PointX, PointY)]);
            hard(Board, PointX, PointY)
        )
        ;
        count_p(Board, Count),
        ((Count = 1) -> get_p_coordinates(Board, [(PointX, PointY)]);
            choose_random_p(Board, PointX, PointY)
        )
    ).


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
    write('\nPlayer Whites, do you want to switch colors?\n'),
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


% choose_random_zero(+Board, -Row, -Col)
% Escolhe aleatoriamente uma célula do board.
choose_random_zero(Board, PRow, PCol) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, 0), nth1(Row, Board, RowList), nth1(Col, RowList, 0), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomRow-RandomCol),
    PRow is RandomRow - 1,
    PCol is RandomCol - 1.



% gameplay_bot_vs_bot(+GameState, +PlayerPos, -FinalScore, -Winner)
% Ciclo de jogo para o Bot Vs Bot.
% Exibe as jogadas válidas e, a cada movimento de um bot, o ciclo prossegue, a menos que o jogo tenha terminado. Se o jogo terminar, calcula o resultado final e identifica o vencedor.
gameplay_bot_vs_bot([Player|Board], PlayerPos, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    (game_over([Player|ListOfMoves]) ->
        (Player = b  ->
            choose_move([Player|ListOfMoves], 2, Move),
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


% move_bot(+GameState, +Move, -NewGameState)
% Aplica a jogada do bot no board e troca de jogador após essa jogada.
move_bot([Player|Board], [PointX, PointY], [NewPlayer|NewBoard]) :-
    replace(Board, PointX, PointY, Player, TempBoard),
    clean_playables(TempBoard, NewBoard),
    switch_player(NewPlayer, Player),
    display_game([NewPlayer|NewBoard]).


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


% choose_random_p(+Board, -PRow, -PCol)
% Predicado para escolher uma posição aleatória com um `p` (espaço jogável) do board e retornar as suas coordenadas.
choose_random_p(Board, PRow, PCol) :-
    custom_flatten(Board, FlatBoard),
    findall(Row-Col, (nth1(Position, FlatBoard, p), nth1(Row, Board, RowList), nth1(Col, RowList, p), Position > 0), Positions),
    length(Positions, NumPositions),
    random(1, NumPositions, RandomIndex),
    nth1(RandomIndex, Positions, RandomPRow-RandomPCol),
    PRow is RandomPRow - 1,
    PCol is RandomPCol - 1.


% get_p_coordinates(+Board, -PList)
% Predicado para obter as coordenadas de todas as posições 'p' no quadro.
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


% count_p(+Board, -Count)
% Conta todos os `p` de um board.
count_p([], 0). 

count_p([Row | RestBoard], Count) :-
    count_p_in_row(Row, RowCount),      
    count_p(RestBoard, RestCount),      
    Count is RowCount + RestCount.      

count_p_in_row([], 0). 
  
count_p_in_row([p | Rest], Count) :- 
    count_p_in_row(Rest, RestCount), 
    Count is RestCount + 1.         

count_p_in_row([_ | Rest], Count) :- 
    count_p_in_row(Rest, Count).    


% value(+Board, +Row, +Col, -Value)
% Determina um valor de uma jogada ao contar quantas jogadas disponíveis ficam após jogar.
value(Board, Row, Col, Value) :-
    clean_playables(Board, NewBoard),
    swap(Row, Col, NewBoard, ListOfMoves),
    count_p(ListOfMoves, Value).

% process_p(+Board, +PList, -Values)
% Percorre as coordenadas numa lista que representam as jogadas possíveis e para cada uma dessas coordenadas, é chamado o predicado `value` para determinar o valor dessa jogada.
process_p(_, [], []).
process_p(Board, [(Row,Col)|Res], [Value|Values]) :-
    value(Board, Row, Col, Value),
    process_p(Board, Res, Values).

% max_in_list1(+List, -Max)
% Determina quel é o maior valor da lista.
max_in_list1([X], X).
max_in_list1([X|Xs], Max) :-
    max_in_list1(Xs, RestMax),
    Max is max(X, RestMax).

% max_position1(+List, -Pos)
% Determina a posição do maior valor da lista.
max_position1(List, Pos) :-
    max_in_list1(List, Max),         
    nth1(Pos, List, Max).

% hard(+Board, -Row, -Col)
% Escolhe a posição onde o bot hard vai jogar.
hard(Board, Row, Col) :-
    get_p_coordinates(Board, PList),
    process_p(Board, PList, Values),
    max_position1(Values, Index),
    custom_nth1(Index, PList, (Row, Col)).
