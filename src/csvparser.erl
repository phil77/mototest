-module(csvparser).

-export([readfile/1, run/0, trim/1]).

trim(Bin = <<C,BinTail/binary>>) ->
    case is_whitespace(C) of
        true -> trim(BinTail);
        false -> trim_tail(Bin)
    end.

trim_tail(<<>>) -> <<>>;
trim_tail(Bin) ->
    Size = size(Bin) - 1,
    <<BinHead:Size/binary,C>> = Bin,
    case is_whitespace(C) of
        true -> trim_tail(BinHead);
        false -> Bin
    end.

is_whitespace($\s) -> true;
is_whitespace($\t) -> true;
is_whitespace($\n) -> true;
is_whitespace($\r) -> true;
is_whitespace(_) -> false.

parse_part(<<"\"", Rest/binary>>) ->
  binary_part(Rest, {0, byte_size(Rest)-1});

parse_part(T) ->
%  io:format("~p~n", [T]),
  try
    list_to_integer(binary_to_list(T))
  catch
    error:badarg -> 
        list_to_float(binary_to_list(T))
  end.
  


readfile(Filename) ->
  {ok, Binary} = file:read_file(Filename),
  Lines = binary:split(Binary, <<"\n">>, [global]),
%  io:format("~p~n", [Lines]),
  List = [begin
           T = [ parse_part(trim(Part))
           || Part <- binary:split(Line, <<",">>, [global]) ],
           list_to_tuple(T) 
          end || Line <- Lines, size(Line) > 0 ].
%  io:format("~p~n", [List]).


run() -> readfile("test.csv").

