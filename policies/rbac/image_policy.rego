package kubernetes.admission

deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not startswith(container.image, "ghcr.io/your-org/")
    msg := sprintf("Container '%s' uses an unauthorized image: %s", [container.name, container.image])
}

deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("Container '%s' must specify an image tag", [container.name])
}
