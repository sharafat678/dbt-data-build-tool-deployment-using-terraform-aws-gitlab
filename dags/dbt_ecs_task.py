import boto3
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.utils.dates import days_ago
from airflow.operators.dummy import DummyOperator
from datetime import timedelta



# -------- SNS Configuration --------
SNS_ARN = '{{ SNS_ARN }}' #"arn:aws-cn:sns:cn-northwest-1:216962084862:dbt-sns-topic-dev-dbt-s3" 
sns_client = boto3.client("sns", region_name="cn-northwest-1")
logs_client = boto3.client("logs", region_name="cn-northwest-1")


LOG_GROUP = "dbt-cluster-logs-dev-dbt-s3"  # CloudWatch log group

def get_ecs_logs(log_group, limit=30):
    """Fetch last N log lines from the ECS task log group."""
    try:
        streams = logs_client.describe_log_streams(
            logGroupName=log_group,
            orderBy="LastEventTime",
            descending=True,
            limit=1
        )
        if not streams["logStreams"]:
            return "No log streams found."
        
        log_stream = streams["logStreams"][0]["logStreamName"]

        events = logs_client.get_log_events(
            logGroupName=log_group,
            logStreamName=log_stream,
            limit=limit,
            startFromHead=False
        )
        log_lines = [e["message"] for e in events["events"]]
        return "\n".join(log_lines) if log_lines else "No log events found."
    except Exception as e:
        return f"Error fetching logs: {e}"

def notify_failure(context):
    dag_id = context['dag'].dag_id
    run_id = context['run_id']
    task = context.get('task_instance')

    message = f"DAG {dag_id} failed. Run ID: {run_id}.\n\n\n\n\n"
    if task:
        message += f"Failed Task: {task.task_id}\n\n"

    # Fetch ECS logs
    ecs_logs = get_ecs_logs(LOG_GROUP, limit=30)
    message += f"--- CloudWatch Log Snippet (last 30 lines) ---\n{ecs_logs}\n"

    sns_client.publish(
        TopicArn=SNS_ARN,
        Message=message,
        Subject=f"Airflow DAG Failure - {dag_id}"
    )

def notify_success(context):
    dag_id = context['dag'].dag_id
    run_id = context['run_id']

    message = f"DAG {dag_id} succeeded    Run ID: {run_id}\n\n\n\n"
    ecs_logs = get_ecs_logs(LOG_GROUP, limit=30)
    message += f"--- CloudWatch Log Snippet (last 30 lines) ---\n{ecs_logs}"

    sns_client.publish(
        TopicArn=SNS_ARN,
        Message=message,
        Subject=f"Airflow DAG Success - {dag_id}"
    )


# -------- Default arguments --------
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

# # -------- Function to create a DAG for any dbt project --------
def create_dbt_ecs_dag(dag_id, project_name, s3_path):
    with DAG(
        dag_id=dag_id,
        default_args=default_args,
        description=f'Run dbt project {project_name} on ECS',
        start_date=days_ago(1),
        schedule_interval='0 18 * * *', #'0 */5 * * *',
        catchup=True,
        on_success_callback=notify_success,
        on_failure_callback=notify_failure,
    ) as dag:
        
        start_task = DummyOperator(task_id='start')

        run_dbt_container = EcsRunTaskOperator(
            task_id=f'run_{project_name}',
            cluster='{{ cluster }}',
            task_definition='{{ task_definition }}',
            launch_type='FARGATE',
            overrides={
                'containerOverrides': [
                    {
                        'name': '{{ container-name }}',
                        'command': [
                            'bash', '-c',
                            (
                                'source /opt/conda/etc/profile.d/conda.sh && '
                                'conda activate env1 && '
                                f'mkdir -p /tmp/{project_name} && '
                                f'aws s3 sync {s3_path} /tmp/{project_name}/ && '
                                f'aws s3 cp s3://sharedproject-dev-dbt-s3/{project_name}/profiles.yml /tmp/{project_name}/profiles.yml && '
                                f'cd /tmp/{project_name} && '
                                'dbt deps && dbt debug && dbt run'
                            )
                        ]
                    }
                ],
            },
            params={"project_name": project_name},
            network_configuration={
                'awsvpcConfiguration': {
                    'subnets': [{{ subnets }}],  # Subnet IDs
                    'securityGroups': ['{{ security_groups }}'],  # Security Group IDs.
                },
            },
        )

        end_task = DummyOperator(task_id='end')

        start_task >> run_dbt_container >> end_task

        return dag


# -------- Create DAGs --------
demo_dbt_dag = create_dbt_ecs_dag(
    dag_id='dbt_ecs_task_demo',
    project_name='demo_dbt',
    s3_path='s3://sharedproject-dev-dbt-s3/demo_dbt/project'
)

maximo_dbt_dag = create_dbt_ecs_dag(
    dag_id='dbt_ecs_task_maximo',
    project_name='maximo',
    s3_path='s3://sharedproject-dev-dbt-s3/maximo/project'
)

hero_dbt_dag = create_dbt_ecs_dag(
    dag_id='dbt_ecs_task_hero',
    project_name='hero',
    s3_path='s3://sharedproject-dev-dbt-s3/hero/project'      #this name of bucket comes form the infra creattion
)

# Expose DAGs to Airflow
globals()['dbt_ecs_task_demo'] = demo_dbt_dag
globals()['dbt_ecs_task_maximo'] = maximo_dbt_dag
globals()['dbt_ecs_task_hero'] = hero_dbt_dag




############## below is the tested and running dag for multiple projects##############.

# from airflow import DAG
# from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
# from airflow.utils.dates import days_ago
# from airflow.operators.dummy import DummyOperator
# from datetime import timedelta

# # Default arguments for all DAGs
# default_args = {
#     'owner': 'airflow',
#     'depends_on_past': False,
#     'email_on_failure': False,
#     'email_on_retry': False,
#     'retries': 1,
#     'retry_delay': timedelta(minutes=2),
# }

# # -------- Function to create a DAG for any dbt project --------
# def create_dbt_ecs_dag(dag_id, project_name, s3_path):
#     with DAG(
#         dag_id=dag_id,
#         default_args=default_args,
#         description=f'Run dbt project {project_name} on ECS',
#         start_date=days_ago(1),
# #        schedule_interval='0 18 * * *',
#         schedule_interval='0 */5 * * *',

#         catchup=True,
#     ) as dag:
        
#         start_task = DummyOperator(task_id='start')

#         run_dbt_container = EcsRunTaskOperator(
#             task_id=f'run_{project_name}',
#             cluster='{{ cluster }}',
#             task_definition='{{ task_definition }}',
#             launch_type='FARGATE',
#             overrides={
#                 'containerOverrides': [
#                     {
#                         'name': '{{ container-name }}',
#                         'command': [
#                             'bash', '-c',
#                             (
#                                 'source /opt/conda/etc/profile.d/conda.sh && '
#                                 'conda activate env1 && '
#                                 f'mkdir -p /tmp/{project_name} && '
#                                 f'aws s3 sync {s3_path} /tmp/{project_name}/ && '
#                                 f'aws s3 cp s3://sharedproject-dev-dbt-s3/{project_name}/profiles.yml /tmp/{project_name}/profiles.yml && '
#                                 f'cd /tmp/{project_name} && '
#                                 'dbt deps && dbt debug && dbt run'
#                             )
#                         ]
#                     }
#                 ],
#             },
#             params={"project_name": project_name},
#             network_configuration={
#                 'awsvpcConfiguration': {
#                     'subnets': [{{ subnets }}],  # Subnet IDs
#                     'securityGroups': ['{{ security_groups }}'],  # Security Group IDs
#                 },
#             },
#         )

#         end_task = DummyOperator(task_id='end')

#         start_task >> run_dbt_container >> end_task

#         return dag

# # -------- Create both DAGs --------
# demo_dbt_dag = create_dbt_ecs_dag(
#     dag_id='dbt_ecs_task_demo',
#     project_name='demo_dbt',
#     s3_path='s3://sharedproject-dev-dbt-s3/demo_dbt/project'
# )

# maximo_dbt_dag = create_dbt_ecs_dag(
#     dag_id='dbt_ecs_task_maximo',
#     project_name='maximo',
#     s3_path='s3://sharedproject-dev-dbt-s3/maximo/project'
# )

# # Expose DAGs to Airflow
# globals()['dbt_ecs_task_demo'] = demo_dbt_dag
# globals()['dbt_ecs_task_maximo'] = maximo_dbt_dag












#############################################Below is the runnign dag for s3 for one project 
# from airflow import DAG
# from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
# from airflow.utils.dates import days_ago
# from airflow.operators.dummy import DummyOperator
# from datetime import timedelta
# #from datetime import datetime
# #import pendulum

# #local_tz = pendulum.timezone("Asia/Shanghai")
# # Default arguments for the DAG.....
# default_args = {
#     'owner': 'airflow',
#     'depends_on_past': False,
#     #'start_date': datetime(2025, 6, 12),
#     'email_on_failure': False,
#     'email_on_retry': False,
#     'retries': 1,
#     'retry_delay': timedelta(minutes=2),
# }

# # Define the DAG
# with DAG(
#     dag_id='dbt_ecs_task',
#     default_args=default_args,
#     description='Run dbt container on ECS',
#     start_date=days_ago(1),
#     schedule_interval='0 18 * * *',
#     catchup=True,       #true means if it miss any jobs run then it will run those jobs...
# ) as dag:
    
#     # Start task
#     start_task = DummyOperator(task_id='start')
    
#     # ECS task execution
#     run_dbt_container = EcsRunTaskOperator(
#         task_id='{{ task_id }}', #Container-name
#         cluster='{{ cluster }}',  # ECS cluster name
#         task_definition='{{ task_definition }}',  # ECS task definition ARN
#         launch_type='FARGATE',
#         overrides={
#             'containerOverrides': [
#                 {
#                     'name':'{{ container-name }}',  # Container name and task id is sameReplace with the container name in the ECS task definition

#                             'command': [
#                                 'bash', '-c',
#                                 (
#                                     'source /opt/conda/etc/profile.d/conda.sh && '
#                                     'conda activate env1 && '
#                                     'mkdir -p /tmp/{{ params.project_name }} && '
#                                     'aws s3 sync s3://sharedproject-dev-dbt-s3/demo_dbt/ /tmp/{{ params.project_name }}/ && '
#                                     'aws s3 cp s3://sharedproject-dev-dbt-s3/profiles.yml /tmp/{{ params.project_name }}/profiles.yml && '
#                                     'cd /tmp/{{ params.project_name }} && '
#                                     'dbt deps && dbt debug && dbt run'
#                                 )
#                             ]
#                 }
#             ],
#         },
#         params={"project_name": "demo_dbt"},  # oas or "nile", "maximo"
#         network_configuration={
#             'awsvpcConfiguration': {
#                 'subnets': [{{ subnets }}],  # Subnet IDs passed dynamically
#                 'securityGroups': ['{{ security_groups }}'],  # Security group IDs passed dynamically..................
#             },
#         },
#     )

#     # End task
#     end_task = DummyOperator(
#         task_id='end'
#     )

#     # Define task dependencies
#     start_task >> run_dbt_container >> end_task