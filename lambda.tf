resource "aws_lambda_function" "dynamo_crud" {
  function_name = "DynamoCRUDFunction"
  handler       = "index.handler"  # Adjust based on your Lambda’s entry point
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_exec_role.arn
  
  filename = "zip/new-lambda-package5.zip"
}



resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaDynamoCRUDRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_full_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
