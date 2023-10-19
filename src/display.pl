initial_state(Size, GameState) :-
    GameState = [p1, 
        [x,x,x,x,x,x,x,0,x,x,x,x,x,x,x],
        [x,x,x,x,x,x,0,0,0,x,x,x,x,x,x],
        [x,x,x,x,x,0,0,0,0,0,x,x,x,x,x],
        [x,x,x,x,0,0,0,0,0,0,0,x,x,x,x],
        [x,x,x,0,0,0,0,0,0,0,0,0,x,x,x],
        [x,x,0,0,0,0,0,0,0,0,0,0,0,x,x],
        [x,0,0,0,0,0,0,0,0,0,0,0,0,0,x], 
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ],
    assertz(size(Size)).

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

identity(p1, I) :- I = '1'.  % Player 1
identity(p2, I) :- I = '2'.  % Player 2
identity(0, I) :- I = ' '.   % Empty space
identity(w, I) :- I = 'W'.   % White checker
identity(b, I) :- I = 'B'.   % Black checker
identity(p_w, I) :- I = 'w'. % Pinned white checker
identity(p_b, I) :- I = 'b'. % Pinned black checker
identity(x, I) :- I = 'X'.   % Non playable space
