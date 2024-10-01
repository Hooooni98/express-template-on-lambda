#! /bin/sh

set -e # 중간에 실패하면 추후 과정을 진행하지 않고 스크립트 종료

dir="$(cd "$(dirname "$0")"; pwd)"
cwd=$(pwd)
source "$dir/set_aws_infra_scripts/.env.sh"
commit_hash=$1

sudo docker build --platform linux/amd64 -t $DOCKER_IMAGE_NAME .

aws ecr get-login-password --region $AWS_REGION \
    | docker login --username AWS --password-stdin \
    $AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag $DOCKER_IMAGE_NAME:latest $ECR_ENDPOINT:latest
docker push $ECR_ENDPOINT:latest
if [ -n "$commit_hash" ] ; then # commit_hash가 존재하면 실행
    docker tag $DOCKER_IMAGE_NAME:latest $ECR_ENDPOINT:$commit_hash
    docker push $ECR_ENDPOINT:$commit_hash
fi

aws lambda update-function-code \
  --function-name $LAMBDA_FUNCTION_NAME \
  --image-uri $ECR_ENDPOINT:latest \
  --region $AWS_REGION