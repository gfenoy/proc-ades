# HELM Chart for Application, Deployment Execution Service

## Prerequisites

* This chart requires Docker Engine 1.8+ in any of their supported platforms.  Please see vendor requirements [here for more information](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker).
* At least 2GB of RAM. Make sure to assign enough memory to the Docker VM if you're running on Docker for Mac or Windows.

## Chart Components

* Creates an ADES deployment
* Creates a Kubernetes Service on specified port (default: 80)
* Creates a processing-manager ades service account with an advanced role allowing to create namespaces and related resources

## Important note about processing manager

The ADES provision a new namespace for each processing job submitted. To do so, it uses a specific service account created during the deployment. This service account will have admin privileges. The service account creates is called `<release-name>-processing-manager`.

## Installing the Chart

You can install the chart with the release name `ades` in `eoepca` namespace as below.

```console
$ helm install ades charts/ades --namespace eoepca
...
```

> Note - If you do not specify a name, helm will select a name for you.

### Stage-in/Out with Stars

By default, CWL values for stage-in and stage-out are not set. Therefore, the default stage-in and stage-out from [`cwl-wrapper`](https://github.com/EOEPCA/cwl-wrapper) project are used. It is strongly recommended to install the default stage-in and stage-out contained in this repository.
This can be done installing or upgrading the chart with

```console
helm upgrade --install ades charts/ades/ --namespace eoepca --set-file workflowExecutor.stagein.cwl=charts/ades/files/cwl/stagein/terradue_stars_t2_latest.cwl  --set-file workflowExecutor.stageout.cwl=charts/ades/files/cwl/stageout/terradue_stars_latest.cwl
```

Those stage-in and stage-out includes the [Stars](https://github.com/Terradue/Stars) CLI that are able to read the EOEPCA catalog reference and provision with the assets referenced. In stage-in, data are also harvested to create a [STAC](https://github.com/radiantearth/stac-spec) catalog describing the assets staged.

### Installed Components

You can use `kubectl get` to view all of the installed components.

```console
$ kubectl get all -l app.kubernetes.io/instance=ades -n eoepca
NAME                            READY     STATUS    RESTARTS   AGE
pod/ades-66fc8f5566-w7456   2/2       Running   0          6d

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/ades   ClusterIP   172.30.89.159   <none>        80/TCP    8d

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ades   1         1         1            1           8d

NAME                                  DESIRED   CURRENT   READY     AGE
replicaset.apps/ades-6669bcbc5d   0         0         0         8d
replicaset.apps/ades-66fc8f5566   1         1         1         7d

NAME                                      HOST/PORT               PATH      SERVICES   PORT      TERMINATION     WILDCARD
route.route.openshift.io/ades-5w2ww   ades.eoepca.com   /         ades      http      edge/Redirect   None
```

## Connecting to the ADES

1. Run the following command to get the openAPI document

```console
$ curl -H 'Accept: application/json' https://ades-cpe.terradue.com/terradue/wps3/api
```

## Values

The configuration parameters in this section control the resources requested and utilized by the ADES instance.

| Parameter                               | Description                                                                                    | Default                          |
| --------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------------------------- |
|image.repository | Docker image repository | `eoepca/proc-ades` |
|image.pullPolicy | Determines if the image should be pulled prior to starting the container. Three possible values: Always, IfNotPresent, Never' | `Always` |
|image.tag | Docker image tag | `0.9.7` |
| clusterAdminRoleName                    | Name of the role binding for the ades service account that provision resources for processing  | `cluster-admin`                              |
|nodeSelector | Constrain on which nodes the Ades is eligible to run based on the node label | `{}` | 
| useKubeProxy                            | If the ADES interacts with the kubernetes cluster via proxy or not. If false, workflowExecutor.kubeconfig file location must be provided | `true`                        |
| workflowExecutor.kubeconfig             | kube config file to be used by the ADES to connect to th cluster where to provision resource for the processing. | `files/kubeconfig` |
| workflowExecutor.inputs            | Key/Value Dictionary of input values to be passed to all nodes of the application workflow. They will be prefixed with 'ADES_'. e.g. 'APP: ades' will be 'ADES_APP: ades' | `[Empty dictionary]`        |
| workflowExecutor.processingStorageClass | kubernetes storage class to be used for provisioning volumes for processing. Must be ReadWriteMany compliant  | `longhorn`                       |
| workflowExecutor.processingVolumeTmpSize | Size of the volumes for processing result of one workflow nodeouput                                                       | `5Gi`  
| workflowExecutor.processingVolumeOutputSize | Size of the volumes for processing result for the whole workflow ouput                                                       | `10Gi`                   |
| workflowExecutor.processingMaxRam       | Total maximum RAM pool available for all pods running concurrently                             | `16Gi`                  |
| workflowExecutor.processingMaxCores       | Total maximum CPU cores pool available for all pods running concurrently                             | `8`                  |
| workflowExecutor.processingKeepWorkspace | Name of the secret to use to pull docker images  | `false`                          |
| workflowExecutor.processingNodeSelector  | Constrain on which nodes the processing pods are eligible to run based on the node label  | `nodeSelector`                          |
| workflowExecutor.main.cwl             | Main CWL workflow file path used by [`cwl-wrapper`](https://github.com/EOEPCA/cwl-wrapper)                                                          | `empty` |
| workflowExecutor.stagein.cwl             | Stage-in CWL workflow file path                                                                 | `charts/ades/files/cwl/stagein/terradue_stars_t2_latest.cwl`                            |
| workflowExecutor.stageout.cwl             | Stage-out CWL workflow file path                                                                 | `charts/ades/files/cwl/stageout/terradue_stars_latest.cwl`                            |
| workflowExecutor.rulez.cwl  | Data structure for defining the CWL parameter used by [`cwl-wrapper`](https://github.com/EOEPCA/cwl-wrapper) | `empty`  |
| workflowExecutor.imagePullSecrets       | ImagePullSecrets is an optional list of references to secrets for the processing namespace to use for pulling any of the images used by the processing pods. If specified, these secrets will be passed to individual puller implementations for them to use. For example, in the case of docker, only DockerConfig type secrets are honored. More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod                                                                                     | `[]`                            |
|workflowExecutor.pod.env | Environmental variables for the processing pods | `{}` |
|workflowExecutor.pod.nodeSelector | Node selectors for the processing pods | `{}` |
|workflowExecutor.userResourceManager | Enables resource manager | `false` |
|workflowExecutor.resourceManagerEndpoint | Resource manager endpoint |`"https://resourcemanager-api.com"`|
|workflowExecutor.resourceManagerWorkspacePrefix | Resource manager workspace prefix |`rm-user`|
|workflowExecutor.jobNamespaceLabels.app | Adds a label to the job namespace | `"ades-app"`|
|workflowExecutor.backofflimit| Number of retries before considering a Job as failed | `Commented Out` |
| wps.maincfgtpl                          | Main config file template for WPS interface                                                         | `files/main.cfg.tpl`                            |
| wps.usePep                              | Use the policy Enforcement Point for registering resources                                                              | `false`                            |
| wps.pepBaseUrl                          | Policy Enforcement Point Base Url                                                              | `https://pep.eoepca.terradue.com`                            |
| persistence.enabled                     | Persist the user and processing Data of the ADES                                               | `true`                           |
| persistence.existingUserDataClaim       | Identify an existing Claim to be used for the User Data Directory                              | `Commented Out`                  |
| persistence.existingProcServicesClaim   | Identify an existing Claim to be used for the Processing data directory                        | `Commented Out`                  |
| persistence.storageClass                | Storage Class to be used                                                                       | `standard`                  |
| persistence.userDataAccessMode          | Data Access Mode to be used for the user data Directory                                        | `ReadWriteOnce`                  |
| persistence.userDataSize                | PVC Size for user data Directory                                                               | `10Gi`                            |
| persistence.procServicesAccessMode      | Data Access Mode to be used for the processing data Directory                                  | `ReadWriteOnce`                  |
| persistence.procServicesSize            | PVC Size for user data Directory                                                               | `5Gi`                            |
| tolerations                             | List of node taints to tolerate                                                                | `[]`                             |
| affinity                                | Map of node/pod affinities                                                                     | `{}`                             |
| podSecurityContext                      | SecurityContext to apply to the pod                                                            | `{}`|
|ades-longhorn.enabled | Installs ades-longhorn subchart | `true` |
|ades-longhorn.persistence.defaultClassReplicaCount | Number of replicas when creating the volume from Longhorn | `1`|


## Liveness and Readiness

The ADES instance has liveness and readiness checks specified.

## Resources

You can specify the resource limits for this chart in the values.yaml file.  Make sure you comment out or remove the curly brackets from the values.yaml file before specifying resource limits.
Example:

```yaml
resources:
  limits:
    cpu: 2
    memory: 4Gi
  requests:
    cpu: 1
    memory: 2Gi
```

## Persistence Examples

Persistence in this chart can be enabled by specifying `persistence.enabled=true`.  The path to the user and processing data can be customized to fit different requirements.

* Example 1 - Enable persistence in values.yaml without specifying claim
> Note - This is useful for local development in a minikube environment

```yaml
persistence:
  enabled: true
  # existingUserDataClaim:
  # existingProcServicesClaim:
  # storageClass: "-"
  userDataAccessMode: ReadWriteOnce
  userDataSize: 5Gi
  procServicesAccessMode: ReadWriteOnce
  procServicesSize: 2Gi
```

* Example 2 - Enable persistence in values.yaml with existing claim
> Note - This is useful for production based environments for persistence volumes and claims already exist.

```yaml
persistence:
  enabled: true
  existingUserDataClaim: pvc-ades-userdata
  existingProcServicesClaim: pvc-ades-processingdata
  # storageClass: "-"
  # userDataAccessMode: ReadWriteOnce
  # userDataSize: 1Gi
  # procServicesAccessMode: ReadWriteOnce
  # procServicesSize: 1Gi
```
