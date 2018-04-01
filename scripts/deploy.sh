# Evaluate ECR LogIn Command From AWS
eval $(aws ecr get-login --no-include-email)

## Configure the details about the deployment
SERVICE_NAME="go-ecs"
CLUSTER_NAME="go-ecs"
TASK_FAMILY="go-ecs"
TASK_NAME="go-ecs"

AWS_REGION="ap-south-1"

# Create a Task Definition
task_def='[
  {
    "name": "${TASK_NAME}",
    "image": "${DOCKER_REPO}:${CIRCLE_BUILD_NUM}",
    "essential": true,
    "memoryReservation": 1000,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 80
      }
    ]
  }
]'

# Register task definition
json=$(aws ecs register-task-definition --region ${AWS_REGION} --container-definitions "$task_def" --family "$TASK_FAMILY")

# Grab revision # using regular bash and grep
revision=$(echo "$json" | grep -o '"revision": [0-9]*' | grep -Eo '[0-9]+')

# Deploy revision
aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition "$TASK_NAME":"$revision"

## Wait until the service runs with the new task revision
SERVICE_TASK=`aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | egrep "taskDefinition" | tr ":" " " | awk '{print $8}' | sed 's/",//' | head -1`
RUNNING_TASK=`aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | egrep "taskDefinition" | tr ":" " " | awk '{print $8}' | sed 's/",//' | tail -1`
echo "SERVICE_TASK:" $SERVICE_TASK
echo "RUNNING_TASK:" $RUNNING_TASK
while [[ ${SERVICE_TASK} != ${RUNNING_TASK} ]]; do
    sleep 10
    SERVICE_TASK=`aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | egrep "taskDefinition" | tr ":" " " | awk '{print $8}' | sed 's/",//' | head -1`
    RUNNING_TASK=`aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | egrep "taskDefinition" | tr ":" " " | awk '{print $8}' | sed 's/",//' | tail -1`
    echo "Waiting for recent task running Service Task:"${SERVICE_TASK}" Running Task:"${RUNNING_TASK}
done

echo "Task ${RUNNING_TASK} has been deployed successfully"