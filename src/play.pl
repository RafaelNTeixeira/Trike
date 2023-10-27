:- consult('display.pl').
:- consult('logic.pl').
:- consult('menu.pl').
:- consult('auxiliar.pl').
:- use_module(library(lists)).
:- use_module(library(random)).

play :- 
    menu.
