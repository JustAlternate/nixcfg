terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
  backend "s3" {
    bucket = "justalternate-multi-project-tfstate-bucket"
    key    = "keycloak.tfstate"
    region = "eu-west-3"
  }
}

provider "keycloak" {
  client_id = var.keycloak_admin_client_id
  username  = var.keycloak_admin_username
  password  = var.keycloak_admin_password
  url       = "https://auth.justalternate.com"
}

resource "keycloak_realm" "sso" {
  realm                       = "sso"
  enabled                     = true
  default_signature_algorithm = "RS256"
}

# --- SSO Realm GitHub IDP ---
resource "keycloak_oidc_identity_provider" "github_sso" {
  realm                                   = keycloak_realm.sso.realm
  alias                                   = "github"
  provider_id                             = "github"
  client_id                               = var.github_sso_client_id
  client_secret                           = var.github_sso_client_secret
  authorization_url                       = "https://github.com/login/oauth/authorize"
  token_url                               = "https://github.com/login/oauth/access_token"
  backchannel_supported                   = false
  trust_email                             = false
  store_token                             = false
  sync_mode                               = "IMPORT"
  first_broker_login_flow_alias           = keycloak_authentication_flow.no_signup_social_sso.alias
  default_scopes                          = ""
  accepts_prompt_none_forward_from_client = false
}

resource "keycloak_openid_client" "open_webui" {
  realm_id              = keycloak_realm.sso.id
  client_id             = var.open_webui_client_id
  name                  = "open-webui"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  client_secret         = var.open_webui_client_secret
  standard_flow_enabled = true
  valid_redirect_uris   = ["https://ai.justalternate.com/oauth/oidc/callback"]
  web_origins           = ["https://ai.justalternate.com"]
}

resource "keycloak_openid_client" "opencloud" {
  realm_id    = keycloak_realm.sso.id
  client_id   = var.opencloud_client_id
  name        = "opencloud"
  enabled     = true
  access_type = "CONFIDENTIAL"
  # client_secret         = var.open_webui_client_secret
  standard_flow_enabled = true
  valid_redirect_uris   = ["https://cloud.justalternate.com/oauth/oidc/callback"]
  web_origins           = ["https://cloud.justalternate.com"]
}

resource "keycloak_openid_client" "grafana" {
  realm_id              = keycloak_realm.sso.id
  client_id             = var.grafana_client_id
  name                  = "grafana"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  client_secret         = var.grafana_client_secret
  standard_flow_enabled = true
  valid_redirect_uris   = ["https://monitoring.justalternate.com/login/generic_oauth"]
  web_origins           = ["https://monitoring.justalternate.com"]
}

# --- Master Realm GitHub IDP ---
resource "keycloak_oidc_identity_provider" "github_master" {
  realm                                   = "master"
  alias                                   = "github"
  provider_id                             = "oidc"
  client_id                               = var.github_master_client_id
  client_secret                           = var.github_master_client_secret
  authorization_url                       = "https://github.com/login/oauth/authorize"
  token_url                               = "https://github.com/login/oauth/access_token"
  backchannel_supported                   = false
  trust_email                             = false
  store_token                             = false
  sync_mode                               = "IMPORT"
  first_broker_login_flow_alias           = keycloak_authentication_flow.no_signup_social_master.alias
  default_scopes                          = ""
  accepts_prompt_none_forward_from_client = false
}

resource "keycloak_authentication_flow" "no_signup_social_master" {
  realm_id = "master"
  alias    = "No-Signup-Social"
}

resource "keycloak_authentication_flow" "no_signup_social_sso" {
  realm_id = "sso"
  alias    = "No-Signup-Social"
}

# Variables
variable "keycloak_admin_client_id" {
  description = "Keycloak admin client ID"
  type        = string
  sensitive   = true
}

variable "keycloak_admin_username" {
  description = "Keycloak admin username"
  type        = string
  sensitive   = true
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "github_sso_client_id" {
  description = "GitHub client ID for SSO realm"
  type        = string
  sensitive   = true
}

variable "github_sso_client_secret" {
  description = "GitHub client secret for SSO realm"
  type        = string
  sensitive   = true
}

variable "open_webui_client_id" {
  description = "Client ID for open-webui"
  type        = string
}

variable "opencloud_client_id" {
  description = "Client ID for opencloud"
  type        = string
}

variable "open_webui_client_secret" {
  description = "Client secret for open-webui"
  type        = string
  sensitive   = true
}

variable "grafana_client_id" {
  description = "Client ID for Grafana"
  type        = string
}

variable "grafana_client_secret" {
  description = "Client secret for Grafana"
  type        = string
  sensitive   = true
}

variable "github_master_client_id" {
  description = "GitHub client ID for master realm"
  type        = string
  sensitive   = true
}

variable "github_master_client_secret" {
  description = "GitHub client secret for master realm"
  type        = string
  sensitive   = true
}
