resource "google_storage_bucket_object" "cloud-function-archive" {
  name   = "index.zip"
  bucket = "terraform-tutorial"
  source = "./index.zip"
}
resource "google_cloudfunctions_function" "function" {
  name        = "terraform-tutorial"
  description = "Hello World example"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = "terraform-tutorial"
  source_archive_object = google_storage_bucket_object.cloud-function-archive.name
  trigger_http          = true
  entry_point           = "helloWorld"
  environment_variables = {
    name = "terraform"
  }
}
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:terraform@terraform-tutorial-324710.iam.gserviceaccount.com"
}

resource "google_cloud_scheduler_job" "hellow-world-job" {
  name             = "terraform-tutorial"
  description      = "Hello World every 2 minutes"
  schedule         = "*/2 * * * *"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.function.https_trigger_url
    oidc_token {
      service_account_email = "terraform@terraform-tutorial-324710.iam.gserviceaccount.com"
    }
  }
}