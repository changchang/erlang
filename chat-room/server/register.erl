-module(register).
-export([start/0]).

% enter for register server
start() ->
	PidMap = dict:new(), 
	loop(PidMap).

% main loop for register server processor
loop(PidMap) -> 
	receive
		{reg, Name, Socket} -> 
			% register a new online user
			loop(dict:store(Name, Socket, PidMap));
		{msg, Name, Msg} -> 
			% receive a new message
			try dict:fetch(Name, PidMap) of
				_ -> 
					broadcast(Name, Msg, PidMap, dict:fetch_keys(PidMap)), 
					loop(PidMap)
			catch
				error:Error -> 
					io:format("fail to get socket by name. Name=~ts, Error=~ts~n", [Name, Error]), 
					loop(PidMap)
			end;
		{close, Name} -> 
			dict:erase(Name, PidMap), 
			io:format("logout user: ~ts~n", [Name]), 
			loop(PidMap); 
		stop ->
			% stop register server processor
			io:format("register processor stop.~n", [])
	end.

% broadcast message to the other online user
%broadcast(Sender, Msg, PidMap, [Sender | Names]) -> 
%	broadcast(Sender, Msg, PidMap, Names);

broadcast(Sender, Msg, PidMap, [Name | Names]) -> 
	PRO_NEW_MSG = 3, 
	try dict:fetch(Name, PidMap) of
		Socket -> 
			Content = list_to_binary(io_lib:format("~ts|~ts", [Sender, Msg])), 
			Len = byte_size(Content), 
			Data = <<PRO_NEW_MSG:8/integer, Len:16/integer, Content/binary>>, 
			gen_tcp:send(Socket, Data)
	catch
		error:Error -> 
			io:format("fail to get socket by name. Name=~ts, Error=~ts~n", [Name, Error])
	end, 
	broadcast(Sender, Msg, PidMap, Names);

broadcast(_, _, _, []) ->
	true. 
	