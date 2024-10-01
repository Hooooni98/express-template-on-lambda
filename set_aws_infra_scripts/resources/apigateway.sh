dir="$(cd "$(dirname "$0")"; pwd)"
source "$dir/env.sh"

create_apigateway() {
    AWS_ID=$1

    aws apigateway create-rest-api \
        --region $AWS_REGION \
        --name $API_GATEWAY_NAME \
        --endpoint-configuration types=REGIONAL \
        --description 'A test API' \
        --query 'id' \
        >/dev/null

    API_GATEWAY_ID=$(aws apigateway get-rest-apis \
        --region $AWS_REGION \
        --query "items[?name=='$API_GATEWAY_NAME'].[id]" \
        --output text)
    API_GATEWAY_ROOT_RESOURCE_ID=$(aws apigateway get-resources \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --query "items[?path=='/'].[id]" \
        --output text)
    API_GATEWAY_ARN="arn:aws:execute-api:${AWS_REGION}:${AWS_ID}:${API_GATEWAY_ID}"
    API_GATEWAY_RESOURCE_NAME='{proxy+}'
    sed -i '' "s|API_GATEWAY_ID=.*$|API_GATEWAY_ID=$API_GATEWAY_ID|" "$dir/env.sh"


    create_apigateway_resource $API_GATEWAY_ID $API_GATEWAY_ROOT_RESOURCE_ID $API_GATEWAY_RESOURCE_NAME 

    set_apigateway_options $API_GATEWAY_ID $API_GATEWAY_ROOT_RESOURCE_ID $API_GATEWAY_RESOURCE_NAME

    deploy $API_GATEWAY_ID
}

create_apigateway_resource() {
    API_GATEWAY_ID=$1
    API_GATEWAY_ROOT_RESOURCE_ID=$2
    API_GATEWAY_RESOURCE_NAME=$3

    aws apigateway create-resource \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --parent-id $API_GATEWAY_ROOT_RESOURCE_ID \
        --path-part $API_GATEWAY_RESOURCE_NAME \
        >/dev/null
}

set_apigateway_options() {
    API_GATEWAY_ID=$1
    API_GATEWAY_ROOT_RESOURCE_ID=$2
    API_GATEWAY_RESOURCE_NAME=$3

    API_GATEWAY_RESOURCE_ID=$(aws apigateway get-resources \
    --region $AWS_REGION \
    --rest-api-id $API_GATEWAY_ID \
    --query "items[?path=='/$API_GATEWAY_RESOURCE_NAME'].[id]" \
    --output text)
    LAMBDA_FUNCTION_ARN=$(aws lambda get-function \
        --region $AWS_REGION \
        --function-name $LAMBDA_FUNCTION_NAME \
        --query 'Configuration.FunctionArn' \
        --output text)

    aws apigateway put-method \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --resource-id $API_GATEWAY_RESOURCE_ID \
        --http-method ANY \
        --authorization-type NONE \
        >/dev/null

    aws apigateway put-integration \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --resource-id $API_GATEWAY_RESOURCE_ID \
        --http-method ANY \
        --integration-http-method POST \
        --type AWS_PROXY \
        --uri "arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/$LAMBDA_FUNCTION_ARN/invocations" \
        >/dev/null

    aws lambda add-permission \
        --region $AWS_REGION \
        --function-name $LAMBDA_FUNCTION_NAME \
        --source-arn "$API_GATEWAY_ARN/*/ANY/$API_GATEWAY_RESOURCE_NAME" \
        --principal apigateway.amazonaws.com \
        --statement-id $API_GATEWAY_ROOT_RESOURCE_ID \
        --action lambda:InvokeFunction &>/dev/null

    aws apigateway put-method-response \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --resource-id $API_GATEWAY_RESOURCE_ID \
        --http-method ANY \
        --status-code 200 \
        --response-models '{"application/json": "Empty"}' \
        >/dev/null

    aws apigateway put-integration-response \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --resource-id $API_GATEWAY_RESOURCE_ID \
        --http-method ANY \
        --status-code 200 --selection-pattern '' \
        >/dev/null
}

deploy() {
    API_GATEWAY_ID=$1

    aws apigateway create-deployment \
        --region $AWS_REGION \
        --rest-api-id $API_GATEWAY_ID \
        --stage-name dev \
        >/dev/null
}


