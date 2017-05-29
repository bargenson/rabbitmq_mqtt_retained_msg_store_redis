-module(rabbitmq_mqtt_retained_msg_store_redis).

-behaviour(rabbit_mqtt_retained_msg_store).
-behaviour(application).
-behaviour(supervisor).

-include_lib("rabbitmq_mqtt/include/rabbit_mqtt.hrl").

-export([start/2, stop/1, init/1]).
-export([new/2, recover/2, insert/3, lookup/2, delete/2, terminate/1]).

-record(store_state, {
  redis_client,
  key_prefix
}).

start(normal, []) ->
  rabbit_log:info("Starting rabbitmq_mqtt_retained_msg_store_redis plugin..."),
  supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = []).

init([]) ->
  {ok, {{one_for_one, 3, 10}, []}}.

stop(_State) ->
  ok.

new(_Dir, VHost) -> connect_to_redis(VHost).

recover(_Dir, VHost) -> connect_to_redis(VHost).

connect_to_redis(VHost) ->
    rabbit_log:info("Connecting to Redis for VHost ~p...", [VHost]),
    case eredis:start_link() of
        {ok, Client} -> {ok, #store_state{redis_client = Client, key_prefix = binary_to_list(VHost)}};
        {error, Reason} -> {error, Reason}
    end.

insert(Topic, Message, #store_state{redis_client = Client, key_prefix = Prefix}) ->
    Key = Prefix ++ Topic,
%%    {mqtt_msg,true,1,"home/garden/fountain",false,2,<<"Coucou">>},
    rabbit_log:info("Inserting message ~p to Redis in key ~p...", [Message, Key]),
    case catch(eredis:q(Client, ["LPUSH", Key, term_to_binary(Message)])) of
        {ok, _} -> ok;
        {error, Reason} -> {error, Reason};
        {'EXIT', {timeout, _}} -> {error, timeout}
    end.

lookup(Topic, #store_state{redis_client = Client, key_prefix = Prefix}) ->
    Key = Prefix ++ Topic,
    rabbit_log:info("Getting message from Redis in key ~p...", [Key]),
    case catch(eredis:q(Client, ["RPOP", Key])) of
        {ok, undefined} -> not_found;
        {ok, Message} -> #retained_message{mqtt_msg = binary_to_term(Message), topic = Topic};
        {error, Reason} -> {error, Reason};
        {'EXIT', {timeout, _}} -> {error, timeout}
    end.

delete(Topic, #store_state{redis_client = Client, key_prefix = Prefix}) ->
    {ok, <<"OK">>} = eredis:q(Client, ["DEL", Prefix ++ Topic]).

terminate(#store_state{}) ->
    {ok, <<"OK">>}.
