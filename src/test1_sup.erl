-module(test1_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Port = 
    case application:get_env(test1, telnet_port) of
        { ok, Value } -> Value;
        undefined -> 1234
    end,
    {ok, { {one_for_one, 5, 10}, 
           [ ?CHILD(myserver_gen, worker),
             {telnetserver, {telnetserver, start_link, [Port]}, permanent, brutal_kill, worker, [telnetserver]} ]} }.

