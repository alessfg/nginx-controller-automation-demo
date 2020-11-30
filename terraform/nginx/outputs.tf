output "public_ip" {
  value = aws_instance.nginx_plus_agent[*].public_ip
}
