output "url_microservicio" {
  value = "http://${aws_instance.comportamiento.public_ip}:8000/comportamiento?city=Lima&date=2025-09-23"
}

output "ip_publica" {
  value = aws_instance.comportamiento.public_ip
}

output "conectar_por_ssh" {
  value = "ssh -i aldana.pem debian@${aws_instance.comportamiento.public_ip}"
}
