output "vpc_id" {
    description = "ID de la VPC"
    value       = aws_vpc.main.id
}

output "public_subnets" {
    description = "Subredes publicas"
    value       = aws_subnet.public.*.id
}

output "private_subnets" {
    description = "Subredes privadas"
    value       = aws_subnet.private.*.id
}

output "security_group_database" {
    description = "Grupo de Seguridad de la base de datos"
    value       = aws_security_group.database.id
}

output "security_group_instances" {
    description = "Grupo de Seguridad de las instancias"
    value       = aws_security_group.instances.id
}

output "security_group_load_balancer" {
    description = "Grupo de Seguridad del balanceador de carga"
    value       = aws_security_group.load_balancer.id
}

output "db_subnet_group" {
    description = "Grupo de subredes de la base de datos"
    value       = aws_db_subnet_group.main.name
}