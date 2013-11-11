-module(csvparser).

-export([readfile/1]).

readfile(Filename) ->
  {ok, Binary} = file:read_file(Filename),
  List = binary:split(Binary, <<"\n">>, [global]),
  %io:write(List).
  
