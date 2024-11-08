terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.5.0"
    }
  } 
}

provider "google" {
  project = "your-project-id"
  region  = "your-region"
}

resource "google_cloud_run_service" "job1" {
  name     = "job1"
  location = "your-region"

  template {
    spec {
      containers {
        image = "gcr.io/your-project-id/job1-image"
      }
    }
  }
}

resource "google_cloud_run_service" "job2" {
  name     = "job2"
  location = "your-region"

  template {
    spec {
      containers {
        image = "gcr.io/your-project-id/job2-image"
      }
    }
  }
}