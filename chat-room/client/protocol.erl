-module(protocol).
-export([login/1, sendMsg/1, parse/1]).
-include("constant.hrl").
-define(SEP, "|"). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% request package type:
%%% request: request to do something. 
%%%		format: Type(8bit), Body(optional, Len(16bit), Content);
%%% ps: Len would be ignored temporarily :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% compose login protocol
login(Name) -> 
	compose(?PRO_REQ_LOGIN, Name).

%% compose send message protocol
sendMsg(Msg) -> 
	compose(?PRO_REQ_SEND_MSG, Msg).

compose(Type, Content) -> 
	Data = list_to_binary(Content), 
	Len = byte_size(Data), 
	<<Type:8/integer, Len:16/integer, Data/binary>>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% server package type:
%%% response: response to some request. 
%%%		format: Type(8bit), Code(8bit), Body(optional, Len(16bit), Content);
%%% push message: message that server push to client, such as a new chat message notify, etc. 
%%%		format: Type(8bit), Body(optional, Len(16bit), Content)
%%% ps: Len would be ignored temporarily :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parse server package	
%% return: {Type, Code, {body, ...}} for response, {Type, {body, ...}} for push message or {error, bad_package} for error.
parse(Pkg) -> 
	case Pkg of 
		<<Type:8/integer, Body/binary>> -> 
			% check package type
			if
				Type < ?PRO_SEP ->
					% is response
					parseResponse(Type, Body);
				Type > ?PRO_SEP -> 
					% is push message
					parsePushMsg(Type, Body);
				true -> 
					{error, bad_package}
			end;
		<<Type:8/integer>> when Type > ?PRO_SEP ->
			% no body push message
			{Type, body}; 
		_ -> 
			{error, bad_package}
	end.

%% parse server response
%% return: {Type, Code, {body, ...}}
parseResponse(Type, Pkg) -> 
	case Pkg of 
		% ignore  length segment
		<<Code:8/integer, _:16/integer, Content/binary>> -> 
			% with content
			{Type, Code, {body, binary_to_list(Content)}};
		<<Code:8/integer>> -> 
			% no content
			{Type, Code, body};
		_ -> 
			{error, bad_package}
	end. 

%% parse server push message
%% return: {Type, {body, ...}}
parsePushMsg(Type, Pkg) -> 
	case Pkg of 
		<<_:16/integer, Content/binary>> -> 
			case Type of 
				?PRO_PSH_NEW_MSG -> 
					parseNewMsg(Type, Content);
				_ -> 
					{Type, {body, binary_to_list(Content)}}
			end;
		_ -> 
			{error, bad_package}
	end.

%% parse new message push
%% return: {Type, {body, SenderName, Content}}
parseNewMsg(Type, Pkg) -> 
	Body = binary_to_list(Pkg), 
	Index = string:str(Body, ?SEP), 
	if 
		Index > 0 -> 
			{Type, {body, string:sub_string(Body, 1, Index - 1), string:sub_string(Body, Index + 1)}};
		true -> 
			{Type, {body, "", Body}}
	end.
