-module(myserver_gen).
 
-behaviour(gen_server).
 
%% API
-export([start_link/0]).
-export([write/2, read/1, flush/0]).
 
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).
 
-define(SERVER, ?MODULE).
 
-record(state, { dirty }).
 
%%% API
start_link() ->
%    gen_server:start_link(?MODULE, [], []).
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
 
read(UserId) ->
  gen_server:call(?SERVER, { read, UserId }).

write(UserId, Amount) ->
  gen_server:call(?SERVER, { write, UserId, Amount }).

flush() ->
  gen_server:cast(?SERVER, { flush }).

%%% gen_server callbacks
init([]) ->
  csv_ets:load("test.csv"),
  {ok, #state{dirty=false}}.
 
handle_call({read, UserId}, _From, State) ->
  Reply = csv_ets:read(binary_to_list(UserId)),
  {reply, Reply, State};
handle_call({write, UserId, Amount}, _From, State) ->
  Reply = csv_ets:write(binary_to_list(UserId), Amount),
  NewState = State#state{dirty=true},
  {reply, Reply, NewState}.

handle_cast({flush}, #state{dirty=true}=State) ->
  csv_ets:save("test.csv"),
  {noreply, State#state{dirty=false}};
handle_cast({flush}, State) ->
  {noreply, State}.
 
handle_info(_Info, State) ->
    {noreply, State}.
 
terminate(_Reason, _State) ->
    ok.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
 
%%% Internal functions
