-module(shutdown).
-export([start/1]).

start(LSocket) -> 
	loop(LSocket).

loop(LSocket) -> 
	receive 
		stop -> 
			gen_tcp:close(LSocket), 
			reg_server ! stop, 
			true;
		_ -> loop(LSocket)
	end.