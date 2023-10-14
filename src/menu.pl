menu :-
    clear_save,
    display_menu,
    read(Option), % ler valor inserido no menu
    run_mode(Option). % desencadeia ação da opção selecionada do menu

clear_save :-
    abolish(size/1),
    abolish(player/1).

display_menu :-
    write('  _________  ______ ______ \n'),
    write(' /_  __/ _ \\/  _/ //_/ __/ \n'),
    write('  / / / , _// // ,< / _/   \n'),
    write(' /_/ /_/|_/___/_/|_/___/   \n'),
    nl,
    write('1. Player Vs Player        \n'),
    write('2. Player Vs Computer(Easy)\n'),
    write('3. Player Vs Computer(Hard)\n'),
    write('4. Computer Vs Computer    \n'),
    write('5. Instructions            \n'), 
    write('0. Quit                    \n'),
    write('___________________________\n'),
    write('SELECT YOUR OPTION!\n').

run_mode(0) :-
    nl,
    write('          _________  ______ ______ \n'),
    write('         /_  __/ _ \\/  _/ //_/ __/ \n'),
    write('          / / / , _// // ,< / _/   \n'),
    write('         /_/ /_/|_/___/_/|_/___/   \n'),
    nl,
    write('\nThank you for playing. Hope to see you soon!\n').

run_mode(1) :-
    playing_order(1),
    playing_order(2),
    play_game,
    menu.

run_mode(2) :-
    write('\nMode 2\n').

run_mode(3) :-
    write('\nMode 3\n').

run_mode(4) :-
    write('\nMode 4\n').    

run_mode(5) :-
    nl, nl,
    write('Trike is a strategic and balanced abstract strategy game for two players played on a hexagonal grid.\n'),
    write('A neutral pawn is initially placed in the center of the board.\n\n'),
    write('PIE RULE:\n'),
    write('The first player selects a color and places a checker on the board.\n'),
    write('The second player can choose to swap sides.\n\n'),
    write('Gameplay:\n'),
    write('Players take turns moving the pawn and placing their checkers.\n'),
    write('The pawn moves in straight lines but can\'t pass through occupied points.\n\n'),
    write('Objective:\n'),
    write('The game ends when the pawn is trapped.\n'),
    write('Points are awarded for the number of checkers adjacently to checker that ended the game (checker that ended the game counts too).\n'),
    write('Trike is partisan, draw-less, finite, and always decisive.\n'),
    write('The game can be scaled with different board sizes.\n\n'),
    write('Note on Scoring:\n'),
    write('The last two moves earn extra points.\n\n\n'),
    write('0. Main menu\n\n'),
    read(0),
    menu.

playing_order(1) :-
    assertz(player(p1)).

playing_order(2) :-
    assertz(player(p2)).

