# Implementing Policy as Code with OPA, Terraform, and GitHub Actions for EKS

In modern cloud-native environments, managing security policies at scale can be challenging. This article explores how we implemented Policy as Code (PaC) using Open Policy Agent (OPA), Terraform, and GitHub Actions for our Amazon EKS infrastructure. We'll dive into the implementation details, challenges faced, and lessons learned.

## Introduction

Policy as Code (PaC) is an approach where security policies are defined, versioned, and enforced using code. This brings several benefits:
- Version control and change tracking
- Automated testing and validation
- Consistent policy enforcement
- Infrastructure as Code (IaC) integration

In our project, we combined three powerful tools:
1. **Open Policy Agent (OPA)**: For policy definition and enforcement
2. **Terraform**: For infrastructure provisioning
3. **GitHub Actions**: For automated validation and deployment

## Project Structure

Our project follows a clear separation of concerns:

```
.
├── policies/
│   ├── rbac/
│   │   ├── image_policy.rego
│   │   ├── network_policy.rego
│   │   └── pod_security.rego
│   └── rebac/
│       └── account_access.rego
├── tests/
│   └── account_access_test.rego
├── docs/
│   └── policies.md
└── .github/workflows/
    └── opa-validation.yml
```

## Policy Implementation

### 1. RBAC Policies

We implemented three core RBAC policies:

#### Image Policy
This policy ensures container images come from trusted sources and have explicit version tags:
```rego
deny[msg] if {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not startswith(container.image, "ghcr.io/your-org/")
    msg := sprintf("Container '%s' uses an unauthorized image: %s", 
                  [container.name, container.image])
}
```

#### Network Policy
Controls network access between namespaces:
```rego
deny[msg] if {
    input.request.kind.kind == "NetworkPolicy"
    ingress := input.request.object.spec.ingress[_]
    from := ingress.from[_]
    namespace := from.namespaceSelector.matchLabels.name
    not allowed_namespace(namespace)
    msg := sprintf("Ingress traffic from namespace '%s' is not allowed", 
                  [namespace])
}
```

#### Pod Security Policy
Enforces container security best practices:
- No privileged containers
- Resource limits required
- Non-root user requirement
- Read-only root filesystem

### 2. ReBAC (Relationship-based Access Control)

We implemented a sophisticated ReBAC system that handles:
- Customer account access
- Parent-child account relationships
- Team resource sharing

```rego
allow if {
    input.subject.role == "customer"
    input.resource.type == "account"
    input.resource.owner_id == input.subject.id
}
```

## Continuous Integration Pipeline

Our GitHub Actions workflow automates policy validation:

1. **Syntax Validation**:
   ```yaml
   - name: Validate Rego Syntax
     run: opa check policies/
   ```

2. **Unit Testing**:
   ```yaml
   - name: Run Policy Unit Tests
     run: opa test policies/ tests/ --verbose
   ```

3. **Documentation Generation**:
   ```yaml
   - name: Generate Policy Documentation
     run: |
       mkdir -p docs
       for f in policies/**/*.rego; do
         echo "# $(basename ${f%.*})" >> docs/policies.md
         echo '```rego' >> docs/policies.md
         cat $f >> docs/policies.md
         echo '```' >> docs/policies.md
         echo "" >> docs/policies.md
       done
   ```

## Challenges and Solutions

### 1. OPA Syntax Evolution
We faced challenges with OPA's syntax requirements changing between versions. Key learnings:
- Use array comprehension syntax for deny rules: `deny[msg] if`
- Properly scope variables within rules
- Maintain consistent rule structure across policies

### 2. Testing Strategy
We developed a comprehensive testing approach:
- Unit tests for individual policies
- Integration tests for policy combinations
- Real-world scenario validation

### 3. Documentation Automation
We automated documentation generation to ensure:
- Up-to-date policy documentation
- Consistent formatting
- Easy policy review and auditing

## Best Practices

1. **Policy Organization**:
   - Group related policies together
   - Use clear, descriptive names
   - Maintain consistent structure

2. **Testing**:
   - Write tests for both positive and negative cases
   - Test edge cases thoroughly
   - Automate test execution

3. **Documentation**:
   - Document policy purpose and requirements
   - Include examples and use cases
   - Automate documentation updates

4. **CI/CD**:
   - Validate policies on every change
   - Generate documentation automatically
   - Maintain version control

## Future Enhancements

1. **Policy Monitoring**:
   - Implement policy violation monitoring
   - Create dashboards for policy compliance
   - Set up alerting for violations

2. **Advanced Policies**:
   - Cost optimization policies
   - Security posture improvement
   - Compliance automation

3. **Integration Improvements**:
   - Enhanced testing frameworks
   - Policy simulation tools
   - Impact analysis capabilities

## Conclusion

Implementing Policy as Code with OPA, Terraform, and GitHub Actions has significantly improved our security posture and operational efficiency. The combination of these tools provides a robust foundation for managing and enforcing policies at scale.

Key benefits realized:
- Automated policy enforcement
- Consistent security controls
- Reduced manual review overhead
- Improved compliance tracking

By following the practices outlined in this article, organizations can effectively implement Policy as Code and enhance their security governance.

## Resources

- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Project Repository](https://github.com/yourusername/EKS-Terraform-GitHub-Actions)

---

*This article is based on real implementation experience. The code examples have been simplified for clarity but represent actual working solutions.*
