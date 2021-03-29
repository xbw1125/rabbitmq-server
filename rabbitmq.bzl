load("@bazel-erlang//:bazel_erlang_lib.bzl", "TEST_ERLC_OPTS", "erlang_lib", "test_erlang_lib")
load("@bazel-erlang//:ct.bzl", "ct_suite", "ct_test")
load("//deps/rabbitmq_cli:rabbitmqctl.bzl", "rabbitmqctl")
load("//deps/rabbitmq_cli:rabbitmqctl_test.bzl", "rabbitmqctl_test")

RABBITMQ_ERLC_OPTS = []

RABBITMQ_TEST_ERLC_OPTS = TEST_ERLC_OPTS + [
    "+debug_info",
    "+nowarn_export_all",
]

APP_VERSION = "3.9.0"

def required_plugins(rabbitmq_workspace = "@rabbitmq-server"):
    return [
        rabbitmq_workspace + "//deps/rabbit:bazel_erlang_lib",
    ]

def management_plugins(rabbitmq_workspace = "@rabbitmq-server"):
    return [
        rabbitmq_workspace + "//deps/rabbitmq_management:bazel_erlang_lib",
    ]

def rabbitmq_lib(
        app_name = "",
        app_version = APP_VERSION,
        app_description = "",
        app_module = "",
        app_registered = [],
        app_env = "[]",
        extra_apps = [],
        extra_erlc_opts = [],
        first_srcs = [],
        build_deps = [],
        deps = [],
        runtime_deps = []):
    erlang_lib(
        app_name = app_name,
        app_version = app_version,
        app_description = app_description,
        app_module = app_module,
        app_registered = app_registered,
        app_env = app_env,
        extra_apps = extra_apps,
        erlc_opts = RABBITMQ_ERLC_OPTS + extra_erlc_opts,
        first_srcs = first_srcs,
        build_deps = build_deps,
        deps = deps,
        runtime_deps = runtime_deps,
    )

    test_erlang_lib(
        app_name = app_name,
        app_version = app_version,
        app_description = app_description,
        app_module = app_module,
        app_registered = app_registered,
        app_env = app_env,
        extra_apps = extra_apps,
        erlc_opts = RABBITMQ_ERLC_OPTS + RABBITMQ_TEST_ERLC_OPTS + extra_erlc_opts,
        first_srcs = first_srcs,
        build_deps = build_deps,
        deps = deps,
        runtime_deps = runtime_deps,
    )

def rabbitmq_integration_suite(
        data = [],
        extra_erlc_opts = [],
        test_env = {},
        tools = [],
        deps = [],
        runtime_deps = [],
        **kwargs):
    ct_suite(
        erlc_opts = RABBITMQ_ERLC_OPTS + RABBITMQ_TEST_ERLC_OPTS + extra_erlc_opts,
        data = [
            "@rabbitmq_ct_helpers//tools/tls-certs:Makefile",
            "@rabbitmq_ct_helpers//tools/tls-certs:openssl.cnf.in",
        ] + data,
        test_env = dict({
            "RABBITMQ_CT_SKIP_AS_ERROR": "true",
            "RABBITMQ_RUN": "$TEST_SRCDIR/$TEST_WORKSPACE/rabbitmq-for-tests-run",
            "RABBITMQCTL": "$TEST_SRCDIR/$TEST_WORKSPACE/broker-for-tests-home/sbin/rabbitmqctl",
            "RABBITMQ_PLUGINS": "$TEST_SRCDIR/$TEST_WORKSPACE/broker-for-tests-home/sbin/rabbitmq-plugins",
        }.items() + test_env.items()),
        tools = [
            "//:rabbitmq-for-tests-run",
        ] + tools,
        runtime_deps = [
            "//deps/rabbitmq_cli:elixir_as_bazel_erlang_lib",
            "//deps/rabbitmq_cli:rabbitmqctl",
            "@rabbitmq_ct_client_helpers//:bazel_erlang_lib",
        ] + runtime_deps,
        deps = [
            "//deps/amqp_client:bazel_erlang_lib",
            "@rabbitmq_ct_helpers//:bazel_erlang_lib",
        ] + deps,
        **kwargs
    )
