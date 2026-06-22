output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "task_definition_name" {
  value = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  value = aws_ecs_task_definition.this.revision
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

# output "efs_id" {
#   value = aws_efs_file_system.this.id
# }

# output "mount_ips" {
#   value = [for mt in aws_efs_mount_target.this : mt.ip_address]
#   description = "List of mount target IP addresses"
# }
