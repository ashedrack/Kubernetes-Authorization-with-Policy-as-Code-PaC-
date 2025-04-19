package kubernetes.admission

# Ensure NetworkPolicy exists for each namespace
deny[msg] {
    input.request.kind.kind == "Namespace"
    name := input.request.object.metadata.name
    not input.request.object.metadata.annotations["network-policy"]
    msg := sprintf("Namespace '%s' must specify a network policy annotation", [name])
}

# Deny ingress traffic from non-whitelisted namespaces
deny[msg] {
    input.request.kind.kind == "NetworkPolicy"
    ingress := input.request.object.spec.ingress[_]
    from := ingress.from[_]
    namespace := from.namespaceSelector.matchLabels.name
    not allowed_namespace(namespace)
    msg := sprintf("Ingress traffic from namespace '%s' is not allowed", [namespace])
}

# List of allowed namespaces
allowed_namespaces := {"default", "kube-system", "monitoring"}

allowed_namespace(namespace) {
    allowed_namespaces[namespace]
}
