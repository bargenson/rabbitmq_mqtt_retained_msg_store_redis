PROJECT = rabbitmq_mqtt_retained_msg_store_redis
PROJECT_DESCRIPTION = Retained message store implementation for Redis
PROJECT_MOD = rabbitmq_mqtt_retained_msg_store_redis

define PROJECT_ENV
[]
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
