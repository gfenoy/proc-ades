from pprint import pprint
import time
import kubernetes.client
from kubernetes.client.rest import ApiException
from kubernetes import client, config

from workflow_executor import helpers


def run(namespace, workflow_name, state=None):

    debugmode= True
    # create an instance of the API class
    apiclient = helpers.get_api_client()
    api_instance = client.BatchV1Api(api_client=apiclient)
    core_v1 = client.CoreV1Api(api_client=apiclient)


    pretty = True

    print("## JOB STATUS")

    try:
        api_response = api_instance.read_namespaced_job_status(name=workflow_name,namespace= namespace, pretty=pretty)

        if api_response.status.active:
            status = {"status": "Running", "error": ""}
            pprint(status)
            return status
        elif api_response.status.succeeded:
            status = {"status": "Success", "error": ""}
            pprint(status)
            return status
        elif api_response.status.failed:
            if debugmode:

                controllerUid = api_response.metadata.labels["controller-uid"]
                pod_label_selector = "controller-uid=" + controllerUid
                pods_list = core_v1.list_namespaced_pod(namespace=namespace, label_selector=pod_label_selector, timeout_seconds=10)
                pod_name = pods_list.items[0].metadata.name
                try:
                    # For whatever reason the response returns only the first few characters unless
                    # the call is for `_return_http_data_only=True, _preload_content=False`
                    pod_log_response = core_v1.read_namespaced_pod_log(name=pod_name, namespace=namespace, _return_http_data_only=True, _preload_content=False)
                    pod_log = pod_log_response.data.decode("utf-8")
                    status = {"status": "Failed", "error": pod_log }
                except client.rest.ApiException as e:
                    status = {"status": "Failed", "error": api_response.status.conditions[0].message}

            else:    
                status = {"status": "Failed", "error": api_response.status.conditions[0].message}
            pprint(status)
            return status

    except ApiException as e:
        print("Exception when calling get status: %s\n" % e)
        raise e

