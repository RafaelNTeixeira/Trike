:- consult('display.pl').
:- consult('logic.pl').
:- consult('menu.pl').
:- consult('bot.pl').
:- consult('auxiliar.pl').
:- use_module(library(lists)).

play :- 
    menu.
