resource "aws_s3_bucket" "lambdas" {
  force_destroy = true
}

# get todos lambda
data "archive_file" "get_to_do_zip" {
  type        = "zip"
  source_file = "lambdas/getTodos.js"
  output_path = "lambdas/getTodos.zip"
}

resource "aws_s3_bucket_object" "lambda_get_todos" {
  key    = "${random_id.id.hex}-object"
  bucket = aws_s3_bucket.lambdas.id
  source = data.archive_file.get_to_do_zip.output_path
  etag   = data.archive_file.get_to_do_zip.output_base64sha256
}

resource "aws_lambda_function" "get_todos" {
  function_name = "GetTodos"
  s3_bucket = aws_s3_bucket.lambdas.id
  s3_key    = aws_s3_bucket_object.lambda_get_todos.id

  source_code_hash = data.archive_file.get_to_do_zip.output_base64sha256
  handler          = "getTodos.handler"
  runtime          = "nodejs10.x"
  role             = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "get_todo_by_id" {
  function_name = "GetTodoById"
  filename      = "lambdas/getTodoById.zip"
  handler       = "getTodoById.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "update_todo_by_id" {
  function_name = "UpdateTodoById"
  filename      = "lambdas/updateTodoById.zip"
  handler       = "updateTodoById.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "delete_todo_by_id" {
  function_name = "DeleteTodoById"
  filename      = "lambdas/deleteTodoById.zip"
  handler       = "deleteTodoById.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "create_todo" {
  function_name = "CreateTodo"
  filename      = "lambdas/createTodo.zip"
  handler       = "createTodo.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "create_comment" {
  function_name = "CreateComment"
  filename      = "lambdas/createComment.zip"
  handler       = "createComment.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "get_comments" {
  function_name = "GetComments"
  filename      = "lambdas/getComments.zip"
  handler       = "getComments.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "delete_comment_by_id" {
  function_name = "DeleteCommentById"
  filename      = "lambdas/deleteCommentById.zip"
  handler       = "deleteCommentById.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "create_like" {
  function_name = "CreateLike"
  filename      = "lambdas/createLike.zip"
  handler       = "createLike.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "get_likes" {
  function_name = "GetLikes"
  filename      = "lambdas/getLikes.zip"
  handler       = "getLikes.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "delete_like_by_id" {
  function_name = "DeleteLikeById"
  filename      = "lambdas/deleteLikeById.zip"
  handler       = "deleteLikeById.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAndDescribe",
            "Effect": "Allow",
            "Action": [
                "dynamodb:List*",
                "dynamodb:DescribeReservedCapacity*",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive"
            ],
            "Resource": "*"
        },
        {
            "Sid": "SpecificTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": [
              "${aws_dynamodb_table.todos.arn}*",
              "${aws_dynamodb_table.comments.arn}*",
              "${aws_dynamodb_table.likes.arn}*"
            ]
        }
    ]
}
EOF
}







