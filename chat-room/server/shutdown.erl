-module(shutdown).
-export([start/1]).

start(LSocket) -> 
	loop(LSocket).

loop(LSocket) -> 
	receive 
		stop -> 
			gen_tcp:close(LSocket), 
			true;
		_ -> loop(LSocket)
	end.