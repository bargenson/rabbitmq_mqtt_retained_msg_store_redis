PROJECT = rabbitmq_mqtt_retained_msg_store_redis
PROJECT_DESCRIPTION = Retained message store implementation for Redis
PROJECT_MOD = rabbitmq_mqtt_retained_msg_store_redis

define PROJECT_ENV
[
	    {default_user, <<"guest">>},
	    {default_pass, <<"guest">>},
	    {ssl_cert_login,false},
	    {allow_anonymous, true},
	    {vhost, <<"/">>},
	    {exchange, <<"amq.topic">>},
	    {subscription_ttl, 86400000}, %% 24 hours
	    {retained_message_store, rabbit_mqtt_retained_msg_store_redis},
	    {prefetch, 10},
	    {ssl_listeners, []},
	    {num_ssl_acceptors, 1},
	    {tcp_listeners, [1883]},
	    {num_tcp_acceptors, 10},
	    {tcp_listen_options, [{backlog,   128},
	                          {nodelay,   true}]},
	    {proxy_protocol, false}
	  ]
endef

DEPS = rabbit_common rabbit eredis rabbitmq_mqtt
TEST_DEPS = rabbitmq_ct_helpers rabbitmq_ct_client_helpers

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-plugin.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-plugin.mk

# FIXME: Use erlang.mk patched for RabbitMQ, while waiting for PRs to be
# reviewed and merged.

ERLANG_MK_REPO = https://github.com/rabbitmq/erlang.mk.git
ERLANG_MK_COMMIT = rabbitmq-tmp

include rabbitmq-components.mk
include erlang.mk
