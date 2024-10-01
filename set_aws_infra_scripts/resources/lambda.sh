dir="$(cd "$(dirname "$0")"; pwd)"
source "$dir/env.sh"

create_lambda() {
    ECR_ENDPOINT=$1

    create_lambda_role

    LAMBDA_ROLE_ARN=$(aws iam get-role \
        --role-name $LAMBDA_ROLE_NAME \
        --query 'Role.Arn' \
        --output text)

    aws lambda create-function \
        --region $AWS_REGION \
        --function-name $LAMBDA_FUNCTION_NAME \
        --role $LAMBDA_ROLE_ARN \
        --package-type Image \
        --code ImageUri=$ECR_ENDPOINT:latest \
        --environment Variables={NODE_ENV=lambda} \
        >/dev/null
}

create_lambda_role() {
    aws iam create-role \
        --role-name $LAMBDA_ROLE_NAME \
        --assume-role-policy-document file://$dir/resources/lambda-role-policy.json \
        >/dev/null

    aws iam attach-role-policy \
        --role-name $LAMBDA_ROLE_NAME \
        --policy-arn $LAMBDA_POLICY_ARN

    sleep 10
}