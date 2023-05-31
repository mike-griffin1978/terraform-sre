output "IP_ADDRESS" {
   value = aws_instance.web.private_ip
}

output "DNS_NAME" {
   value = aws_instance.web.private_dns
}