AWS_ID= #This variable is created automatically
AWS_ACCESS_KEY= 
AWS_SECRET_KEY= 
AWS_REGION=

DOCKER_REPOSITORY_NAME=
DOCKER_IMAGE_NAME=
ECR_ENDPOINT=$AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$DOCKER_REPOSITORY_NAME

LAMBDA_ROLE_NAME=
LAMBDA_FUNCTION_NAME=
LAMBDA_POLICY_ARN=arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

API_GATEWAY_ID= #This variable is created automatically
API_GATEWAY_NAME=
API_GATEWAY_STAGE=