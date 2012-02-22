-module(accept).
-export([start/1]).

start(LSocket) -> 
	io:format("accept processor started.~n", []), 
	loop(LSocket).

loop(LSocket) -> 
	case gen_tcp:accept(LSocket) of
		{ok, Socket} -> 
			spawn(receiver, start, [Socket]), 
			loop(LSocket);
		{error, Reason} -> 
			io:format("accept processor stop, socket status:~p~n", [Reason])
	end.