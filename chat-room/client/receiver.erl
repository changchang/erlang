-module(receiver).
-export([start/1]).
-include("constant.hrl").

%% receive server message and show it in console.

start(Socket) -> 
	loop(Socket).

loop(Socket) -> 
	case gen_tcp:recv(Socket, 0) of
		{ok, Package} -> 
		case protocol:parse(Package) of 
				{?PRO_PSH_NEW_MSG, {body, Name, Msg}} -> 
					io:format("~ts Say: ~ts~n", [Name, Msg]), 
					loop(Socket);
				_ -> 
					loop(Socket)
			end;
		{error, Reason} -> 
			io:format("socket close, Reason=~p~n", [Reason])
	end.