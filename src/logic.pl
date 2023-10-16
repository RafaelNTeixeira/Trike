% play_game will receive Level variable
play_game(Level):- 
    initial_state(8, GameState),
    display_game(GameState).
    gameplayfirstround(GameState, level).

gameplay(GameState, _Level) :-
    % end condition
    % winner condition

gameplay(GameState, Level) :-
    % get the player that is going to play now
    % get available moves
    % move pieces
    display_game(NewGameState),
    gameplay(NewGameState, Level).

checkificanplay(GameState, Row, Column) :- 
    Row1 is Row - 48, % 0 is 48.
    Column1 is Column - 97, % a is 97.
    get_element_at_index(GameState, Row, RowList),
    get_element_at_index(RowList, Column, Elem),
    is_zero(Elem).


chooseposition(GameState, Row, Column) :-
    repeat,
    write("Choose the starting position."),
    write("Choose Row (The row between 1 - 8): "),
    read(Row),
    write("Choose Column (The column between a - o): "),
    read(Column),
    checkificanplay(GameState, Row, Column).

update_board(Board, Player, PointX, PointY, NewBoard) :-
    switch_player(Player, Opponent),
    replace(Board, PointX, PointY, Player, TempBoard),
    move_pawn(TempBoard, PointX, PointY, NewBoard, Opponent).
    
gameplayfirstround(GameState, Level) :-
    chooseposition(GameState),
    update_board()

/*  
    Pie Rule:
    - The first player choose the starting position;
    - The second player as the chance to change color with the first player. 
*/

apply_pie_rule(Board, Player, NewBoard) :-
    display_board(Board),
    write('Player '), write(Player), write(', choose a starting point (X Y): '),
    read(PointX), read(PointY),
    (is_empty(Board, PointX, PointY) ->
        update_board(Board, Player, PointX, PointY, NewBoard);
        write('Invalid choice. Try again.\n'),
        apply_pie_rule(Board, Player, NewBoard)
    ).