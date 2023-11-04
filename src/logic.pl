% initial_player(+Player)
% Define o jogador inicial como o 'b'.
initial_player(b).

% switch_player(+Player1, +Player2)
% Muda o jogador 1 pelo jogador 2.
switch_player(b, w).
switch_player(w, b).

% print_indication/0
% Imprime na tela as indicações do tipo de jogadores que existem para mais fácil interpretação e com que peças começam o jogador 1 e 2.
print_indication :-
    write('============================================'), nl,
    write('Player b = Player with the black pieces (b)'), nl,
    write('Player w = Player with the white pieces (w)'), nl,
    write('============================================'), nl, nl,
    write('\nPlayer 1 starts with the black pieces\n'),
    write('Player 2 starts with the white pieces\n'), nl.

% play_bot_vs_bot/0
% Predicado para iniciar o jogo no modo Bot Vs Bot.
play_bot_vs_bot :-
    initial_state(8,GameState),
    print_indication,
    pie_rule_bot_vs_bot(GameState, PlayerPos, NewGameState),
    gameplay_bot_vs_bot(NewGameState, PlayerPos, FinalScore, Winner),
    report_winner(FinalScore, Winner).

% play_game_bot(+Level)
% Predicado para iniciar o jogo no modo Player Vs Bot.
% O argumento Level indica o tipo de dificuldade escolhido para o computador.
play_game_bot(Level) :-
    initial_state(8,GameState),
    print_indication,
    pie_rule_bot(GameState, PlayerPos, NewGameState),
    gameplay_bot(NewGameState, PlayerPos, Level, FinalScore, Winner),
    report_winner(FinalScore, Winner).

% play_game/0
% Predicado para iniciar o jogo no modo Player Vs Player.
play_game :- 
    initial_state(8, GameState),
    print_indication,
    pie_rule(GameState, PlayerPos, NewGameState),
    gameplay(NewGameState, PlayerPos, FinalScore, Winner), % play_game
    report_winner(FinalScore, Winner).

% gameplay(+GameState, +PlayerPos, -FinalScore, -Winner)
% Ciclo de jogo para o modo Player Vs Player.
% Exibe as jogadas válidas e, a cada movimento de um jogador, o ciclo prossegue, a menos que o jogo tenha terminado. Se o jogo terminar, calcula o resultado final e identifica o vencedor.
gameplay([Player|Board], PlayerPos, FinalScore, Winner) :-
    valid_moves([Player|Board], PlayerPos, ListOfMoves),
    ((game_over([Player|ListOfMoves])) -> 
        write('Player '), write(Player), write(', choose an X starting point:'),
        read(PointX),
        write('Player '), write(Player), write(', now choose an Y starting point: '),
        read(PointY),
        Move = ([PointX, PointY]),
        move([Player|ListOfMoves], Move, NewMove,[NewPlayer|NewBoard]),
        gameplay([NewPlayer|NewBoard], NewMove, FinalScore, Winner);

        calculate_final_score([Player|Board], PlayerPos, FinalScore, Winner)
    ).

% game_over(+GameState)
% Verifica se num board existem jogadas jogáveis.
game_over([_Player|ListOfMoves]) :-
    check_board(ListOfMoves).

% valid_moves(+GameState, +PlayerPos, -ListOfMoves)
% Determina e imprime as jogadas possíveis do momento no board.
valid_moves([CurPlayer|Board], [PlayerX, PlayerY], ListOfMoves) :-
    swap(PlayerX, PlayerY, Board, ListOfMoves),
    display_game([CurPlayer|ListOfMoves]).

% calculate_final_score(+GameState, +PlayerPos, -Score, -Winner)
% Identifica o vencedor e calcula a pontuação total obtida por esse jogador.
calculate_final_score([_Player|Board], [PlayerX, PlayerY], Score, Winner) :-
    count_around_end(Board, PlayerX, PlayerY, [0,0], ListOfScores),
    max_in_list(ListOfScores, Score),
    find_max_position(ListOfScores, Res),
    ((Score = 0) -> Winner = t;
        (Res = 0) -> Winner = w;
        (Res = 1) -> Winner = b  
    ).


% increment_first(+Start, +ListOfScores)
% Recebe uma lista como entrada e aumenta o valor do primeiro elemento em 1.
increment_first([OldFirst | Rest], [NewFirst | Rest]) :-
    NewFirst is OldFirst + 1.

% increment_second(+List, +NewList)
% Predicado principal para aumentar o valor do segundo elemento de uma lista.
increment_second(List, NewList) :-
    increment_second_helper(List, NewList, 0).


% increment_second_helper(+List, +NewList, +Index)
% Predicado auxiliar processa a cabeça da lista List (H) e o primeiro elemento da NewList (NewH). 
% O predicado verifica se o Index é igual a 1, o que indica que estamos no segundo elemento da lista original. Se for o caso, aumenta o valor de H em 1 e coloca o resultado em NewH.
% O Index é usado para rastrear a posição atual na lista.
increment_second_helper([], [], _).
increment_second_helper([H|T], [NewH|T], Index) :-
    Index =:= 1, % Check if the current index is 1 (the second element)
    NewH is H + 1.

% increment_second_helper(+List, +NewList, +Index)
% Predicado auxiliar lida com elementos que não são o segundo elemento da lista original. 
% Mantém o elemento H inalterado e continua a processar o resto da lista. 
% O Index é incrementado para acompanhar a posição atual.
increment_second_helper([H|T], [H|NewT], Index) :-
    Index \= 1, % Index is not 1, so keep the element as is
    NewIndex is Index + 1,
    increment_second_helper(T, NewT, NewIndex).

% ---------------------------------------------------------------------------------------------------------------------------------------------
% count_around_end(+Board, +Row, +Col, +Start, -ListOfScores)
% Coordena a contagem dos pontos nas direções em redor de uma coordenada do board.
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

% count_around_end_up(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos acima da posição fornecida (Row, Col) no board. 
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_up(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ((RowAbove < Col) -> ListOfScores = Start; 
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(Col, RowAboveList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_down(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos abaixo da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_down(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    (((RowBelow + Col) > 12) -> ListOfScores = Start;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(Col, RowBelowList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_left(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos à esquerda da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_left(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    ((ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(ColLeft, RowList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_right(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos à direita da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_right(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    length(RowList, Len),
    Len1 is Len - 1,
    ColRight is Col + 1,
    ((ColRight > Len1) -> ListOfScores = Start;
        custom_nth1(ColRight, RowList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_diagonal1(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos na diagonal superior esquerda da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_diagonal1(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    ((RowAbove < 0 ; ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(RowAbove, Board, RowAboveList),
        custom_nth1(ColLeft, RowAboveList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_diagonal2(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos na diagonal inferior esquerda da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_diagonal2(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    ((RowBelow > 12 ; ColLeft < 0) -> ListOfScores = Start;
        custom_nth1(RowBelow, Board, RowBelowList),
        custom_nth1(ColLeft, RowBelowList, Elem),
        ((Elem = 'w') -> increment_first(Start, ListOfScores);
            (Elem = 'b') -> increment_second(Start, ListOfScores);
                ListOfScores = Start
        )
    ).

% count_around_end_diagonal3(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos na diagonal superior direita da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo.
count_around_end_diagonal3(Board, Row, Col, Start, ListOfScores) :-
    RowAbove is Row - 1,
    ColRight is Col + 1,
    ((RowAbove < 0) -> ListOfScores = Start;
        custom_nth1(RowAbove, Board, RowAboveList),
        length(RowAboveList, Len),   
        Len1 is Len - 1,
        ((ColRight > Len1) -> ListOfScores = Start;  
            custom_nth1(ColRight, RowAboveList, Elem),
            ((Elem = 'w') -> increment_first(Start, ListOfScores);
                (Elem = 'b') -> increment_second(Start, ListOfScores);
                    ListOfScores = Start
            )
        )
    ).

% count_around_end_diagonal4(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos na diagonal inferior direita da posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo
count_around_end_diagonal4(Board, Row, Col, Start, ListOfScores) :-
    RowBelow is Row + 1,
    ColRight is Col + 1,
    ((RowBelow > 12) -> ListOfScores = Start;
        custom_nth1(RowBelow, Board, RowBelowList),
        length(RowBelowList, Len),
        Len1 is Len - 1,
        ((ColRight > Len1) -> ListOfScores = Start;
            custom_nth1(ColRight, RowBelowList, Elem),
            ((Elem = 'w') -> increment_first(Start, ListOfScores);
                (Elem = 'b') -> increment_second(Start, ListOfScores);
                    ListOfScores = Start
            )
        )
    ).

% count_around_end_under(+Board, +Row, +Col, +Start, -ListOfScores)
% Conta pontos diretamente sob a posição fornecida (Row, Col) no board.
% Se a peça lida for `w` incrementa no primeiro elemento da lista Start mas se for `b` incrementa no segundo
count_around_end_under(Board, Row, Col, Start, ListOfScores) :-
    custom_nth1(Row, Board, RowList),
    custom_nth1(Col, RowList, Elem),
    ((Elem = 'w') -> increment_first(Start, ListOfScores);
        (Elem = 'b') -> increment_second(Start, ListOfScores);
            ListOfScores = Start
    ).

% ---------------------------------------------------------------------------------------------------------------------------------------------

% max_position(+List, - MaxPosition)
% Caso base: Se a lista contiver apenas um elemento, sua posição será 0.
max_position([_MaxValue], 0) :- !.

% Caso recursivo:
% - Encontra a posição máxima do final da lista.
% - Se o início da lista for maior ou igual ao máximo do final, a posição máxima da lista é 0 (a posição atual).
max_position([Head | Tail], MaxPosition) :-
    max_position(Tail, _TailMaxPosition),
    find_max(Tail, TailMax),
    Head >= TailMax,
    MaxPosition is 0, !.

% Caso recursivo:
% - Se o início da lista for menor que o máximo do final, a posição máxima da lista é a posição máxima da cauda + 1.
max_position([Head | Tail], MaxPosition) :-
    max_position(Tail, TailMaxPosition),
    find_max(Tail, TailMax),
    Head < TailMax,
    MaxPosition is TailMaxPosition + 1.

% Predicado para encontrar a posição do valor máximo em uma lista.
find_max_position(List, MaxPosition) :-
    max_position(List, MaxPosition).

% max_or_zero(+X, +Y, -Max)
% Predicado que retorna valor máximo entre X e Y, porém se X = Y retorna 0.
max_or_zero(X, Y, Max) :-
    (X > Y, Max is X);
    (Y > X, Max is Y);
    (X =:= Y, Max is 0).

% max_in_list(+List, -Max)
% Caso Base: Se existe apenas um elemento na lista esse elemento é o maior.
max_in_list([X], X).

% Caso recursivo: Chama a função max_or_zero para os dois primeiros elementos de uma lista.
max_in_list([X, Y | Rest], Max) :-
    max_or_zero(X, Y, TempMax),
    max_in_list([TempMax | Rest], Max).


% max_in_list(+List, - Max)
% Caso base: Se a lista contiver apenas um elemento, o máximo será esse elemento.
max_in_list([X], X) :- !.

% Caso recursivo:
% - Se o início da lista for maior ou igual ao máximo do final, o máximo da lista é o cabeçalho.
max_in_list([Head | Tail], Max) :-
    max_in_list(Tail, TailMax),
    Head >= TailMax,
    Max is Head, !.

% Caso recursivo:
% - Se o início da lista for menor que o máximo do final, o máximo da lista é o máximo da cauda.
max_in_list([Head | Tail], Max) :-
    max_in_list(Tail, TailMax),
    Head < TailMax,
    Max is TailMax.

% Predicado para encontrar o valor máximo em uma lista.
find_max(List, Max) :-
    max_in_list(List, Max).

% ---------------------------------------------------------------------------------------------------------------------------------------------

% contains_p(+List)
% Predicado para verificar se existe um 'p' em uma lista.
contains_p([p|_]).
contains_p([_|T]) :- contains_p(T).

% check_board(+Board)
% Predicado para verificar se existe um 'p' no tabuleiro.
check_board(Board) :- 
    member(Row, Board),
    contains_p(Row).

% move(+GameState, +Move, -NewMove, -NewGameState)
% Se um movimento é válido escreve esse mesmo movimento no tabuleiro, se for inválido ele pede para escolher outro movimento. 	   
move([Player|Board], [PointX, PointY], [PointX1, PointY1], [NewPlayer|NewBoard]) :- 
    (check_if_valid(Board, PointX, PointY) ->
        PointX1 = PointX,
        PointY1 = PointY,
        replace(Board, PointX, PointY, Player, TempBoard),
        clean_playables(TempBoard, NewBoard),
        switch_player(NewPlayer, Player),
        write('Move'), nl,
        display_game([NewPlayer|NewBoard]); % tem que ser display do board sem os ps
        write('Invalid move. Try again.\n'),
        write('Player '), write(Player), write(', choose an X starting point:'),
        read(PointX2),
        write('Player '), write(Player), write(', now choose an Y starting point: '),
        read(PointY2),
        move([Player|Board], [PointX2, PointY2], [PointX1, PointY1], [NewPlayer|NewBoard])
    ).

% check_if_valid(+Board, +X, +Y)
% O predicado verifica se a posição (X, Y) é válida para jogar.
check_if_valid(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(X, Board, Row),
    nth0(Y, Row, p).

% update_board_first_play(+Board, +Player, +PointX, +PointY, -NewBoard)
% Predicado que altera o tabuleiro na primeira jogada.
update_board_first_play(Board, Player, PointX, PointY, NewBoard) :-
    replace(Board, PointX, PointY, Player, NewBoard),
    display_game_pie_rule(Board).

% replace(+Board, +X, +Y, +NewValue, -NewBoard)
% Substitui uma célula do tabuleiro por um novo valor.
replace([Row | Rest], 0, Y, NewValue, [NewRow | Rest]) :-
    replace_in_row(Row, 0, Y, NewValue, NewRow).
replace([Row | Rest], X, Y, NewValue, [Row | NewRest]) :-
    X > 0,
    X1 is X - 1,
    replace(Rest, X1, Y, NewValue, NewRest).

% replace_in_row(+Row, +X, +Y, +NewValue, -NewRow)
% Substitui uma célula da linha por um novo valor.
replace_in_row([_ | Rest], 0, Y, NewValue, [NewValue | Rest]) :-
    Y = 0; Y = p.
replace_in_row([Value | Rest], X, Y, NewValue, [Value | NewRest]) :-
    Y > 0,
    Y1 is Y - 1,
    replace_in_row(Rest, X, Y1, NewValue, NewRest).


% pie_rule(+GameState, -PlayerPos, -NewGameState)
% Aplicar a Pie Rule no modo Player Vs Player
% Um jogador escolhe a jogada inicial e o outro se quer ou não trocar de cor.
pie_rule([Player|Board], PlayerPos, [CurPlayer|NewBoard]) :-
    display_game_pie_rule(Board),
    write('\nPlayer 1\'s turn:'), nl, nl,
    write('Player '), write(Player), write(', choose an X starting point:'),
    read(PointX),
    write('Player '), write(Player), write(', now choose an Y starting point: '),
    read(PointY),
    (is_empty(Board, PointX, PointY) ->
        replace(Board, PointX, PointY, Player, TempBoard), % Player = b
        nl,
        write('Player 1\'s play:\n'),
        display_game_pie_rule(TempBoard),
        write('\nPlayer Whites, do you want to switch colors?\n'),
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

% is_empty(+Board, +X, +Y)
% Verifica se um ponto está vazio e se a jogada é feita dentro do board.
is_empty(Board, X, Y) :-
    is_inside(Board, X, Y),
    nth0(X, Board, Col),
    nth0(Y, Col, 0).

% is_inside(+Board, +X, +Y)
% Verifica se o ponto fornecido se encontra dentro do tabuleiro.
is_inside(Board, X, Y) :-
    length(Board, Rows),
    X >= 0,
    X < Rows,
    nth0(X, Board, Row),
    length(Row, Cols),
    Y >= 0,
    Y < Cols.

% report_winner(+Score, +Winner)
% Anuncia empate ou o vencedor do jogo.
report_winner(Score, Winner) :-
    (Winner \= t ->
        write('\nPlayer '), write(Winner), write(' is the WINNER!!!\n'),
        write('Scored '), write(Score), write(' points.\n\n\n')
        ;
        write('It\'s a draw! No one wins.\n'),
        write('Both players scored the same amount of points.\n')
    ).

% custom_nth1(+Index, +List, -Element)
% Predicado auxiliar para obter o elemento de uma lista num certo índice.
custom_nth1(0, [Element|_], Element).
custom_nth1(Index, [_|Rest], Element) :-
    Index > 0,
    NextIndex is Index - 1,
    custom_nth1(NextIndex, Rest, Element).


% swap(+Row, +Col, +Board, -NewBoard)
% Troca `0` por `p` em todas as direções de (Row, Col).
swap(Row, Col, Board, NewBoard) :-
    swapInDirection(Row, Col, Board, NewBoard).

% swapInDirection(+Row, +Col, +Board, -NewBoard)
% Troca `0` por `p` em todas as direções (cima, baixo, esquerda, direita e diagonais).
swapInDirection(Row, Col, Board, NewBoard) :-
    swapUp(Row, Col, Board, TempBoard1),
    swapDown(Row, Col, TempBoard1, TempBoard2),
    swapLeft(Row, Col, TempBoard2, TempBoard3),
    swapRight(Row, Col, TempBoard3, TempBoard4),
    swapDiagonal1(Row, Col, TempBoard4, TempBoard5),
    swapDiagonal2(Row, Col, TempBoard5, TempBoard6),
    swapDiagonal3(Row, Col, TempBoard6, TempBoard7),
    swapDiagonal4(Row, Col, TempBoard7, NewBoard).

% swapUp(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção de cima. 
% Caso Base: A linha é igual à coluna, o tabuleiro mantém-se.
swapUp(Col, Col, Board, NewBoard) :-
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapUp(Row, Col, Board, NewBoard) :-
    RowAbove is Row - 1,
    custom_nth1(RowAbove, Board, RowAboveList),
    custom_nth1(Col, RowAboveList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) ->
        replace_swap(Col, RowAboveList, p, NewRowAbove),
        replace_swap(RowAbove, Board, NewRowAbove, TempBoard),
        swapUp(RowAbove, Col, TempBoard, NewBoard);
    NewBoard = Board). 


% swapDown(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção de baixo. 
% Caso Base: A suma de Row e Col é igual a 12, o tabuleiro mantém-se.
swapDown(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapDown(Row, Col, Board, NewBoard) :-
    RowBelow is Row + 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    custom_nth1(Col, RowBelowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) -> 
        replace_swap(Col, RowBelowList, p, NewRowBelow),
        replace_swap(RowBelow, Board, NewRowBelow, TempBoard),
        swapDown(RowBelow, Col, TempBoard, NewBoard);
    NewBoard = Board).


% swapLeft(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da esquerda. 
% Caso Base: A coluna é igual a 0, o tabuleiro mantém-se.
swapLeft(_Row, 0, Board, NewBoard) :-
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapLeft(Row, Col, Board, NewBoard) :-
    custom_nth1(Row, Board, RowList),
    ColLeft is Col - 1,
    custom_nth1(ColLeft, RowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) -> 
        replace_swap(ColLeft, RowList, p, NewRowLeft),
        replace_swap(Row, Board, NewRowLeft, TempBoard),
        swapLeft(Row, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).


% swapRight(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da direita. 
% Caso Base: A coluna é igual à linha, o tabuleiro mantém-se.
swapRight(Row, Row, Board, NewBoard) :-
    NewBoard = Board.

% Caso Base: A suma de Row e Col é igual a 12, o tabuleiro mantém-se.
swapRight(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapRight(Row, Col, Board, NewBoard) :-
    custom_nth1(Row, Board, RowList),
    ColRight is Col + 1,
    custom_nth1(ColRight, RowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) ->  
        replace_swap(ColRight, RowList, p, NewRowRight),
        replace_swap(Row, Board, NewRowRight, TempBoard),
        swapRight(Row, ColRight, TempBoard, NewBoard);
    NewBoard = Board).


% swapDiagonal1(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da diagonal de cima e esquerda. 
% Caso Base: A coluna é igual a 0, o tabuleiro mantém-se.
swapDiagonal1(_Row, 0, Board, NewBoard) :-
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapDiagonal1(Row, Col, Board, NewBoard) :-
    RowAbove is Row - 1,
    ColLeft is Col - 1,
    custom_nth1(RowAbove, Board, RowAboveList),
    custom_nth1(ColLeft, RowAboveList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) ->  
        replace_swap(ColLeft, RowAboveList, p, NewTopLeft),
        replace_swap(RowAbove, Board, NewTopLeft, TempBoard),
        swapDiagonal1(RowAbove, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).


% swapDiagonal2(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da diagonal de baixo e esquerda. 
% Caso Base: A coluna é igual a '0', o tabuleiro mantém-se.
swapDiagonal2(_Row, 0, Board, NewBoard) :-
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
swapDiagonal2(Row, Col, Board, NewBoard) :-
    RowBelow is Row + 1,
    ColLeft is Col - 1,
    custom_nth1(RowBelow, Board, RowBelowList),
    custom_nth1(ColLeft, RowBelowList, Elem),
    ((Elem = w ; Elem = b) ->
        NewBoard = Board; 
    (Elem = 0) ->  
        replace_swap(ColLeft, RowBelowList, p, NewBottomLeft),
        replace_swap(RowBelow, Board, NewBottomLeft, TempBoard),
        swapDiagonal2(RowBelow, ColLeft, TempBoard, NewBoard);
    NewBoard = Board).


% swapDiagonal3(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da diagonal de cima e direita. 
% Caso Base: A linha é igual à coluna, o tabuleiro mantém-se.
swapDiagonal3(Col, Col, Board, NewBoard) :-
    NewBoard = Board.

% Caso Base: A linha menos a coluna é igual 1, o tabuleiro mantém-se.
swapDiagonal3(Row, Col, Board, NewBoard) :-
    Row - Col =:= 1,
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
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


% swapDiagonal4(+Row, +Col, + Board, -NewBoard)
% Muda '0' por 'p' no tabuleiro na direção da diagonal de cima e direita. 
% Caso Base: A linha mais a coluna é igual a 12, o tabuleiro mantém-se.
swapDiagonal4(Row, Col, Board, NewBoard) :-
    Row + Col =:= 12,
    NewBoard = Board.

% Caso Base: A linha mais a coluna é igual a 11, o tabuleiro mantém-se.
swapDiagonal4(Row, Col, Board, NewBoard) :-
    Row + Col =:= 11,
    NewBoard = Board.

% Caso Recursivo: Muda '0' por 'p' até chegar ao fim do tabuleiro ou encontrar um 'b' ou 'w'.
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

% ---------------------------------------------------------------------------------------------------

% replace_swap(+Index, + List, + Element, -NewList)
% Substitui um elemento em um índice específico em uma lista.
replace_swap(0, [_|Rest], Element, [Element|Rest]).

replace_swap(Index, [X|Rest], Element, [X|NewRest]) :-
    Index > 0,
    NewIndex is Index - 1,
    replace_swap(NewIndex, Rest, Element, NewRest).
    
% clean_playables(+Board, -NewBoard)
% Limpa os 'p' do tabuleiro de jogo.
clean_playables([], []).
clean_playables([Row|RestOfRows], [NewRow|NewRest]) :-
    replace_p_in_row(Row, NewRow),
    clean_playables(RestOfRows, NewRest).

% replace_p_in_row(+Row, -NewRow)
% Limpa os 'p' de um linha do tabuleiro.
replace_p_in_row([], []).
replace_p_in_row([p|Rest], [0|NewRest]) :-
    replace_p_in_row(Rest, NewRest).
replace_p_in_row([X|Rest], [X|NewRest]) :-
    X \= p,
    replace_p_in_row(Rest, NewRest).
