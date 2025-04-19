resource "kubernetes_namespace" "opa" {
  metadata {
    name = "opa"
  }
}

resource "helm_release" "opa_gatekeeper" {
  name       = "gatekeeper"
  namespace  = kubernetes_namespace.opa.metadata[0].name
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  version    = "3.12.0"

  set {
    name  = "replicas"
    value = 3
  }

  set {
    name  = "auditInterval"
    value = "60"
  }

  set {
    name  = "constraintViolationsLimit"
    value = "100"
  }

  set {
    name  = "audit.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "audit.resources.limits.memory"
    value = "1024Mi"
  }
}

# Create ConfigMap for OPA policies
resource "kubernetes_config_map" "opa_policies" {
  metadata {
    name      = "opa-policies"
    namespace = kubernetes_namespace.opa.metadata[0].name
  }

  data = {
    "image_policy.rego"     = file("${path.module}/../../policies/rbac/image_policy.rego")
    "pod_security.rego"     = file("${path.module}/../../policies/rbac/pod_security.rego")
    "network_policy.rego"   = file("${path.module}/../../policies/rbac/network_policy.rego")
    "account_access.rego"   = file("${path.module}/../../policies/rebac/account_access.rego")
  }
}

# Deploy OPA webhook configuration
resource "kubernetes_validating_webhook_configuration" "opa_validating_webhook" {
  metadata {
    name = "opa-validating-webhook"
  }

  webhook {
    name = "validating.gatekeeper.sh"

    client_config {
      service {
        name      = "gatekeeper-webhook-service"
        namespace = kubernetes_namespace.opa.metadata[0].name
        path      = "/v1/admit"
      }
      ca_bundle = data.kubernetes_secret.webhook_server_cert.data["ca.crt"]
    }

    rule {
      api_groups   = ["*"]
      api_versions = ["*"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["*"]
    }

    failure_policy = "Ignore"
    side_effects   = "None"

    admission_review_versions = ["v1", "v1beta1"]
  }
}
