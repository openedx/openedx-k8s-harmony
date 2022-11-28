# Tutor Multi Chart

This repository contains a Helm Chart and [Tutor](https://docs.tutor.overhang.io/) plugin that you can use to install
the necessary components onto a Kubernetes cluster so that the cluster can be used to host multiple instances of Open
edX, where each instance is provisioned and managed by Tutor.

## Central Load Balancing

The problem: Tutor uses Caddy, which requires a central configuration file listing all the hostnames to route HTTP(S)
traffic to. Deploying a separate Caddy load balancer per Open edX instance also deploys a corresponding network load
balancers at the Cloud Provider, which can become expensive and are an inefficient use of resources.

Instead, we want to use this Helm chart to deploy a single load balancer onto the cluster along with other shared
resources. The load balancer should **auto-detect** any Open edX instances that get deployed onto the cluster, without
a central configuration file.

Currently, this is a proof of concept, so it uses [Traefik](https://traefik.io/traefik/) as a load balancer (Traefik is
the one that the author is most experienced with). Traefik is excellent _but_ does not support a high availability setup
when it's also managing HTTPS certs, so a future version of this chart could offload cert management onto a separate
service or use another ingress controller like nginx+cert-manager. (Note that the author tried using the Caddy Ingress
Controller but it was too immature and buggy.)

## Central Database/Monitoring/etc

In the future, this chart could also be made to install monitoring, databases, ElasticSearch, or other shared resources
that can be shared by all the instances in the cluster, following all the best practices. For now it's just a proof of
concept that focuses on load balancing and integration with the existing Tutor plugins/ecosystem.

Alternately, many of those shared databases can be provisioned outside of the cluster using Terraform, and configured to
work with the instances that Tutor deploys. That approach is outside the scope of this Helm chart but see
[Grove](https://grove.opencraft.com/) for an open source implementation.


<br><br><br>


How to use:

## Step 1: Use Helm to provision a kubernetes cluster using this chart

### Option 1a: Setting up Tutor Multi Chart on a cloud-hosted Kubernetes Cluster (recommended)

For this recommended approach, you need to have a Kubernetes cluster in the cloud **with at least 12GB of usable
memory** (that's enough to test 2 Open edX instances).

1. Make sure you can access the cluster from your machine: run `kubectl cluster-info` and make sure it displays some
   information about the cluster (e.g. two URLs).
2. Copy `values-example.yaml` to `values.yaml` and edit it to put in your email address and customize other settings.
   The email address is required for Lets Encrypt to issue HTTPS certificates. It is not shared with anyone else.
3. Install [Helm](https://helm.sh/) if you don't have it already.
4. Run:
   ```
   helm install --namespace tutor-multi --create-namespace -f values.yaml tutor-multi ./tutor-multi-chart
   ```

Note: in the future, if you make any changes to `values.yaml`, then run this command to update the deployment:

```
helm upgrade --namespace tutor-multi -f values.yaml tutor-multi ./tutor-multi-chart
```

### Option 1b: Setting up Tutor Multi Chart locally on Minikube

*Note: if possible, it's preferred to use a cloud-hosted cluster instead (see previous section). But if you don't have a
cluster available in the cloud, you can use minikube to try this out locally. The minikube version does not support
HTTPS and is more complicated due to the need to use tunnelling.*

1. First, [install `minikube`](https://minikube.sigs.k8s.io/docs/start/) if you don't have it already.
2. Run `minikube start` (you can also use `minikube dashboard` to access the Kubernetes dashboard).
3. Run\
   `helm install --namespace tutor-multi --create-namespace -f values-minikube.yaml tutor-multi ./tutor-multi-chart`
4. Run `minikube tunnel` (you may need to enter a password), and then you should be able to access the cluster (see
   "External IP" below). If this approach is not working, an alternative is to run\
   `minikube service tutor-multi-traefik -n tutor-multi`\
   and then go to the URL it says, e.g. `http://127.0.0.1:52806` plus `/cluster-echo-test`
   (e.g. `http://127.0.0.1:52806/cluster-echo-test`)
5. In this case, skip step 2 ("Get the external IP") and use `127.0.0.1` as the external IP. You will need to remember
   to include the port numbers shown above when accessing the instances.


## Step 2: Get the external IP

A [Traefik](https://doc.traefik.io/traefik/)
[Ingress Controller](https://doc.traefik.io/traefik/providers/kubernetes-ingress/) is used to automatically set up an
HTTPS reverse proxy for each Open edX instance as it gets deployed onto the cluster. There is just one load balancer
with a single external IP for all the instances on the cluster. To get its IP, use:

```
kubectl get svc -n tutor-multi tutor-multi-traefik
```

To test that your load balancer is working, go to `http://<the external ip>/cluster-echo-test` .
You may need to ignore the HTTPS warnings, but then you should see a response with some basic JSON output.

## Step 3: Deploying an Open edX instance using Tutor

Important: First, get the load balancer's IP (see "external IP" above), and set the DNS records for the instance you
want to create to be pointing to the load balancer (Usually if you want the LMS at `lms.example.com`, you'll need to set
two A records for `lms.example.com` and `*.lms.example.com`, pointing to the external IP from the load balancer).

You also will need to have the tutor-contrib-multi-plugin installed into Tutor:

```
pip install -e 'git+https://github.com/open-craft/tutor-contrib-multi.git#egg=tutor-contrib-multi-plugin&subdirectory=tutor-contrib-multi-plugin'
```

Next, create a Tutor config directory unique to this instance, and configure it:

```
export INSTANCE_ID=openedx-01
export TUTOR_ROOT=~/deployments/tutor-k8s/$INSTANCE_ID
tutor plugins enable multi_k8s
tutor config save -i --set K8S_NAMESPACE=$INSTANCE_ID
```

Then deploy it:

```
tutor k8s start
tutor k8s init
```

Note that the `init` command may take quite a long time to complete. Use the commands that Tutor says ("To view the logs
from this job, run:") in a separate terminal in order to monitor the status. Also note that if you want to use the MFEs,
[you'll need a custom image](https://github.com/overhangio/tutor-mfe/#running-mfes-on-kubernetes) and it won't work out
of the box.

**You can repeat step 3 many times to install multiple instances onto the cluster.**


<br><br><br><br>

----------------

## Appendix A: how to uninstall this chart

Just run `helm uninstall --namespace tutor-multi tutor-multi` to uninstall this.

## Appendix B: how to create a cluster for testing on DigitalOcean

If you use DigitalOcean, you can use Terraform to quickly spin up a cluster, try this out, then shut it down again.
Here's how. First, put the following into `infra-tests/secrets.auto.tfvars` including a valid DigitalOcean access token:
```
cluster_name = "tutor-multi-test"
do_token = "digital-ocean-token"
```
Then run:
```
cd infra-example
terraform init
terraform apply
cd ..
export KUBECONFIG=`pwd`/infra-example/kubeconfig
```
Then follow steps 1-4 above. When you're done, run `terraform destroy` to clean
up everything.
