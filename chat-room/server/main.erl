-module(main).
-export([start/1]).

start(Port) -> 
	RegPid = spawn(register, start, []), 
	case gen_tcp:listen(Port, [binary, {active, false}]) of 
		{ok, LSocket} -> 
			spawn(accept, start, [RegPid, LSocket]), 
			Pid = spawn(shutdown, start, [LSocket]), 
			io:format("Chat server started.~n", []), 
			Pid;
%			loop();
		{error, Reason} -> 
			RegPid ! stop, 
			io:format("Fail to start server for ~p~n", [Reason])
	end.
	
%loop() -> 
%	receive 
%		stop -> true;
%		_ -> loop()
%	end.