# OPA Policies Documentation

This document provides documentation for all OPA policies in the repository.

## RBAC Policies

### Image Policy
```rego
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
```

### Network Policy
```rego
package kubernetes.admission

# Ensure NetworkPolicy exists for each namespace
deny[msg] if {
    input.request.kind.kind == "Namespace"
    name := input.request.object.metadata.name
    not input.request.object.metadata.annotations["network-policy"]
    msg := sprintf("Namespace '%s' must specify a network policy annotation", [name])
}

# Deny ingress traffic from non-whitelisted namespaces
deny[msg] if {
    input.request.kind.kind == "NetworkPolicy"
    ingress := input.request.object.spec.ingress[_]
    from := ingress.from[_]
    namespace := from.namespaceSelector.matchLabels.name
    not allowed_namespace(namespace)
    msg := sprintf("Ingress traffic from namespace '%s' is not allowed", [namespace])
}

# List of allowed namespaces
allowed_namespaces := {"default", "kube-system", "monitoring"}

allowed_namespace(namespace) if {
    allowed_namespaces[namespace]
}
```

### Pod Security Policy
```rego
package kubernetes.admission

# Deny privileged containers
deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("Container '%s' must not run as privileged", [container.name])
}

# Enforce resource limits
deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not container.resources.limits
    msg := sprintf("Container '%s' must specify resource limits", [container.name])
}

# Block root user
deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not container.securityContext.runAsNonRoot == true
    msg := sprintf("Container '%s' must run as non-root user", [container.name])
}

# Enforce read-only root filesystem
deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem == true
    msg := sprintf("Container '%s' must use a read-only root filesystem", [container.name])
}
```

## ReBAC Policies

### Account Access Policy
```rego
package permissions

default allow = false

# Allow users to access their own accounts
allow if {
    input.subject.role == "customer"
    input.resource.type == "account"
    input.resource.owner_id == input.subject.id
}

# Allow parent accounts to access child accounts
allow if {
    input.subject.relation == "parent"
    input.resource.type == "account"
    input.resource.child_id == input.subject.child_id
}

# Allow team members to access shared resources
allow if {
    input.subject.role == "team_member"
    input.resource.type == "shared"
    input.resource.team_id == input.subject.team_id
}
```
