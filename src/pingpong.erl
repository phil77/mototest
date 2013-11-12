-module(pingpong).

-export([start/0, stop/1]).

start() ->
  PongPid = spawn(fun pong_proc/0),
  PingPid = spawn(fun() -> ping_proc(PongPid) end),
  [PingPid, PongPid].

ping_proc(Pid) ->
  Pid ! {ping, self()},
  receive
    pong ->
      io:format("PingProc: got pong~n")
  after 3000 ->
    io:format("PingProc: It appears PongProc is dead. Exiting...~n"),
    exit(stop)
  end,
  timer:sleep(random:uniform(5000)+100),
  ping_proc(Pid).


pong_proc() ->
  receive
    { ping, Pid } ->
      io:format("PongProc: got ping~n"),
      Pid ! pong
  end,
  pong_proc().

stop(PidList) ->
  [ exit(Pid, stop) || Pid <- PidList ].

