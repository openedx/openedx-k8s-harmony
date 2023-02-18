This is a plugin for Tutor to make it easier to deploy multiple Tutor instances
onto a single cluster. This disables the use of Caddy as an external endpoint
and instead uses it only for per-instance routing. An Ingress is used to
automatically register each Open edX instance with a central NGINX load
balancer that routes traffic for the whole cluster.
