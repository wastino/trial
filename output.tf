output "ionoscloud_ipblock"{
  value       = [ ionoscloud_ipblock.IonosPoc_IP.ips ]
  description = "The IP addresses of the main server instance."
}