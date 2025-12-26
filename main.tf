terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53"
    }
  }
}

# Configuration explicite du provider OpenStack pour OVH (évite les bugs d'auth)
provider "openstack" {
  auth_url            = "https://auth.cloud.ovh.net/v3"
  user_name           = "user-JXWJQafDbbxx"                  # ← Ton username OpenStack exact
  password            = "mdNcKNmppmjjNmw6vcvDTeqzvdtTkW4J"  # ← Ton mot de passe OpenStack
  tenant_id           = "7b7a3150286046328920a88159650ed4"  # ← Ton OS_TENANT_ID
  user_domain_name    = "Default"
  domain_name         = "Default"
  region              = "BHS5"
}

# Import de ta clé SSH publique
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "terraform-key"
  public_key = file("C:/Users/DELL LATITUDE/.ssh/ovh_key.pub")  # ← Adapte si nom différent (ex: id_ed25519.pub)
}

# Création de l'instance Ubuntu
resource "openstack_compute_instance_v2" "test_instance" {
  name            = "terraform-test-instance"
  region          = "BHS5"
  image_name      = "Ubuntu 24.04"
  flavor_name     = "b3-8"           # Petite instance (1 vCPU, 2 GB RAM)
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = ["default"]

  network {
    name = "Ext-Net"                 # Donne automatiquement une IP publique
  }
}

# Affiche l'IP publique une fois l'instance créée
output "instance_ip" {
  value       = openstack_compute_instance_v2.test_instance.access_ip_v4
  description = "Adresse IP publique de l'instance"
}