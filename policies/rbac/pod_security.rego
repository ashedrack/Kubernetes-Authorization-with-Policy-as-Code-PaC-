package kubernetes.admission

# Deny privileged containers and enforce security policies
deny = messages {
    messages := {
        msg |
        input.request.kind.kind == "Pod";
        container := input.request.object.spec.containers[_];
        container.securityContext.privileged == true;
        msg := sprintf("Container '%s' must not run as privileged", [container.name])
    } | {
        msg |
        input.request.kind.kind == "Pod";
        container := input.request.object.spec.containers[_];
        not container.resources.limits;
        msg := sprintf("Container '%s' must specify resource limits", [container.name])
    } | {
        msg |
        input.request.kind.kind == "Pod";
        container := input.request.object.spec.containers[_];
        not container.securityContext.runAsNonRoot == true;
        msg := sprintf("Container '%s' must run as non-root user", [container.name])
    } | {
        msg |
        input.request.kind.kind == "Pod";
        container := input.request.object.spec.containers[_];
        not container.securityContext.readOnlyRootFilesystem == true;
        msg := sprintf("Container '%s' must use a read-only root filesystem", [container.name])
    }
}
