load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_commit_layer")

container_run_and_commit_layer(
    name = "php_7_4_deps",
    commands = [
        "apt-get update",
    ],
    image = "@php_7_4_apache//image",
)
