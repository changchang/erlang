-module(input).
-export([start/2]).
-define(QUIT_CMD, ":q").

%% wait user input and send message to server. input :q to quit.

start(Name, Socket) -> 
	loop(Name, Socket).

loop(Name, Socket) -> 
	Line = string:strip(io:get_line("")), 
	if 
		Line =:= ?QUIT_CMD -> 
			gen_tcp:close(Socket);
		true ->
			gen_tcp:send(Socket, protocol:sendMsg(Name, Line)), 
			loop(Name, Socket)
	end.