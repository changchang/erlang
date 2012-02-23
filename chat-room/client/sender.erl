-module(sender).
-export([start/2]).

%% enter for sender processor
start(Name, Socket) -> 
	loop(Name, Socket).

%% loop for sending messageloop(Name, Socket) -> 
loop(Name, Socket) ->
	receive
		{msg, Msg} -> 
			gen_tcp:send(Socket, protocol:sendMsg(Name, Msg)), 
			loop(Name, Socket);
		stop -> 
			io:format("sender processor stop.~n", [])
	end.