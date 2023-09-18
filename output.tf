output "ionoscloud_ipblock"{
  value       = [ ionoscloud_ipblock.Ionos_IP.ips ]
  description = "The IP addresses of the main server instance."
}