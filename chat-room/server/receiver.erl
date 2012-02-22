-module(receiver).
-export([start/1]).

% enter for recv processor
start(Socket) -> 
	wait_reg(Socket).

% wait for register request
wait_reg(Socket) -> 
	PRO_REG = 1, 
	case gen_tcp:recv(Socket, 0) of
		{ok, Binary} -> 
			case parse_pkg(Binary) of 
				{PRO_REG, Name} -> 
					reg_server ! {reg, Name, Socket}, 
					io:format("join a new user ~ts~n", [Name]), 
					loop(Name, Socket);
				_ -> 
					io:format("invalid request, closing connection.~n", []), 
					gen_tcp:close(Socket)
			end;
		{error, closed} -> 
			io:format("connection closed.~n", [])
	end.

% loop for recv client message
loop(Name, Socket) -> 
	PRO_SEND_MSG = 2, 
	case gen_tcp:recv(Socket, 0) of 
		{ok, Binary} -> 
			case parse_pkg(Binary) of 
				{PRO_SEND_MSG, Msg} -> 
					reg_server ! {msg, Name, Msg}, 
					loop(Name, Socket);
				_ -> 
					io:format("ignore invalid request.~n", []), 
					gen_tcp:close(Socket)
			end;
		{error, closed} -> 
			reg_server ! {close, Name}, 
			io:format("connection closed.~n", [])
	end.

% parse request package			
parse_pkg(Pkg) -> 
	case Pkg of 
		% ignore  length segment
		<<Type:8/integer, _:16/integer, Content/binary>> -> 
			{Type, Content};
		_ -> 
			{error, bad_package}
	end.