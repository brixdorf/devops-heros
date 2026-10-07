# Kubernetes Volumes

Tried each storage option on Minikube with the docker driver, where "the node" is the `minikube` container.

## emptyDir

An empty folder created with the Pod and shared by its containers. It is deleted with the Pod, so after I deleted and recreated the Pod the old lines were gone.

```bash
kubectl apply -f emptydir-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-demo --timeout=120s
sleep 15
kubectl get pod emptydir-demo          # READY should be 2/2
kubectl logs emptydir-demo -c reader   # lines written by the other container
kubectl exec emptydir-demo -c reader -- cat /shared/log.txt
```

The reader container shows the lines the writer container wrote, so both share the folder.

![](../image1.png)

```bash
kubectl delete pod emptydir-demo
kubectl apply -f emptydir-pod.yaml
kubectl wait --for=condition=Ready pod/emptydir-demo --timeout=120s
kubectl exec emptydir-demo -c reader -- cat /shared/log.txt
```

## hostPath

Mounts a folder from the node into the Pod, so the data stays on that node after the Pod is deleted. It is a security risk and ties data to one node, so it is only for local testing.

```bash
kubectl apply -f hostpath-pod.yaml
kubectl wait --for=condition=Ready pod/hostpath-demo --timeout=120s
kubectl exec hostpath-demo -- cat /data/hello.txt
kubectl delete pod hostpath-demo
kubectl apply -f hostpath-pod.yaml
kubectl wait --for=condition=Ready pod/hostpath-demo --timeout=120s
kubectl exec hostpath-demo -- cat /data/hello.txt
minikube ssh -- cat /data/hostpath-demo/hello.txt
```

After recreating the Pod the file had two lines, and `minikube ssh` showed the same file on the node.

![](../image2.png)

## PersistentVolume (PV)

A piece of storage registered in the cluster on its own, with a size, access mode and reclaim policy. Mine showed `Available` until a claim bound it.

```bash
kubectl apply -f pv.yaml
kubectl get pv
kubectl describe pv pv-demo
```

## PersistentVolumeClaim (PVC)

A request for storage. Kubernetes binds it to a matching PV, and the Pod only names the claim.

```bash
kubectl apply -f pvc.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/pvc-demo --timeout=60s
kubectl get pv,pvc
```

The PV and the PVC are `Bound` to each other.

![](../image3.png)

```bash
kubectl apply -f pvc-pod.yaml
kubectl wait --for=condition=Ready pod/pvc-pod --timeout=180s
kubectl exec pvc-pod -- sh -c 'echo "<h1>Hello from a PersistentVolume</h1>" > /usr/share/nginx/html/index.html'
kubectl port-forward pod/pvc-pod 8080:80     # leave running, use a second terminal
curl http://localhost:8080
```

```bash
kubectl delete pod pvc-pod
kubectl apply -f pvc-pod.yaml
kubectl wait --for=condition=Ready pod/pvc-pod --timeout=120s
kubectl exec pvc-pod -- cat /usr/share/nginx/html/index.html
```

The page written before the Pod was deleted was still there in the new Pod.

![](../image4.png)

## StorageClass

Describes a type of storage and names a provisioner that creates PVs automatically. Minikube ships with `standard`, which uses `k8s.io/minikube-hostpath`.

```bash
kubectl get storageclass
kubectl describe storageclass standard
```

`standard` is the default class, with reclaim policy `Delete`.

![](../image5.png)

## Dynamic provisioning

I only wrote the PVC, and the provisioner created a matching PV for it.

```bash
kubectl apply -f dynamic-pvc.yaml
kubectl wait --for=condition=Ready pod/dynamic-pod --timeout=120s
kubectl get pvc dynamic-pvc
kubectl get pv
kubectl exec dynamic-pod -- cat /data/note.txt
minikube ssh -- ls /tmp/hostpath-provisioner/default/dynamic-pvc
```

The PVC is bound to a generated PV, and `note.txt` is stored on the node.

![](../image6.png)

## Quick comparison

emptyDir dies with the Pod, hostPath stays on one node, PV plus PVC survive Pod deletion, and a StorageClass creates the PV for you.

## Cleanup

```bash
kubectl delete -f .
minikube ssh -- sudo rm -rf /data/hostpath-demo /data/pv-demo
```
