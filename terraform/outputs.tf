# test
output test {
  value = "testoutput"
}

# GCP
output gcp_bigip01_mgmt {
  value = module.gcp.f5vm01_mgmt_public_ip
}
output gcp_bigip02_mgmt {
  value = module.gcp.f5vm02_mgmt_public_ip
}
output gcp_bigip01_app {
  value = module.gcp.f5vm01_app_public_ip
}
output gcp_bigip02_app {
  value = module.gcp.f5vm02_app_public_ip
}
# vmware

# azure

# aws
