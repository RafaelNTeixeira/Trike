% initial_state(+Size, + GameState)
% Constrói o estado inicial de um tabuleiro triangular e salva-o no *GameState*.
initial_state(_Size, GameState) :-
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

% display_game_pie_rule(+Board)
% Mostra o tabuleiro para a primeira jogada.
display_game_pie_rule(Board) :-
    nl,
    write('  X\n'), 
    write('----|---|---|---|---|---|---|---|'), nl,
    display_rows(Board, 0),
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | Y\n').

% display_game(+GameState)
% Motra o tabuleiro em função do GameState.
display_game([Player|Board]) :-
    nl,
    write('  X\n'), 
    write('----|---|---|---|---|---|---|---|'), nl,
    display_rows(Board, 0),
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | Y\n'), nl,
    write('Player '), write(Player), write(' turn'), nl.

% display_rows(+Row, +N)
% Mostra as linhas do tabuleiro. 
display_rows([], _).
display_rows([Row | Rest], N) :-
    (N < 10 -> write(' '); true),
    write('<'), write(N), write('>'), 
    write('|'),
    display_row(Row, N), nl,
    write('----|---|---|---|---|---|---|---|'), nl,
    NextN is N + 1,
    display_rows(Rest, NextN).

% display_row(+Row, +N)
% Mostra a linha do tabuleiro. 
display_row([], _).
display_row([Cell | Rest], N) :-
    write(' '),
    ((Cell = 0) -> write('.');
        (Cell = p) -> write('x');
            (Cell = b) -> write('B');
                (Cell = w) -> write('W');
        write(Cell)
    ),
    write(' |'),
    display_row(Rest, N).

