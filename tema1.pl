
% replace O in a list with R
replace(_, _, [], []).
replace(O, R, [O|T], [R | T2]):- replace(O, R, T, T2).
replace(O, R, [H|T], [H | T2]):- H \= O, replace(O, R, T, T2).

get_coord(Loc, X, Y):- Loc = [X, Y].
get_coord(Loc, X, Y):- Loc = [X, Y, _].

max(A, B, A):- A >= B.
max(A, B, B):- B > A.
get_energy([X, Y], Loc, 0, PE):- not(member([X, Y, energy], Loc)).
get_energy([X, Y], Loc, PE, PE):- member([X, Y, energy], Loc).

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

get_places([], Places, Places).
get_places([Loc|RL], Places, New_Places):- Loc = [X, Y, _],
                                           get_places(RL, [[X,Y] | Places], New_Places).

get_places([Loc|RL], Places, New_Places):- Loc = [X, Y],
                                           get_places(RL, [Loc | Places], New_Places).

                                                    
print_portal_info([X, Y], S, G):- write('[ '),
                                  write(X),
                                  write(', '),
                                  write(Y),
                                  write(' | '),
                                  write(S),
                                  write(', '),
                                  write(G),
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

compute_signal_for_portals([], Loc, EG, EI, P, P).
compute_signal_for_portals([Portal | RP], Loc, EG, EI, P, NewP):- get_signals(Portal, Loc, EG, EI, 0, 0, FE, FG), !,
                                                                  print_portal_info(Portal, FE, FG),
                                                                  write('   '),
                                                                  compute_signal_for_portals(RP, Loc, EG, EI, [[Portal, FE, FG] | P], NewP).

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
                                                            findall(NPlace,
                                                                    (member(NPlace,Places),not(member(NPlace, Portals)), NPlace \= Place),
                                                            Possible_Moves),
                                                            length(Possible_Moves, L),
                                                            R is random(L),
                                                            nth0(R, Possible_Moves, New_Portal),
                                                            update_portal_list(Place, New_Portal, Portal_List, Updated_Portal_List),
                                                            replace([Place, Portals], [Place, [New_Portal | Portals]], Updated_Portal_List, PL),
                                                            generate_portal(Place, Places, PL, NPortal_List).

generate_portal(Place, Places, Portal_List, NPortal_List):- not(member([Place, Portals], Portal_List)),
                                                            generate_portal(Place, Places, [[Place, []] | Portal_List],NPortal_List).


select_best_portal(Best_Portal, [], Best_Portal, Energy, Loc, GateEnergy, BestEnergy).

select_best_portal(Best_Portal, [Portal | RPortals], New_Portal, Energy, Loc, GateEnergy, BestEnergy):- Portal = [[X, Y], SE, SG],
                                                              member([X, Y, gate], Loc),
                                                              Energy < GateEnergy,
                                                              select_best_portal(Best_Portal,
                                                                  RPortals,
                                                                  New_Portal,
                                                                  Energy,
                                                                  Loc,
                                                                  GateEnergy,
                                                                  BestEnergy).

select_best_portal(Best_Portal, [Portal | RPortals], Portal, Energy, Loc, GateEnergy, BestEnergy):- Portal = [[X, Y], SE, SG],
                                                              member([X, Y, gate], Loc),
                                                              Energy >= GateEnergy.

select_best_portal(Best_Portal, [Portal | RPortals], New_Portal, Energy, Loc, GateEnergy, BestEnergy):- Portal = [[X, Y], SE, SG],
                                                              SE >= BestEnergy,
                                                              select_best_portal(Portal,
                                                                  RPortals,
                                                                  New_Portal,
                                                                  Energy,
                                                                  Loc,
                                                                  GateEnergy,
                                                                  SE).

select_best_portal(Best_Portal, [Portal | RPortals], New_Portal, Energy, Loc, GateEnergy, BestEnergy):- Portal = [[X, Y], SE, SG],
                                                              SE < BestEnergy,
                                                              select_best_portal(Best_Portal,
                                                                  RPortals,
                                                                  New_Portal,
                                                                  Energy,
                                                                  Loc,
                                                                  GateEnergy,
                                                                  BestEnergy).


move(Place, Energy,      _, Loc,           _,  _,  _, GateEnergy,           _, Sol):- get_coord(Place, X, Y),
                                                                                 member([X, Y, gate], Loc), Sol = [].

move(Place, Energy, Places, Loc, Portal_List, SE, SG, GateEnergy, PacketEnergy, Sol):- get_coord(Place, X, Y),
                      get_signals([X, Y], Loc, SG, SE, 0, 0, S, G),
                      generate_portal([X, Y], Places, Portal_List, NPortal_List), !,
                      member([[X, Y], Portals], NPortal_List),
                      print_current_loc_info(X, Y, Energy, G, S),
                      write(':  '),
                      compute_signal_for_portals(Portals, Loc, SG, SE, [], NewP),nl,
                      NewP = [H | RNewP],
                      select_best_portal(H, NewP, New_Portal, Energy, Loc, GateEnergy, 0),!,
                      New_Portal = [[NX, NY], _, _],
                      get_energy([NX, NY], Loc, E, PacketEnergy),
                      New_Energy is E + Energy,
                      replace([NX, NY, energy], [NX, NY], Loc, New_Loc),
                      move([NX, NY], New_Energy, Places, New_Loc, Portal_List, SE, SG, GateEnergy, PacketEnergy, Sol).

go(problema(Loc, Packets, Gate), Sol):- member(Initial, Loc),
                                           Initial = [_, _, initial],
                                           get_places(Loc, [], Places),
                                           Packets = pachete(SE, PacketEnergy),
                                           Gate = poarta(SG, GateEnergy),
                                           move(Initial, 0, Places, Loc, [], SE, SG, GateEnergy, PacketEnergy, Sol).

%go(problema([
%            [15, 15], [43, 5], [9, 25, initial], [25, 25, gate],
%            [50, 14, energy], [13, 31], [29, 36, energy], [40, 31],
%            [51, 33, energy]
%        ], pachete(17, 10), poarta(20, 25)), Solutie).

