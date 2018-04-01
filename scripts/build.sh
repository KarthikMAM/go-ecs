# Evaluate ECR LogIn Command From AWS
eval $(aws ecr get-login --no-include-email --region ap-south-1)

# Build the docker image
docker build --rm -f Dockerfile -t ${DOCKER_NAME} .

# Tag the docker image
docker tag ${DOCKER_NAME}:latest ${DOCKER_REPO}:${CIRCLE_BUILD_NUM}

# Deploy it to ECR
docker push ${DOCKER_REPO}:${CIRCLE_BUILD_NUM}