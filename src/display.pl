initial_state(Size, GameState) :-
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
    ],
    assertz(size(Size)).

display_game_pie_rule(Board) :-
    nl,
    write('  X\n'), 
    write('----|---|---|---|---|---|---|---|'), nl,
    display_rows(Board, 0),
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | Y\n'), nl, nl.

display_game([Player|Board]) :-
    nl,
    write('  X\n'), 
    write('----|---|---|---|---|---|---|---|'), nl,
    display_rows(Board, 0),
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | Y\n'), nl, nl,
    write('Player '), write(Player), write(' turn'), nl, nl.

display_rows([], _).
display_rows([Row | Rest], N) :-
    write('<'), write(N), write('>'), 
    (N < 10 -> write(' '); true),
    write('|'),
    display_row(Row, N), nl,
    write('----|---|---|---|---|---|---|---|'), nl,
    NextN is N + 1,
    display_rows(Rest, NextN).

display_row([], _).
display_row([Cell | Rest], N) :-
    write(' '),
    write(Cell),
    write(' |'),
    display_row(Rest, N).

print_padding(N) :-
    N > 0,
    write(' '),
    NextN is N - 1,
    print_padding(NextN).
print_padding(0).

identity(0, I) :- I = ' '.   % Empty space
identity(w, I) :- I = 'W'.   % White checker
identity(b, I) :- I = 'B'.   % Black checker
identity(p_w, I) :- I = 'w'. % Pinned white checker
identity(p_b, I) :- I = 'b'. % Pinned black checker
identity(x, I) :- I = 'X'.   % Non playable space
