%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Console.
%%
%%   The Initial Developers of the Original Code are LShift Ltd.
%%
%%   Copyright (C) 2009 LShift Ltd.
%%
%%   All Rights Reserved.
%%
%%   Contributor(s): ______________________________________.
%%
-module(rabbit_management_connections).

-export([init/1, to_json/2, content_types_provided/2, is_authorized/2]).

-include_lib("webmachine/include/webmachine.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------

init(_Config) -> {ok, undefined}.
%%init(_Config) -> {{trace, "/tmp"}, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"application/json", to_json}], ReqData, Context}.

to_json(ReqData, Context) ->
    Conns = [format(Conn) ||
                Conn <- rabbit_management_stats:get_connection_stats()],
    {mochijson2:encode({struct,
                        [{node, node()},
                         {pid, list_to_binary(os:getpid())},
                         {datetime, list_to_binary(
                                      rabbit_management_util:http_date())},
                         {connections, [{struct, C} || C <- Conns]}
                        ]}), ReqData, Context}.

format(Conn) ->
    rabbit_management_format:format(
      Conn,
      [{fun rabbit_management_format:pid/1,   [pid]},
       {fun rabbit_management_format:ip/1,    [address, peer_address]},
       {fun rabbit_management_format:table/1, [client_properties]}]).

is_authorized(ReqData, Context) ->
    rabbit_management_util:is_authorized(ReqData, Context).
