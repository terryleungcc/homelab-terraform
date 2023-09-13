resource "helm_release" "main" {
  name       = "csi-driver-nfs"
  namespace  = "kube-system"
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  version    = "4.4.0"

  set {
    name  = "kubeletDir"
    value = var.kubelet_dir
  }
}

resource "kubernetes_storage_class" "main" {
  metadata {
    name = "storage-class-nfs"
  }

  storage_provisioner = "nfs.csi.k8s.io"

  parameters = {
    server = "192.168.1.4"
    share  = "/volume"
  }

  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"

  mount_options = ["nfsvers=4.1"]

  depends_on = [
    helm_release.main
  ]
}

