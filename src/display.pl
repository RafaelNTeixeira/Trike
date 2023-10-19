initial_state(Size, GameState) :-
    GameState = [p1, 
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

/*
print_board(_, Lines, TotalLines) :- Lines > TotalLines. 
print_board([Line | Matrix], Lines, TotalLines) :-
    write('----|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|'), nl,
    write('<'), write(Lines), write('> | '),
    print_line(Line), nl,
    NextLines is Lines + 1,
    print_board(Matrix, NextLines, TotalLines).

display_game([Player|Board]) :-
    nl,
    size(Size),
    TotalLines is Size - 1, 
    print_board(Board, 0, TotalLines),
    write('----|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|'), nl,
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10| 11| 12| 13| 14|\n'), nl, nl,
    write('    > Turn of Player '),
    identity(Player, Identity), 
    write(Identity), write(' <'), nl, nl.

print_line([]).
print_line([Ele|RestLine]) :-
    identity(Ele, Identity),
    write(Identity),
    write(' | '),
    print_line(RestLine).
*/

display_board(Board) :-
    nl,
    write('  X\n'), 
    write('----|---|---|---|---|---|---|---|'), nl,
    display_rows(Board, 0),
    write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | Y\n'), nl, nl,
    nl.

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

identity(p1, I) :- I = '1'.  % Player 1
identity(p2, I) :- I = '2'.  % Player 2
identity(0, I) :- I = ' '.   % Empty space
identity(w, I) :- I = 'W'.   % White checker
identity(b, I) :- I = 'B'.   % Black checker
identity(p_w, I) :- I = 'w'. % Pinned white checker
identity(p_b, I) :- I = 'b'. % Pinned black checker
identity(x, I) :- I = 'X'.   % Non playable space
