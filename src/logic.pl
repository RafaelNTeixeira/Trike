% play_game will receive Level variable
play_game(Level):- 
    initial_state(8, GameState),
    display_game(GameState).
    gameplay(GameState, level).

gameplay(GameState, _Level) :-
    % end condition
    % winner condition

gameplay(GameState, Level) :-
    % get the player that is going to play now
    % get available moves
    % move pieces
    display_game(NewGameState),
    gameplay(NewGameState, Level).

