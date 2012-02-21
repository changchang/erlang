-module(accept).
-export([start/2]).

start(RegPid, LSocket) -> 
	io:format("Accept processor started.~n", []), 
	loop(RegPid, LSocket).

loop(RegPid, LSocket) -> 
	case gen_tcp:accept(LSocket) of
		{ok, Socket} -> 
			Pid = spawn(receiver, start, [RegPid, Socket]), 
			loop(RegPid, LSocket);
		{error, Reason} -> 
			RegPid ! stop, 
			io:format("Access socket error, ~p~n", [Reason])
	end.