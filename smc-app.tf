terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.5.0"
    }
  } 
}

resource "kubernetes_deployment" "django_app" {
  metadata {
    name = "django-app"
    labels = {
      app = "django"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "django"
      }
    }

    template {
      metadata {
        labels = {
          app = "django"
        }
      }

      spec {
        container {
          name  = "django"
          image = "your-django-app-image:latest"

          port {
            container_port = 8000
          }

          env {
            name  = "DJANGO_SETTINGS_MODULE"
            value = "your_project.settings"
          }

          env {
            name  = "DATABASE_URL"
            value = "your_database_url"
          }
        }
      }
    }
  }
}