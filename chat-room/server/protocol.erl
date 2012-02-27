-module(protocol).
-export([response/2, response/3, push/1, push/2, parse/1, new_msg/2]).
-include("constant.hrl").
-define(SEP, "|"). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% server package type:
%%% response: response to some request. 
%%%		format: Type(8bit), Code(8bit), Body(optional, Len(16bit), Content);
%%% push message: message that server push to client, such as a new chat message notify, etc. 
%%%		format: Type(8bit), Body(optional, Len(16bit), Content)
%%% ps: Len would be ignored temporarily :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% compose response
response(Type, Code) -> 
	<<Type:8/integer, Code:8/integer>>.

%% compose response
response(Type, Code, Content) -> 
	Data = unicode:characters_to_binary(Content), 
	Len = byte_size(Data), 
	<<Type:8/integer, Code:8/integer, Len:16/integer, Data/binary>>.

%% compose push message
push(Type) -> 
	<<Type:8/integer>>.

%% compose push message
push(Type, Content) -> 
	Data = unicode:characters_to_binary(Content), 
	Len = byte_size(Data), 
	<<Type:8/integer, Len:16/integer, Data/binary>>. 

%% compose new message push message
new_msg(Sender, Msg) -> 
	Content = unicode:characters_to_binary(io_lib:format("~ts|~ts", [Sender, Msg])), 
	Len = byte_size(Content), 
	<<?PRO_PSH_NEW_MSG:8/integer, Len:16/integer, Content/binary>>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% request package type:
%%% request: request to do something. 
%%%		format: Type(8bit), Body(optional, Len(16bit), Content);
%%% ps: Len would be ignored temporarily :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parse request package
%% return: {Type, {body, ...}} or {error, bad_package}		
parse(Pkg) -> 
	case Pkg of 
		<<Type:8/integer, Len:16/integer, Body:Len/binary>> -> 
			{Type, {body, unicode:characters_to_list(Body)}};
		_ -> 
			{error, bad_package}
	end.

