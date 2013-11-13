-module(myserver_gen).
 
-behaviour(gen_server).
 
%% API
-export([start_link/0]).
-export([inc/1]).
 
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).
 
-define(SERVER, ?MODULE).
 
-record(state, { counter }).
 
%%% API
start_link() ->
    gen_server:start_link(?MODULE, [], []).
%    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
 
inc(S) ->
    gen_server:call(S, inc).

%%% gen_server callbacks
init([]) ->
    {ok, #state{counter=0}}.
 
handle_call(inc, _From, State) ->
    Reply = { ok, State#state.counter },
    NewState = State#state{counter=State#state.counter + 1},
    {reply, Reply, NewState}.
 
handle_cast(_Msg, State) ->
    {noreply, State}.
 
handle_info(_Info, State) ->
    {noreply, State}.
 
terminate(_Reason, _State) ->
    ok.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
 
%%% Internal functions
