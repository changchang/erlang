-module(main).
-export([start/3, start/0]).
-define(QUIT_CMD, ":q").

%% start client, connect to server and spawn receiver, input processor.

start(Name, Host, Port) -> 
	{ok, Socket} = gen_tcp:connect(Host, Port, [binary, {active, false}]), 
	spawn(receiver, start, [Socket]), 
	gen_tcp:send(Socket, protocol:login(Name)), 
	loop(Name, Socket).

start() -> 
	Name = "chang", 
	{ok, Socket} = gen_tcp:connect("localhost", 3333, [binary, {active, false}]), 
	spawn(receiver, start, [Socket]), 
	gen_tcp:send(Socket, protocol:login(Name)), 
%	spawn(input, start, [Name, Socket]).
	loop(Name, Socket).

loop(Name, Socket) -> 
	Line = string:strip(io:get_line(""), both, $\n), 
	if 
		Line =:= ?QUIT_CMD -> 
			gen_tcp:close(Socket);
		true ->
			gen_tcp:send(Socket, protocol:sendMsg(Line)), 
			loop(Name, Socket)
	end.