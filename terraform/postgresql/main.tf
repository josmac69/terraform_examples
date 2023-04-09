terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.19.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "/root/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_deployment" "postgresql" {
  metadata {
    name = "postgresql"
    labels = {
      app = "postgresql"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "postgresql"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          app = "postgresql"
        }
      }

      spec {
        container {
          name  = "postgresql"
          image = "postgres:latest"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }

          volume_mount {
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgresql-data"

          persistent_volume_claim {
            claim_name = "postgresql-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgresql" {
  metadata {
    name = "postgresql"
  }

  spec {
    selector = {
      app = "postgresql"
    }

    port {
      name       = "postgresql"
      port       = 5432
      target_port = 5432
    }

    type = "NodePort"
  }
}
