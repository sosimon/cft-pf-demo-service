/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  credentials_file_path = "${var.credentials_path}"
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  credentials = "${file(local.credentials_file_path)}"
  version     = "~> 1.19"
}

provider "google-beta" {
  credentials = "${file(local.credentials_file_path)}"
  version     = "~> 1.19"
}

provider "gsuite" {
  credentials             = "${file(local.credentials_file_path)}"
  impersonated_user_email = "${var.admin_email}"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]

  version = "~> 0.1.9"
}

module "project-factory" {
  source             = "terraform-google-modules/project-factory/google"
  version            = "0.3.0"
  random_project_id  = "true"
  name               = "sso-cft-pf-demo-service"
  org_id             = "${var.organization_id}"
  billing_account    = "${var.billing_account}"
  credentials_path   = "${local.credentials_file_path}"
  create_group       = "true"
  group_name         = "${var.project_group_name}"
  group_role         = "roles/editor"
  shared_vpc         = "${var.shared_vpc_project}"
  shared_vpc_subnets = "${var.shared_vpc_subnets}"
}

resource "gsuite_group_member" "group_owner" {
  group = "${module.project-factory.group_email}"
  email = "${var.project_group_owner}"
  role  = "OWNER"
}
