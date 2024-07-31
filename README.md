# Harmony Project - Open edX on Kubernetes

This project is focused on making it easy to set up a standardized, scalable, secure Kubernetes environment that can host **multiple instances** of [Open edX](https://www.openedx.org). See [Motivation](#motivation) below.

Specifically, this repository contains:

* A Helm Chart that can install necessary shared resources into your cluster (a load balancer / ingress controller, autoscaling infrastructure, monitoring tools, databases, etc.)
* A [Tutor](https://docs.tutor.overhang.io/) plugin that configures Tutor to build images that will use the shared resources deployed by the Helm chart.

This repository does not set up the Kubernetes cluster or provision individual Open edX instances.

See [technology stack and architecture](#technology-stack-and-architecture) below for more details.

## Motivation

Many Open edX providers and users have a need to deploy multiple instances of Open edX onto Kubernetes, but there is currently no standardized way to do so and each provider must build their own tooling to manage that. This project aims to provide an easy and standardized approach that incorporates industry best practices and lessons learned.

In particular, this project aims to provide the following benefits to Open edX operators:

* **Ease of use** and **rapid deployment**: This project aims to provide an Open edX hosting environment that just works out of the box, that can be easily upgraded, and that follows best practices for monitoring, security, etc.
* **Lower costs** by sharing resources where it makes sense. For example, by default Tutor's k8s feature will deploy a separate load balancer and ingress controller for each Open edX instance, instead of a shared ingress controller for all the instances in the cluster. Likewise for MySQL, MongoDB, ElasticSearch, and other resources. By using shared resources by default, costs can be dramatically reduced and operational monitoring and maintenance is greatly simplified.
  * For setups with many small instances, this shared approach provides a huge cost savings with virtually no decrease in performance.
  * For larger instances on the cluster that need dedicated resources, they can easily be configured to do so.
* **Scalable hosting** for instances of any size. This means for example that the default configuration includes autoscaling of LMS pods to handle increased traffic.
* **Flexibility**: this project aims to be "batteries included" and to support setting up all the resources that you need, with useful default configurations, but it is carefully designed so that operators can configure, replace, or disable any components as needed.

## Technology stack and architecture

1. At the base is a Kubernetes cluster, which you must provide (e.g. using OpenTofu to provision Amazon EKS).
   * Any cloud provider such as AWS or Digital Ocean should work. There are OpenTofu examples in the `infra-examples` folder but it is just a starting point and not recommended for production use.
2. On top of that, this project's helm chart will install the shared resources you need - an ingress controller, monitoring, database clusters, etc. The following are included but can be disabled/replaced if you prefer an alternative:
   * Ingress controller: [ingress-nginx](https://kubernetes.github.io/ingress-nginx/)
   * Automatic HTTPS cert provisioning: [cert-manager](https://cert-manager.io/)
   * Autoscaling: `metrics-server` and `vertical-pod-autoscaler`
   * Search index: ElasticSearch or OpenSearch
   * Monitoring: TODO
   * Database clusters: TODO (for now we recommend provisioning managed MySQL/MongoDB database clusters from your cloud provider using OpenTofu or a tool like [Grove](https://grove.opencraft.com/).)
   * Where possible, we try to configure these systems to **auto-detect** newly deployed Open edX instances and adapt to them automatically; where that isn't possible, Tutor plugins are used so that the instances self-register or self-provision the shared resources as needed.
3. [Tutor](https://docs.tutor.overhang.io/) is used to build the container images that will be deployed onto the cluster.
   * This project's Tutor plugin is required to make the images compatible with the shared resources deployed by the Helm chart.
   * The
[pod-autoscaling plugin](https://github.com/eduNEXT/tutor-contrib-pod-autoscaling) is required for autoscaling.
   * You can use the `tutor k8s` commands directly (as documented below) or you can use a CI/CD tool like [Grove](https://grove.opencraft.com/) to deploy instances/images.

## FAQ

### Is this ready to use in production?

We are tracking that in [issue 26](https://github.com/openedx/openedx-k8s-harmony/issues/26), so check that issue for the current status.

### This project aims to support many small/medium instances deployed onto a cluster; is it also suitable for deploying one really high traffic instance?

Supporting one really large instance is not a core design goal, but it should work well and we may consider including this as a goal in the future. Please reach out to us or get involved with this project if you have this requirement.

### What are the gotchas related to cert-manager?

This helm chart uses [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) as a load balancer alongside [cert-manager](https://cert-manager.io/) to provide automatic SSL certificates. Because of how Helm works, the cert-manager sub-chart will be installed into the same namespace as the parent harmony chart. But if you already have cert-manager on your cluster, this will create a conflict. You should take special care not to install cert-manager twice due to it installing several non-namespaced resources. If you already installed cert-manager by different means, make sure set `cert-manager.enabled: false` for this chart.

In addition, [the cert-manager Helm charts do not install the required CRDs used by cert-manager](https://cert-manager.io/docs/installation/upgrading/#crds-managed-separately), so you will need to manually install and upgrade them to the correct version as described in the instructions below. This is due to the some limitations in the management of CRDs by Helm.

### How the autoscaling capabilities are implemented in this project?

Tutor does not offer an autoscaling mechanism by default. This is a critical feature when your application starts to
receive more and more traffic. Kubernetes offers two main autoscaling methods:

* **Pod-based scaling**: This mechanism consists of the creation and adjustment of new pods to cover growing workloads.
Here we can mention tools like
[**Horizontal Pod autoscaler (HPA)**](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
and [**Vertical pod autoscaler (VPA)**](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler).
The first consist of automatically increasing or decreasing the number of pods in response to a workload's metric
consumption (generally CPU and memory), and the second one aims to stabilize the consumption and resources of every pod
by providing suggestions on the best configuration for a workload based on historical resource usage measurements. Both
of them are meant to be applied over Kubernetes Deployment instances.

* **Node-based scaling:** This mechanism allows the addition of new NODES to the Kubernetes cluster so compute resources
are guaranteed to schedule new incoming workloads. Tools worth mentioning in this category are
[**cluster-autoscaler (CA)**](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) and
[Karpenter](https://karpenter.sh/).

For the scope of this project, the focus will be in the **pod-based scaling** mechanisms since Node-based scaling tools
require configuration which is external to the cluster and this is out of the scope for this Helm chart for now.

The approach will be to use pod autoscaling on each environment separately (assuming there are installations on different
namespaces) following the steps below:

1. **Install the global dependencies**: this Helm chart offers the option of installing the dependencies required to
get HPA and VPA working (they are included as subcharts). These are the Helm charts for **metrics-server** and **VPA**.
By default these dependencies are not installed, however you can enable them via the Helm chart values if they aren't
still present in your cluster.
2. **Enable the pod-autoscaling plugin per environment**: the
[pod-autoscaling plugin](https://github.com/eduNEXT/tutor-contrib-pod-autoscaling) enables the implementation of HPA and
VPA to start scaling an installation workloads. Variables for the plugin configuration are documented there.

#### Node-autoscaling with Karpenter in EKS Clusters

This section provides a guide on how to install and configure [Karpenter](https://karpenter.sh/) in a EKS cluster. We'll use
infrastructure examples included in this repo for such purposes.

> Prerequisites:

* An aws account id
* Kubectl 1.27
* OpenTofu 1.6.x or higher
* Helm

1. Clone this repository and navigate to `./infra-examples/aws`. You'll find OpenTofu modules for `vpc` and `k8s-cluster`
resources. Proceed creating the `vpc` resources first, followed by the `k8s-cluster` resources. Make sure to have the target
AWS account ID available, and then execute the following commands on every folder:

   ```sh
   tofu init
   tofu plan
   tofu apply -auto-approve
   ```

   It will create an EKS cluster in the new VPC. Required Karpenter resources will also be created.

2. Once the `k8s-cluster` is created, run the `tofu output` command on that module and copy the following output variables:

   * cluster_name
   * karpenter_irsa_role_arn
   * karpenter_instance_profile_name

   These variables will be required in the next steps.

3. Karpenter is a dependency of the harmony chart that can be enabled or disabled. To include Karpenter in the Harmony Chart,
**it is crucial** to configure these variables in your `values.yaml` file:

   * `karpenter.enabled`: true
   * `karpenter.serviceAccount.annotations.eks\.amazonaws\.com/role-arn`: "<`karpenter_irsa_role_arn` value from module>"
   * `karpenter.settings.aws.defaultInstanceProfile`: "<`karpenter_instance_profile_name` value from module>"
   * `karpenter.settings.aws.clusterName`:  "<`cluster_name` value from module>"

   Find below an example of the Karpenter section in the `values.yaml` file:

   ```yaml
   karpenter:
      enabled: true
      serviceAccount:
         annotations:
            eks.amazonaws.com/role-arn: "<karpenter_irsa_role_arn>"
      settings:
         aws:
            # -- Cluster name.
            clusterName: "<cluster_name"
            # -- Cluster endpoint. If not set, will be discovered during startup (EKS only)
            # From version 0.25.0, Karpenter helm chart allows the discovery of the cluster endpoint. More details in
            # https://github.com/aws/karpenter/blob/main/website/content/en/docs/upgrade-guide.md#upgrading-to-v0250
            # clusterEndpoint: "https://XYZ.eks.amazonaws.com"
            # -- The default instance profile name to use when launching nodes
            defaultInstanceProfile: "<karpenter_instance_profile_name>"
   ```

4. Now, install the Harmony Chart in the new EKS cluster using [these instructions](#usage-instructions). This will provide a
very basic Karpenter configuration with one [provisioner](https://karpenter.sh/docs/concepts/provisioners/) and one
[node template](https://karpenter.sh/docs/concepts/node-templates/). Please refer to the official documentation to
get further details.

> **NOTE:**
> This Karpenter installation does not support multiple provisioners or node templates for now.

5. To test Karpenter, you can proceed with the instructions included in the
[official documentation](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/#first-use).

<br><br><br>

## Usage Instructions

### Step 1: Use Helm to provision a kubernetes cluster using this chart

#### Option 1a: Setting up Harmony Chart on a cloud-hosted Kubernetes Cluster (recommended)

For this recommended approach, you need to have a Kubernetes cluster in the cloud **with at least 12GB of usable
memory** (that's enough to test 2 Open edX instances).

1. Make sure you can access the cluster from your machine: run `kubectl cluster-info` and make sure it displays some
   information about the cluster (e.g. two URLs).
2. Copy `values-example.yaml` to a new `values.yaml` file and edit it to put in your email address and customize
   other settings. The email address is required for Lets Encrypt to issue HTTPS certificates. It is not shared
   with anyone else. For a full configuration reference, see the `charts/harmony-chart/values.yaml` file.
3. Install [Helm](https://helm.sh/) if you don't have it already.
4. Add the Harmony Helm repository:

   ```shell
   helm repo add openedx-harmony https://openedx.github.io/openedx-k8s-harmony
   helm repo update
   ```

5. Install the cert-manager CRDs if using cert-manager:

   ```shell
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.crds.yaml --namespace=harmony
   ```

   You can check the version of cert-manager that is going to be installed by the chart by checking the corresponding
   line in the `charts/harmony-chart/Chart.yaml` file.
6. Install the Harmony chart by running:

   ```shell
   helm install harmony --namespace harmony --create-namespace -f values.yaml openedx-harmony/harmony-chart
   ```

Note: in the future, if you apply changes to `values.yaml`, please run this command to update the deployment of the chart:

```shell
helm upgrade harmony --namespace harmony -f values.yaml openedx-harmony/harmony-chart
```

#### Option 1b: Setting up Harmony Chart locally on Minikube

*Note: if possible, it's preferred to use a cloud-hosted cluster instead (see previous section). But if you don't have a
cluster available in the cloud, you can use minikube to try this out locally. The minikube version does not support
HTTPS and is more complicated due to the need to use tunnelling.*

1. First, [install `minikube`](https://minikube.sigs.k8s.io/docs/start/) if you don't have it already.
2. Run `minikube start` (you can also use `minikube dashboard` to access the Kubernetes dashboard).
3. Add the Helm repository and install the Harmony chart using the `values-minikube.yaml` file as configuration:

   ```shell
   helm repo add openedx-harmony https://openedx.github.io/openedx-k8s-harmony
   helm repo update
   helm install harmony --namespace harmony --create-namespace -f values-minikube.yaml openedx-harmony/harmony-chart
   ```

4. Run `minikube tunnel` (you may need to enter a password), and then you should be able to access the cluster (see
   "External IP" below). If this approach is not working, an alternative is to run\
   `minikube service harmony-ingress-nginx-controller -n harmony`\
   and then go to the URL it says, e.g. `http://127.0.0.1:52806` plus `/cluster-echo-test`
   (e.g. `http://127.0.0.1:52806/cluster-echo-test`)
5. In this case, skip step 2 ("Get the external IP") and use `127.0.0.1` as the external IP. You will need to remember
   to include the port numbers shown above when accessing the instances.

### Step 2: Get the external IP

The [ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/) is used to automatically set up an HTTPS
reverse proxy for each Open edX instance as it gets deployed onto the cluster. There is just one load balancer with a
single external IP for all the instances on the cluster. To get its IP, use:

```shell
kubectl get svc -n harmony harmony-ingress-nginx-controller
```

To test that your load balancer is working, go to `http://<the external ip>/cluster-echo-test` .
You may need to ignore the HTTPS warnings, but then you should see a response with some basic JSON output.

### Step 3: Deploying an Open edX instance using Tutor

Important: First, get the load balancer's IP (see "external IP" above), and set the DNS records for the instance you
want to create to be pointing to the load balancer (Usually if you want the LMS at `lms.example.com`, you'll need to set
two A records for `lms.example.com` and `*.lms.example.com`, pointing to the external IP from the load balancer).

You also will need to have the tutor-contrib-harmony-plugin installed into Tutor:

```shell
pip install -e 'git+https://github.com/openedx/openedx-k8s-harmony.git#egg=tutor-contrib-harmony-plugin&subdirectory=tutor-contrib-harmony-plugin'
```

Next, create a Tutor config directory unique to this instance, and configure it:

```shell
export INSTANCE_ID=openedx-01
export TUTOR_ROOT=~/deployments/tutor-k8s/$INSTANCE_ID
tutor plugins enable k8s_harmony
tutor config save -i --set K8S_NAMESPACE=$INSTANCE_ID
```

Then deploy it:

```shell
tutor k8s start
tutor k8s init
```

Note that the `init` command may take quite a long time to complete. Use the commands that Tutor says ("To view the logs
from this job, run:") in a separate terminal in order to monitor the status.

**You can repeat step 3 many times to install multiple instances onto the cluster.**

<br><br><br>

## Configuration Reference

### Multi-tenant Elasticsearch

Tutor creates an Elasticsearch pod as part of the Kubernetes deployment. Depending on the number of instances, memory
and CPU use can be lowered by running a central ES cluster instead of an ES pod for every instance.

**Please note that this will only work for "Redwood" version and later. The OpenSearch implementation is not yet confirmed to work as expected.**

To enable set `elasticsearch.enabled=true` in your `values.yaml` and deploy the chart.

For each instance you would like to enable this on, set the configuration values in the respective `config.yml`:

```yaml
RUN_ELASTICSEARCH: false
K8S_HARMONY_ENABLE_SHARED_SEARCH_CLUSTER: true
K8S_HARMONY_SEARCH_CLUSTER_HTTP_AUTH: instance-name:desired-password
K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX: prefix-
```

If the `K8S_HARMONY_SEARCH_CLUSTER_HTTP_AUTH` or `K8S_HARMONY_SEARCH_CLUSTER_INDEX_PREFIX` is not set, the settings are
populated with random value to ensure uniqueness.

* Create the user on the cluster with `tutor harmony create-elasticsearch-user`.
* Copy the Elasticsearch CA certificate to the instance's namespace where `$INSTANCE_NAMESPACE` is where the instance is installed in. The `$HARMONY_NAMESPACE` should be set to the namespace where the Harmony is installed to.
  ```shell
  kubectl get secret "search-cluster-certificates-elasticsearch" -n "$HARMONY_NAMESPACE" -o "yaml" | \
      grep -v '^\s*namespace:\s' | \
      sed s/-elasticsearch//g |\
      kubectl apply -n "$INSTANCE_NAMESPACE" --force -f -
  ```
* Rebuild your Open edX image `tutor images build openedx`.
* Finally, redeploy your changes: `tutor k8s start && tutor k8s init`.

#### Caveats

In order for SSL to work without warnings the CA certificate needs to be mounted in the relevant pods. This is not yet implemented as due to an [outstanding issue in tutor](https://github.com/overhangio/tutor/issues/791) that had not yet been completed at the time of writing.

## Extended Documentation

### How to uninstall this chart

Just run `helm uninstall --namespace harmony harmony` to uninstall this.

### How to create a cluster for testing on DigitalOcean

If you use DigitalOcean, you can use OpenTofu to quickly spin up a cluster, try this out, then shut it down again.

Here's how. First, put the following into `infra-examples/digitalocean/secrets.auto.tfvars` including a valid DigitalOcean access token:

```conf
cluster_name = "harmony-test"
do_token = "digital-ocean-token"
```

Then run:

```sh
cd infra-examples/digitalocean
tofu init
tofu apply
cd ..
export KUBECONFIG=`pwd`/infra-examples/digitalocean/kubeconfig
```

Then follow steps 1-4 above. When you're done, run `tofu destroy` to clean
up everything.

## Appendix C: how to create a cluster for testing on AWS

Similarly, if you use AWS, you can use OpenTofu to spin up a cluster, try this out, then shut it down again.
Here's how. First, put the following into `infra-examples/aws/vpc/secrets.auto.tfvars` and `infra-examples/aws/k8s-cluster/secrets.auto.tfvars`:

   ```terraform
   account_id  = "012345678912"
   aws_region  = "us-east-1"
   name        = "tutor-multi-test"
   ```

Then run:

   ```bash
   aws sts get-caller-identity   # to verify that awscli is properly configured
   cd infra-examples/aws/vpc
   tofu init
   tofu apply               # run time is approximately 1 minute
   cd ../k8s-cluster
   tofu init
   tofu apply               # run time is approximately 30 minutes

   # to configure kubectl
   aws eks --region us-east-1 update-kubeconfig --name tutor-multi-test --alias tutor-multi-test
   ```

Then follow steps 1-4 above. When you're done, run `tofu destroy` in both the `aws` and `k8s-cluster` modules to clean up everything.
