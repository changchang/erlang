-module(register).
-export([start/0]).

% enter for register server
start() ->
	PidMap = dict:new(), 
	loop(PidMap).

% main loop for register server processor
loop(PidMap) -> 
	receive
		{reg, Pid, Name, Socket} -> 
			% register a new online user
			loop(dict:store(Pid, {Name, Socket}, PidMap));
		{msg, Pid, Msg} -> 
			% receive a new message
			try dict:fetch(Pid, PidMap) of
				{Name, _} -> 
					broadcast(Pid, Name, Msg, PidMap, dict:fetch_keys(PidMap)), 
					loop(PidMap)
			catch
				error:Error -> 
					io:format("fail to get Name by Pid. Pid=~p, Error=~p~n", [Pid, Error]), 
					loop(PidMap)
			end;
		{close, Pid} -> 
			dict:erase(Pid, PidMap), 
			loop(PidMap); 
		stop ->
			% stop register server processor
			io:format("register processor stop.~n", [])
	end.

% broadcast message to the other online user
broadcast(Sender, Name, Msg, PidMap, [Sender | Pids]) -> 
	broadcast(Sender, Name, Msg, PidMap, Pids);

broadcast(Sender, Name, Msg, PidMap, [Pid | Pids]) -> 
	PRO_NEW_MSG = 3, 
	try dict:fetch(Pid, PidMap) of
		{Name, Socket} -> 
			Content = list_to_binary(io_lib:format("~p|~p", Name, Msg)), 
			Len = byte_size(Content), 
			Data = <<PRO_NEW_MSG:16/integer, Len:8/integer, Content/binary>>, 
			gen_tcp:send(Socket, Data)
	catch
		error:Error -> 
			io:format("fail to get Name by Pid. Pid=~p, Error=~p~n", [Pid, Error])
	end, 
	broadcast(Sender, Name, Msg, PidMap, Pids).
	