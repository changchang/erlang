%% client to server (request)
-define(PRO_REQ_LOGIN, 101).
-define(PRO_REQ_SEND_MSG, 102).

%% separator for requeset and push message
-define(PRO_SEP, 200).

%% server to client (push message)
-define(PRO_PSH_NEW_MSG, 201).

%% code
-define(CODE_OK, 1).
-define(CODE_FAIL, -1).