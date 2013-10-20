
replace(_, _, [], []).
replace(O, R, [O|T], [R | T2]):- replace(O, R, T, T2).
replace(O, R, [H|T], [H | T2]):- H \= O, replace(O, R, T, T2).


generate_portal(Place, Places, Portal_List, Portal_List):- member([Place, Portals], Portal_List),
                                              length(Portals, 3).

generate_portal(Place, Places, Portal_List, NPortal_List):- member([Place, Portals], Portal_List),
                                                            not(length(Portals, 3)),
                                                            findall(NPlace,(member(NPlace,Places),not(member(NPlace, Portals))), Possible_Moves),
                                                            length(Possible_Moves, L),
                                                            R is random(L),
                                                            nth0(R, Possible_Moves, New_Portal),
                                                            replace([Place, Portals], [Place, [New_Portal | Portals]], Portal_List, PL),
                                                            generate_portal(Place, Places, PL, NPortal_List).

generate_portal(Place, Places, Portal_List, NPortal_List):- not(member([Place, Portals], Portal_List)),
                                                            generate_portal(Place, Places, [[Place, []] | Portal_List],NPortal_List).
                                                            
move(Place, Energy):- Place = [X, Y, initial],
                              write('[ '),
                              write(X),
                              write(', '),
                              write(Y),
                              write(' | '),
                              write(Energy),
                              write(' ]').
go(problema(Places, Packets, Gate), Sol):- member(Initial, Places), Initial = [_, _, initial], Sol = [], move(Initial, 0).

%go(problema([
%            [15, 15], [43, 5], [9, 25, initial], [25, 25, gate],
%            [50, 14, energy], [13, 31], [29, 36, energy], [40, 31],
%            [51, 33, energy]
%        ], pachete(17, 10), poarta(20, 25)), Solutie).

