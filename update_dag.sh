#!/bin/bash

# Load Terraform outputs
outputs=$(cat terraform_outputs.json)

# Extract values from the JSON
#bucket_name=$(echo "$outputs" | jq -r '."bucket-name".value')
bucket_name=$(echo "$outputs" | jq -r '.bucket_name.value')
# Check if bucket_name is empty or null
if [ -z "$bucket_name" ] || [ "$bucket_name" == "null" ]; then
  echo "Error: Bucket name is empty or null."
  exit 1
fi
cluster_name=$(echo "$outputs" | jq -r '.cluster_name.value')
container_name=$(echo "$outputs" | jq -r '.container_name.value')
task_definition=$(echo "$outputs" | jq -r '.full_task_definition_name.value')
#subnets=$(echo "$outputs" | jq -r '.subnet_ids.value | map("\"" + . + "\"") | join(", ")')
subnets=$(echo "$outputs" | jq -r '.subnet_ids.value | map("'"'"'" + . + "'"'"'") | join(", ")')

#subnets=$(echo "$outputs" | jq -r '.subnet_ids.value | join(", ")')
security_groups=$(echo "$outputs" | jq -r '.mwaa_env_security_group_id.value')
sns_arn=$(echo "$outputs" | jq -r '.sns_topic_arn.value')

# Read the DAG template
template_file="dags/dbt_ecs_task.py"
if [ ! -f "$template_file" ]; then
  echo "Error: DAG template file '$template_file' not found."
  exit 1
fi
dag_content=$(cat "$template_file")

# Replace placeholders
dag_content=$(echo "$dag_content" | sed "s/{{ task_id }}/$container_name/g")
dag_content=$(echo "$dag_content" | sed "s/{{ cluster }}/$cluster_name/g")
dag_content=$(echo "$dag_content" | sed "s/{{ task_definition }}/$task_definition/g")
dag_content=$(echo "$dag_content" | sed "s/{{ container-name }}/$container_name/g")
dag_content=$(echo "$dag_content" | sed "s/{{ subnets }}/$subnets/g")
dag_content=$(echo "$dag_content" | sed "s/{{ SNS_ARN }}/$sns_arn/g")
#dag_content=$(echo "$dag_content" | sed "s/{{ subnets }}/$subnets/g")

dag_content=$(echo "$dag_content" | sed "s/{{ security_groups }}/$security_groups/g")

# Save the updated DAG
updated_file="dags/dbt_ecs_task.py"
echo "$dag_content" > "$updated_file"

if aws s3 ls "s3://$bucket_name/dags/" > /dev/null 2>&1; then
  echo "The 'dags' folder already exists."
else
  echo "The 'dags' folder does not exist. Creating it now..."
  aws s3api put-object --bucket "$bucket_name" --key "dags/"
fi
#aws s3api put-object --bucket "$bucket_name" --key "dags/"
# Upload the DAG to the S3 bucket
aws s3 cp "$updated_file" "s3://$bucket_name/dags/"

if [ $? -eq 0 ]; then
  echo "DAG updated and uploaded successfully."
else
  echo "Error: Failed to upload DAG to S3 bucket."
fi
