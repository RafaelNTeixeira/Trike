/*
% get_element_at_index(List, Index, Element)

get_element_at_index([Element|_], 0, Element).
get_element_at_index([_|Rest], Index, Element) :-
    Index > 0,
    NextIndex is Index - 1,
    get_element_at_index(Rest, NextIndex, Element).

% Check if the element zero
is_zero(Element) :- 
    Element \= 0,
    !,
    write('Can not play there'), 
    fail.
*/