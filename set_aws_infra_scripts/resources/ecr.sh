dir="$(cd "$(dirname "$0")"; pwd)"
source "$dir/.env.sh"

create_ecr() {
    AWS_ID=$1

    # create ecr
    aws ecr create-repository \
        --repository-name $DOCKER_REPOSITORY_NAME \
        --image-tag-mutability MUTABLE \
        >/dev/null
}

push_first_image() {
    AWS_ID=$1
    ECR_ENDPOINT=$2

    # build docker image
    docker build --platform linux/amd64 -t $DOCKER_IMAGE_NAME .

    # login to ecr
    aws ecr get-login-password --region $AWS_REGION \
        | docker login --username AWS --password-stdin \
        $AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    # docker push image to repository
    docker tag $DOCKER_IMAGE_NAME:latest $ECR_ENDPOINT:latest
    docker push $ECR_ENDPOINT:latest
}