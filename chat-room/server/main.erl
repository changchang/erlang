-module(main).
-export([start/1]).

start(Port) -> 
	register(reg_server, spawn(register, start, [])), 
	case gen_tcp:listen(Port, [binary, {active, false}]) of 
		{ok, LSocket} -> 
			spawn(accept, start, [LSocket]), 
			Pid = spawn(shutdown, start, [LSocket]), 
			io:format("chat server started.~n", []), 
			Pid;
%			loop();
		{error, Reason} -> 
			reg_server ! stop, 
			io:format("fail to start server for ~p~n", [Reason])
	end.
	
%loop() -> 
%	receive 
%		stop -> true;
%		_ -> loop()
%	end.