-module(protocol).
-export([login/1, sendMsg/1, parse/1]).
-include("constant.hrl").
-define(SEP, "|"). 

% compose login protocol
login(Name) -> 
	compose(?PRO_LOGIN, Name).

% compose send message protocol
sendMsg(Msg) -> 
	compose(?PRO_SEND_MSG, Msg).

compose(Type, Data) -> 
	Content = list_to_binary(Data), 
	Len = byte_size(Content), 
	<<Type:8/integer, Len:16/integer, Content/binary>>.

% parse request package			
parse(Pkg) -> 
	case Pkg of 
		% ignore  length segment
		<<Type:8/integer, _:16/integer, Content/binary>> when Type == ?PRO_NEW_MSG -> 
			Body = binary_to_list(Content), 
			Index = string:str(Body, ?SEP), 
			if 
				Index > 0 -> 
					{Type, string:sub_string(Body, 1, Index - 1), string:sub_string(Body, Index + 1)};
				true -> 
					{Type, "", Body}
			end;
		<<Type:8/integer, _:16/integer, Content/binary>> ->
			{Type, Content};
		_ -> 
			{error, bad_package}
	end.
