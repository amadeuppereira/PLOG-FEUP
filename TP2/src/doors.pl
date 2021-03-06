doors_calculator(Board) :-
  length(Board, NRows),
  NRows1 is NRows - 1,
  nth1(1, Board, Line),
  length(Line, NCols),
  NCols1 is NCols - 1,
  create_matrix(NRows, NCols1, Vertical),
  create_matrix(NRows1, NCols, Horizontal),
  % Use 1 for door present and 0 for door absent
  flatten(Vertical, VerticalFlat),
  flatten(Horizontal, HorizontalFlat),
  append(VerticalFlat, HorizontalFlat, Vars),
  domain(Vars, 0, 1),
  % Apply restriction on each cell
  (   for(R, 1, NRows),
      param(Board),
      param(Vertical),
      param(Horizontal),
      param(NCols)
  do  ( for(C, 1, NCols),
        param(Board),
        param(Vertical),
        param(Horizontal),
        param(R)
      do restrict_cell(Board, Vertical, Horizontal, [R,C])
      )
  ),
  reset_timer,
  labeling([ffc], Vars),
  print_time,
  fd_statistics,
  print_board(Board, Vertical, Horizontal).

length_list(N, L) :- length(L, N).
create_matrix(R, C, M) :-
  length_list(R, M),
  maplist(length_list(C), M).

calculate_value([], 0).
calculate_value([H|T], V) :-
  calculate_value(T, V1),
  V #= H + H*V1.

/**
 * restrict_cell/4
 * restrict_cell(+Board, +Vertical, +Horizontal, +Cell).
 * Computes the four accumulators on cell [R,C], and bind them
 * to the value of the respective cell in the Board.
 */
restrict_cell(Board, _, _, [R,C]) :-
  matrixnth1([R,C], Board, 0), !.
restrict_cell(Board, Vertical, Horizontal, [R,C]) :-
  matrixnth1([R,C], Board, Value),
  right_total(Vertical, [R,C], Right),
  left_total(Vertical, [R,C], Left),
  top_total(Horizontal, [R,C], Top),
  bot_total(Horizontal, [R,C], Bot),
  Right + Left + Top + Bot + 1 #= Value.

/**
 * right_total/3
 * right_total(+Vertical, +[R,C], -Total).
 * Compute the accumulator function to the right of cell [R,C].
 */
right_total(Vertical, [R,C], Total) :-
  nth1(R, Vertical, L),
  Pop is C - 1,
  popn(Pop, L, Sublist),
  calculate_value(Sublist, Total).

/**
 * left_total/3
 * left_total(+Vertical, +[R,C], -Total).
 * Compute the accumulator function to the left of cell [R,C].
 */
left_total(Vertical, [R,C], Total) :-
  nth1(R, Vertical, L),
  reverse(L, Reversed),
  matrix_length(Vertical, _, V),
  Pop is V - C + 1,
  popn(Pop, Reversed, Sublist),
  calculate_value(Sublist, Total).

/**
 * top_total/3
 * top_total(+Vertical, +[R,C], -Total).
 * Compute the accumulator function upwards of cell [R,C].
 */
top_total(Horizontal, [R,C], Total) :-
  matrix_col(C, Horizontal, L),
  reverse(L, Reversed),
  matrix_length(Horizontal, H, _),
  Pop is H - R + 1,
  popn(Pop, Reversed, Sublist),
  calculate_value(Sublist, Total).

/**
 * bot_total/3
 * bot_total(+Vertical, +[R,C], -Total).
 * Compute the accumulator function downwards of cell [R,C].
 */
bot_total(Horizontal, [R,C], Total) :-
  matrix_col(C, Horizontal, L),
  Pop is R - 1,
  popn(Pop, L, Sublist),
  calculate_value(Sublist, Total).
