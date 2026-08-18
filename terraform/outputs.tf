output "public_ips" {
  value = {
    for k, instance in aws_instance.web : k => instance.public_ip
  }
  description = "Public IP addresses for Ansible inventory composition"
}

output "private_ips" {
  value = {
    for k, instance in aws_instance.web : k => instance.private_ip
  }
  description = "Private IP addresses for backend interconnection test checks"
}
