-module(register).
-export([start/0]).

% enter for register server
start() ->
	ClientMap = dict:new(), 
	loop(ClientMap).

% main loop for register server processor
loop(ClientMap) -> 
	receive
		{reg, Name, Socket} -> 
			% register a new online user
			loop(dict:store(Name, Socket, ClientMap));
		{msg, Name, Msg} -> 
			% receive a new message
			broadcast(Name, Msg, ClientMap), 
			loop(ClientMap);
		{close, Name} -> 
			% close a client by recv processor
			dict:erase(Name, ClientMap), 
			io:format("logout user: ~ts~n", [Name]), 
			loop(ClientMap); 
		stop ->
			% stop register server processor
			closeSockets(ClientMap), 
			io:format("register processor stop.~n", [])
	end.

%% broadcast message to online user
broadcast(SenderName, Msg, ClientMap) -> 
	dict:map(fun(RecvName, Socket) -> 
			if 
				SenderName =:= RecvName -> 
					% we will push the message to the sender, too
					gen_tcp:send(Socket, protocol:newMsg(SenderName, Msg)), 
					Socket;
				true -> 
					gen_tcp:send(Socket, protocol:newMsg(SenderName, Msg)), 
					Socket
			end
		end,
		ClientMap
	).

%% close all client connections
closeSockets(ClientMap) -> 
	dict:map(fun(_, Socket) -> 
			gen_tcp:close(Socket), 
			Socket
		end,
		ClientMap
	).