:- consult('display.pl').
:- consult('logic.pl').
:- consult('menu.pl').
:- consult('bot.pl').
:- use_module(library(lists)).
:- use_module(library(random)).

% play/0
% Inicia o jogo.
play :- 
    menu.
