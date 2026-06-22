resource "aws_cloudwatch_log_group" "dag_processing" {
  name              = "airflow-${var.environment_name}-${var.env}-DAGProcessing"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "scheduler" {
  name              = "airflow-${var.environment_name}-${var.env}-Scheduler"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "task" {
  name              = "airflow-${var.environment_name}-${var.env}-Task"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "webserver" {
  name              = "airflow-${var.environment_name}-${var.env}-WebServer"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "airflow-${var.environment_name}-${var.env}-Worker"
  retention_in_days = var.log_retention_days
}

resource "aws_mwaa_environment" "this" {
  name                           = "${var.environment_name}-${var.env}"
  airflow_version                = var.airflow_version
  dag_s3_path                    = var.dag_s3_path
  source_bucket_arn              = var.source_bucket_arn
  execution_role_arn             = var.execution_role_arn
  network_configuration {
    security_group_ids           = var.security_group_ids
    subnet_ids                   = var.subnet_ids
  }
  max_workers                    = var.max_workers
  min_workers                    = var.min_workers
  webserver_access_mode          = var.webserver_access_mode

  logging_configuration {
    dag_processing_logs {
      enabled        = var.enable_dag_processing_logs
      log_level      = var.dag_processing_log_level
    }
    scheduler_logs {
      enabled        = var.enable_scheduler_logs
      log_level      = var.scheduler_log_level
    }
    task_logs {
      enabled        = var.enable_task_logs
      log_level      = var.task_log_level
    }
    webserver_logs {
      enabled        = var.enable_webserver_logs
      log_level      = var.webserver_log_level
    }
    worker_logs {
      enabled        = var.enable_worker_logs
      log_level      = var.worker_log_level
    }
    
  }

  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.dag_processing,
    aws_cloudwatch_log_group.scheduler,
    aws_cloudwatch_log_group.task,
    aws_cloudwatch_log_group.webserver,
    aws_cloudwatch_log_group.worker
  ]
}
