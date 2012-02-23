-module(main).
-export([start/3, start/0]).
-include("constant.hrl").
-define(QUIT_CMD, ":q").

%% start client, connect to server and spawn receiver, input processor.

start(Name, Host, Port) -> 
	{ok, Socket} = gen_tcp:connect(Host, Port, [binary, {active, false}]), 
	login(Name, Socket).

start() -> 
	Name = "chang", 
	{ok, Socket} = gen_tcp:connect("localhost", 3333, [binary, {active, false}]), 
	login(Name, Socket).

%% try to login with Name
login(Name, Socket) -> 
	gen_tcp:send(Socket, protocol:login(Name)), 
	case gen_tcp:recv(Socket, 0) of 
		{ok, Package} -> 
			case protocol:parse(Package) of 
				{?PRO_REQ_LOGIN, ?CODE_OK, body} -> 
					% login ok
					spawn(receiver, start, [Socket]), 
					loop(Name, Socket);
				_ -> 
					io:format("fail to login with Name:~ts~n", [Name])
			end;
		{error, Reason} -> 
			io:format("socket close, Reason=~p~n", [Reason])
	end.

%% loop to recv console input
loop(Name, Socket) -> 
	Line = string:strip(io:get_line(""), both, $\n), 
	if 
		Line =:= ?QUIT_CMD -> 
			gen_tcp:close(Socket);
		true ->
			gen_tcp:send(Socket, protocol:sendMsg(Line)), 
			loop(Name, Socket)
	end.