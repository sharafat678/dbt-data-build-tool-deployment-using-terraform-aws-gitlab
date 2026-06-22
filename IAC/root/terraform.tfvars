env = "dev-dbt-s3"
aws_region           = "cn-northwest-1"
ecr_repository_name  = "dbt-repo"  #this is dafualt value but we can pss the value form gitlab
iam_role_name        = "ecs-task-execution-role"   #role for ecs task execution
ecs_cluster_name     = "dbt-cluster"   #cluster-name
ecs_family_name      = "dbt-task"    #task-definition name
cpu                  = "1024"
memory               = "2048"
ecs_container_name   = "dbt-container"  #container-name...
s3_bucket_name       = "dbt-bucket"  #"dbt-bucket"   #this is dafualt value but we can pss the value form gitlab
s3_bucket2_name      = "sharedproject"   # this is the name of second bucket which contains the dbt-projects
my_secret_name          = "snowflake/credentials31"

#########Airflow variables###
environment_name                 = "dbt-mwaa-environment"
airflow_version                  = "2.10.1"
dag_s3_path                      = "dags/"
#subnet_ids                       = ["subnet-055e42c6aabfa2e50", "subnet-0952da7674096d12b"]
max_workers                      = 5
min_workers                      = 1
webserver_access_mode            = "PUBLIC_ONLY"
enable_dag_processing_logs       = true
dag_processing_log_level         = "INFO"
enable_scheduler_logs            = true
scheduler_log_level              = "INFO"
enable_task_logs                 = true
task_log_level                   = "INFO"
enable_webserver_logs            = true
webserver_log_level              = "INFO"
enable_worker_logs               = true
worker_log_level                 = "INFO"
weekly_maintenance_window_start  = "SUN:03:00"  #This means AWS can perform maintenance every Sun at 03:00 UTC...................
tags                             = {
  "Environment" = "dev"
  "Project"     = "MWAA"
}
log_retention_in_days = 14
security_group_name = "dbt-mwaa-environment-sg"

##########SNS values.........
topicname = "dbt-sns-topic"
protocolname = "email"
endpointname = ["sharafat.hussain@scania.com.cn"]
