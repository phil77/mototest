-module(test1_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).
-export([search_kth/2, remove_kth/2, divide_at/2]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    application:start(test1).

start(_StartType, _StartArgs) ->
    test1_sup:start_link().

stop(_State) ->
    ok.


%% Soem training functions

search_kth( 1, [H|_] ) -> H ;
search_kth( K, [_|T] ) -> search_kth( K-1, T ).

remove_kth(K, List) -> remove_kth(K, List, []). 
remove_kth(_, [], Acc) -> lists:reverse(Acc); 
remove_kth(1, [_|T], Acc) -> lists:reverse(Acc, T); 
remove_kth(K, [H|T], Acc) -> remove_kth(K-1, T, [H|Acc]). 

divide_at( K, List ) -> divide_at( K, List, [] ).
divide_at( _, [], _) -> { throw(badarg) };
divide_at( 1, [H|T], Acc) -> { lists:reverse(Acc, [H]), T };
divide_at( K, [H|T], Acc) -> divide_at(K-1, T, [H|Acc]).

%random_swap( List ) ->
%    {List1, List2} = divide_at(random:uniform(length(List)), List).

