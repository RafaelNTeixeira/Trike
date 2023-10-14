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

display_game([Player|Board]) :-
    nl,
    write('----|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|'),nl,
    size(Size),
    print_board(Board, Size),
    write('    |<A>|<B>|<C>|<D>|<E>|<F>|<G>|<H>|<I>|<J>|<K>|<L>|<M>|<N>|<O>|\n'), nl, nl,
    write('    > Turn of Player '),
    identity(Player, Identity), 
    write(Identity), write(' <'), nl, nl.

print_board([], 0).
print_board([Line|Matrix], Lines) :-
    write('<'),
    write(Lines),
    write('>'),
    (Lines < 10 -> write(' '); true), 
    write('| '), 
    print_line(Line), nl,
    write('\n----|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n'),
    RestLines is Lines - 1,
    print_board(Matrix, RestLines).

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
