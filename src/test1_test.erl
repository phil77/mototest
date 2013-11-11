-module(test1_test).
-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").

first_test() ->
  ?assertEqual(test1_app:search_kth(3, [a,b,c,d]), c),
  ?assertEqual(test1_app:remove_kth(4, [a,b,c,d,e,f]), [a,b,c,e,f]).


%prop_delete() ->
%  ?FORALL({X,L}, {integer(), list(integer())},
%                  not lists:member(X, lists:delete(X,L))).

%prop_remove_kth() ->
%  ?FORALL(N, pos_integer(), 
%                  length(test1_app:remove_kth(X,L)) == length(L)-1 ).


proper_test() ->
  ?assertEqual(
    proper:module(?MODULE, [{to_file,  user},
                            {numtests, 1000}]),
                            []).

