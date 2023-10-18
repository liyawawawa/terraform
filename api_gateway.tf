resource "aws_api_gateway_rest_api" "dynamo_api" {
  name        = "DynamoDBCRUDAPI"
  description = "API to perform CRUD operations on DynamoDB"
}

resource "aws_api_gateway_resource" "items_resource" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  parent_id   = aws_api_gateway_rest_api.dynamo_api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_resource" "item_resource" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  parent_id   = aws_api_gateway_resource.items_resource.id
  path_part   = "{id}"
}

# GET /items
resource "aws_api_gateway_method" "items_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET /items/{id}
resource "aws_api_gateway_method" "item_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_api.id
  resource_id   = aws_api_gateway_resource.item_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# PUT /items
resource "aws_api_gateway_method" "items_put_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

# DELETE /items/{id}
resource "aws_api_gateway_method" "item_delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.dynamo_api.id
  resource_id   = aws_api_gateway_resource.item_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "items_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  resource_id = aws_api_gateway_resource.items_resource.id
  http_method = aws_api_gateway_method.items_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamo_crud.invoke_arn
}

resource "aws_api_gateway_integration" "item_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamo_crud.invoke_arn
}

resource "aws_api_gateway_integration" "items_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  resource_id = aws_api_gateway_resource.items_resource.id
  http_method = aws_api_gateway_method.items_put_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamo_crud.invoke_arn
}

resource "aws_api_gateway_integration" "item_delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_delete_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamo_crud.invoke_arn
}

resource "aws_api_gateway_deployment" "dynamo_api_deployment" {
  depends_on  = [
    aws_api_gateway_integration.items_get_integration,
    aws_api_gateway_integration.item_get_integration,
    aws_api_gateway_integration.items_put_integration,
    aws_api_gateway_integration.item_delete_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.dynamo_api.id
  stage_name  = "prod"
}

# Lambda permissions
resource "aws_lambda_permission" "apigw_lambda_items_get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.dynamo_api_deployment.execution_arn}/GET/items"
}

resource "aws_lambda_permission" "apigw_lambda_item_get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.dynamo_api_deployment.execution_arn}/GET/items/{id}"
}

resource "aws_lambda_permission" "apigw_lambda_items_put" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.dynamo_api_deployment.execution_arn}/PUT/items"
}

resource "aws_lambda_permission" "apigw_lambda_item_delete" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.dynamo_api_deployment.execution_arn}/DELETE/items/{id}"
}

output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.dynamo_api.id}.execute-api.eu-central-1.amazonaws.com/prod/items"
  description = "Endpoint URL for the deployed API Gateway"
}




