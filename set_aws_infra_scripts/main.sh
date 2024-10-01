#! bin/sh

# set -e

dir="$(cd "$(dirname "$0")"; pwd)"

source "$dir/env.sh"
source "$dir/resources/ecr.sh"
source "$dir/resources/lambda.sh"
source "$dir/resources/apigateway.sh"

aws configure set aws_access_key_id $AWS_ACCESS_KEY
aws configure set aws_secret_access_key $AWS_SECRET_KEY
aws configure set region $AWS_REGION

######## Login to Aws ########
AWS_ID=$(aws sts get-caller-identity \
    --output text \
    --query 'Account')

sed -i '' "s/AWS_ID=.*$/AWS_ID=$AWS_ID/" "$dir/env.sh" # on mac
# sed -i "s/AWS_ID=.*$/AWS_ID=$AWS_ID/" "$dir/env.sh" # on linux
echo "[Success] Login to Aws"


######## ECR & push image ########
ECR_ENDPOINT=$AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$DOCKER_REPOSITORY_NAME
create_ecr $AWS_ID
push_first_image $AWS_ID $ECR_ENDPOINT
echo "[Success] Create ECR and Push first image"

# ######## Lambda ########
create_lambda $ECR_ENDPOINT
echo "[Success] Create Lambda"


######## API Gateway ########
create_apigateway $AWS_ID
echo "[Success] Create API Gateway and Invoke lambda"