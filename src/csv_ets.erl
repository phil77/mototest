-module(csv_ets).

-export([load/1, save/1, read/1, write/2]).

load(Filename) ->
  Db = csvparser:readfile(Filename),
  ets:new(csvdb, [named_table, public]),
  [ insert_into_db(Entry) || Entry <- Db ].
%%  ets:insert(csvdb, Db).

insert_into_db(Entry) ->
  {X,_} = Entry,
  case read(binary_to_list(X)) of
    { error, not_found } -> ets:insert(csvdb, [Entry]);
    _ -> { error, dup }
  end.

save(Filename) ->
  Bin = << <<"\"", Name/binary, "\",", (num_to_binary(Value))/binary, "\n">> 
     || {Name, Value} <- ets:tab2list(csvdb) >>,
  file:write_file(Filename, Bin, [write]).

num_to_binary(X) when is_integer(X) -> integer_to_binary(X);
num_to_binary(X) when is_float(X) -> float_to_binary(X, [{decimals, 15}, compact]).

read(UserId) -> 
  case ets:lookup(csvdb, list_to_binary(UserId)) of 
    [{_, Value}] -> { ok, Value };
    [] -> { error, not_found }
  end.

write(UserId, Amount) ->
  ets:insert(csvdb, {list_to_binary(UserId), Amount}).

