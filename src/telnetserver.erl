-module(telnetserver).
-export[start_server/1].
 
start_server(Port) ->
    csv_ets:load("test.csv"),
    {ok, Listen} = gen_tcp:listen(Port, [binary, {active, false}, {reuseaddr, true}]),
    spawn(fun() -> acceptor(Listen) end),
    ok.
 
acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> acceptor(ListenSocket) end),
    erlang:send_after(5000, self(), echo),
    handle(Socket).
 
handle(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {tcp, Socket, Msg} ->
            case handle_msg(Msg) of
              { reply, Reply } -> gen_tcp:send(Socket, Reply), handle(Socket);
              { error, Reply } -> gen_tcp:send(Socket, <<"Error! ", Reply/binary, "\n">>), handle(Socket);
              { error, _ }     -> gen_tcp:send(Socket, <<"Internal Error!\n">>), handle(Socket);
              quit -> gen_tcp:send(Socket, <<"Bye bye.\n">>), ok
            end;
        echo ->
            {H,M,S} = time(),
            Bin = << (integer_to_binary(H))/binary, ":",
                     (integer_to_binary(M))/binary, ":", 
                     (integer_to_binary(S))/binary, "\n" >>,
            %%gen_tcp:send(Socket, Bin),
            %%erlang:send_after(5000, self(), echo),
            handle(Socket)
    end.

handle_msg(<<"quit", _/binary>>) -> quit;
handle_msg(<<"get", Params/binary>>) -> { reply, process_get(Params) };
handle_msg(<<"set", Params/binary>>) -> 
  case process_set(Params) of
    { ok, Reply } -> { reply, Reply };
    { error, bad_params } -> { error, <<"Bad Params">> };
    _ -> { error, generic_error }
  end;
handle_msg(<<"flush", _/binary>>) ->
  csv_ets:save("temp.bak"),
  { reply, <<"Flush done.\n">> };  
handle_msg(<<Msg/binary>>) -> { reply, Msg }.
    
process_get(Msg) ->
  [_, Param] = binary:split(Msg, <<" ">>, [global]),
  Name = csvparser:trim(Param),
  case csv_ets:read(binary_to_list(Name)) of
    Value -> <<"Value = ", (num_to_binary(Value))/binary, "\n">>;
    { error, not_found } -> <<Name/binary, " not found.\n">>
  end.

%  Value = csv_ets:read(binary_to_list(Name)),
%  <<"Value = ", (num_to_binary(Value))/binary, "\n">>.

process_set(Msg) ->
  Params = binary:split(Msg, <<" ">>, [global]),
  case length(Params) of
    3 -> 
      [_, Param1, Param2] = Params,
      Name = csvparser:trim(Param1),
      Value = csvparser:trim(Param2),
      NumValue =
        try
          binary_to_integer(Value)
        catch
          error:badarg -> 
            binary_to_float(Value)
        end,
      csv_ets:write(binary_to_list(Name), NumValue),
      { ok, <<"set ", Name/binary, ",", Value/binary, " done.\n">> };
    _ ->
      { error, bad_params }
  end.

num_to_binary(X) when is_integer(X) -> integer_to_binary(X);
num_to_binary(X) when is_float(X) -> float_to_binary(X, [{decimals, 15}, compact]).


