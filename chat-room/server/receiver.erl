-module(receiver).
-export([start/2]).

% enter for recv processor
start(RegPid, Socket) -> 
	wait_reg(RegPid, Socket).

% wait for register request
wait_reg(RegPid, Socket) -> 
	PRO_REG = 1, 
	case gen_tcp:recv(Socket, 0) of
		{ok, Binary} -> 
			case parse_pkg(Binary) of 
				{PRO_REG, Name} -> 
					RegPid ! {reg, self(), Name, Socket}, 
					io:format("Join a new user ~p~n", [Name]), 
					loop(RegPid, Socket);
				_ -> 
					io:format("Invalid request, closing connection.~n", []), 
					gen_tcp:close(Socket)
			end;
		{error, closed} -> 
			io:format("connection closed.~n", [])
	end.

% loop for recv client message
loop(RegPid, Socket) -> 
	PRO_SEND_MSG = 2, 
	case gen_tcp:recv(Socket, 0) of 
		{ok, Binary} -> 
			case parse_pkg(Binary) of 
				{PRO_SEND_MSG, Msg} -> 
					RegPid ! {msg, self(), Msg}, 
					loop(RegPid, Socket);
				_ -> 
					io:format("Ignore invalid request.~n", []), 
					gen_tcp:close(Socket)
			end;
		{error, closed} -> 
			RegPid ! {close, self()}, 
			io:format("connection closed.~n", [])
	end.

% parse request package			
parse_pkg(pkg) -> 
	case pkg of 
		% ignore  length segment
		<<Type:8/integer, _:16/integer, Content/binary>> -> 
			{Type, Content};
		_ -> 
			{error, bad_package}
	end.