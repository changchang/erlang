-module(receiver).
-export([start/1]).
-include("constant.hrl").

% enter for recv processor
start(Socket) -> 
	waitRegister(Socket).

% wait for register request
waitRegister(Socket) -> 
	case gen_tcp:recv(Socket, 0) of
		{ok, Binary} -> 
			case protocol:parse(Binary) of 
				{?PRO_REQ_LOGIN, {body, Name}} -> 
					registerUser(Name, Socket);
				_ -> 
					io:format("invalid request, closing connection.~n", []), 
					gen_tcp:close(Socket)
			end;
		{error, closed} -> 
			io:format("connection closed.~n", [])
	end.

%% register a user
%% check the user whether has logined, register him/her to the reg_server and response to client
registerUser(Name, Socket) -> 
	case whereis(list_to_atom(Name)) of 
		undefined -> 
			register(list_to_atom(Name), self()), 
			reg_server ! {reg, Name, Socket}, 
			io:format("join a new user ~ts~n", [Name]), 
			gen_tcp:send(Socket, protocol:response(?PRO_REQ_LOGIN, ?CODE_OK)), 
			loop(Name, Socket);
		_ -> 
			% user with the same Name already logined
			gen_tcp:send(Socket, protocol:response(?PRO_REQ_LOGIN, ?CODE_FAIL)), 
			gen_tcp:close(Socket)
	end.

%% loop for recv client request
loop(Name, Socket) -> 
	case gen_tcp:recv(Socket, 0) of 
		{ok, Binary} -> 
		case protocol:parse(Binary) of 
				{?PRO_REQ_SEND_MSG, {body, Msg}} -> 
					reg_server ! {msg, Name, Msg}, 
					loop(Name, Socket);
				_ -> 
					io:format("ignore invalid request. Package=~p~n", [Binary]), 
					loop(Name, Socket)
			end;
		{error, closed} -> 
			% it would unregister the Name if the processor return
			try reg_server ! {close, Name} of
				_ -> true
			catch 
				error:_ -> 
					true
			end, 
			io:format("connection closed.~n", [])
	end.
