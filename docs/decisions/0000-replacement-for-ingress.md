# 0. Replacement for Ingress NGINX

## Status

**Draft** *2026-02-23*

## Context

On november 11, 2025, the Kubernetes SIG Network and the Security
Response Comitee announced the [retirement of ingress
NGINX](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement).
All support for the project will stop on march 2026. This includes new
features, bug fixes and security updates.

An Ingress controller is integral to the Harmony project, providing a
standardized and cost efficient way of exposing HTTP services in a
Kubernetes cluster. The controller implementation that Harmony uses is the
Ingress NGINX controller, the most widely adopted one, with around
[50% of Kubernetes clusters using
it](https://securitylabs.datadoghq.com/articles/kubernetes-ingress-nginx-retirement-warning/).
The sun setting of Ingress NGINX presents a security risk to the project,
prompting a proper replacement to face the deprecation.

This ADR proposes a migration plan from Ingress NGINX to an alternative
controller implementation.

## Decision

The Traefik Ingress controller will be added to the Harmony project to
serve as a replacement for Ingress NGINX. A "transition" release will
be published with support for both controller implementations, before
fully removing Ingress NGINX in the following release.

Although the Kubernetes Ingress API defines a standardized routing
compatibilities shared between implementations, individual controllers add
custom behavior through annotations specific to each vendor, which complicates
the transition process. Among the [list of available third party
controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#third-party-ingress-controllers),
Traefik stood out due to it's [compatibility
layer](https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress-nginx/#annotations-support)
with Ingress NGINX, specifically designed to ease the migration process.

## Consequences

- The latest release of the Traefik controller will be added to Harmony, with
  support for the NGINX provider by default.
- Custom annotations for NGINX will be translated to the Treafik equivalent.
- The ingress NGINX Helm chart will be removed from the project.

## Rejected Alternatives

- **Keep using Ingress NGINX**: The Ingress NGINX codebase have faced multiple
  security issues along the years, with [four new vulnerabilities disclosed this
  year](https://groups.google.com/a/kubernetes.io/g/dev/c/9RYJrB8e8ts). Using
  Ingress NGINX after the support stops would be a huge security risk.
- **Migrate to GatewayAPI**: The Kubernetes project recommends using Gateway
  instead of Ingress. Although the Ingress API is froze, it still remains well
  supported, and performing a migration between controller implementations is
  much feasible task than migrating to a new API, specially considering the
  current timeline. 


## References

1. https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement
1. https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress-nginx/#annotations-support
1. https://securitylabs.datadoghq.com/articles/kubernetes-ingress-nginx-retirement-warning/
1. https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress-nginx/#annotations-support
1. https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/ingress-nginx/#annotations-support
1. https://groups.google.com/a/kubernetes.io/g/dev/c/9RYJrB8e8ts
