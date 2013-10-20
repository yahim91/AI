
% replace O in a list with R
replace(_, _, [], []).
replace(O, R, [O|T], [R | T2]):- replace(O, R, T, T2).
replace(O, R, [H|T], [H | T2]):- H \= O, replace(O, R, T, T2).

get_coord(Loc, X, Y):- Loc = [X, Y].
get_coord(Loc, X, Y):- Loc = [X, Y, _].

max(A, B, A):- A >= B.
max(A, B, B):- B > A.

get_signals(_, [], EG, EI, E, G, E, G).
get_signals(Curr_place, [Loc | RL], EG, EI, E, G, FE, FG):- Loc = [X, Y, gate],
                                                       Curr_place = [MX, MY],
                                                       Dist is abs(MX - X) + abs(MY - Y),
                                                       CS is EG - Dist,
                                                       max(CS, 0, NI),
                                                       NG is NI + G,
                                                       get_signals(Curr_place, RL, EG, EI, E, NG, FE, FG).

get_signals(Curr_place, [Loc | RL], EG, EI, E, G, FE, FG):- Loc = [X, Y, energy],
                                                       Curr_place = [MX, MY],
                                                       Dist is abs(MX - X) + abs(MY - Y),
                                                       CS is EI - Dist,
                                                       max(CS, 0, NI),
                                                       NE is NI + E,
                                                       get_signals(Curr_place, RL, EG, EI, NE, G, FE, FG).

get_signals(Curr_place, [Loc | RL], EG, EI, E, G, FE, FG):- get_signals(Curr_place, RL, EG, EI, E, G, FE, FG).

                                                    
print_portal_info([X, Y], S, E):- write('[ '),
                                  write(X),
                                  write(', '),
                                  write(Y),
                                  write(' | '),
                                  write(S),
                                  write(', '),
                                  write(E),
                                  write(' ]').

print_current_loc_info(X, Y, E, S, G):- write('[ '),
                                        write(X),
                                        write(', '),
                                        write(Y),
                                        write(' |'),
                                        write(E),
                                        write('| '),
                                        write(S),
                                        write(', '),
                                        write(G),
                                        write(' ]').

update_portal_list(Place, New_Portal, Portal_List, New_Portal_List):- not(member([New_Portal, _], Portal_List)),
                                                                      New_Portal_List = [[New_Portal, [Place]] | Portal_List].

update_portal_list(Place, New_Portal, Portal_List, New_Portal_List):- member([New_Portal, Portals], Portal_List),
                                                                      not(member(Place, Portals)),
                                                                      replace([New_Portal, Portals],
                                                                          [New_Portal, [Place | Portals]],
                                                                          Portal_List,
                                                                          New_Portal_List).
                                                                      
generate_portal(Place, Places, Portal_List, Portal_List):- member([Place, Portals], Portal_List),
                                              length(Portals, 3).

generate_portal(Place, Places, Portal_List, NPortal_List):- member([Place, Portals], Portal_List),
                                                            not(length(Portals, 3)),
                                                            findall(NPlace,(member(NPlace,Places),not(member(NPlace, Portals))), Possible_Moves),
                                                            length(Possible_Moves, L),
                                                            R is random(L),
                                                            nth0(R, Possible_Moves, New_Portal),
                                                            update_portal_list(Place, New_Portal, Portal_List, Updated_Portal_List),
                                                            replace([Place, Portals], [Place, [New_Portal | Portals]], Updated_Portal_List, PL),
                                                            generate_portal(Place, Places, PL, NPortal_List).

generate_portal(Place, Places, Portal_List, NPortal_List):- not(member([Place, Portals], Portal_List)),
                                                            generate_portal(Place, Places, [[Place, []] | Portal_List],NPortal_List).
                                                            
move(Place, Energy):- get_coord(Place, X, Y).
go(problema(Places, Packets, Gate), Sol):- member(Initial, Places), Initial = [_, _, initial], Sol = [], move(Initial, 0).

%go(problema([
%            [15, 15], [43, 5], [9, 25, initial], [25, 25, gate],
%            [50, 14, energy], [13, 31], [29, 36, energy], [40, 31],
%            [51, 33, energy]
%        ], pachete(17, 10), poarta(20, 25)), Solutie).

