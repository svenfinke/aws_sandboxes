resource "aws_dynamodb_table" "sandboxes" {
  name           = "Sandboxes"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "account_id"

  global_secondary_index {
    name               = "Launched"
    hash_key           = "launched"
    range_key          = "account_id"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "ALL"
  }

  attribute {
    name = "account_id"
    type = "S"
  }

  attribute {
    name = "launched"
    type = "S"
  }

  tags = {
    Name        = "sandboxes"
    Environment = "development"
  }
}

data "aws_iam_policy_document" "stepfucntion_assume_role_policy"{
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["states.amazonaws.com"]
      } 
    }
}

resource "aws_iam_policy" "stepfunction_xray" {
    name = "stepfunction_xray_access"
    path = "/"
    policy = jsonencode({
        "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "xray:PutTraceSegments",
                        "xray:PutTelemetryRecords",
                        "xray:GetSamplingRules",
                        "xray:GetSamplingTargets"
                    ],
                    "Resource": [
                        "*"
                    ]
                }
            ]
    })
}

resource "aws_iam_role" "register_sandbox"{
    name = "register_sandbox_service"
    assume_role_policy = data.aws_iam_policy_document.stepfucntion_assume_role_policy.json

    inline_policy {
        name="register_sandbox_role"
        policy=jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:PutItem"
                    ],
                    "Resource": [
                        "*"
                    ]
                }
            ]
        })
    }
}

resource "aws_iam_role_policy_attachment" "register_sandbox_xray" {
    role = aws_iam_role.register_sandbox.name
    policy_arn = aws_iam_policy.stepfunction_xray.arn
}

resource "aws_sfn_state_machine" "register_sandbox"{
    name = "register_sandbox"
    role_arn = aws_iam_role.register_sandbox.arn

    definition = <<EOF
{
  "Comment": "Add a new sandbox account to the sandbox pool",
  "StartAt": "RegisterSandbox",
  "States": {
    "RegisterSandbox": {
      "Type": "Task",
      "Resource": "arn:aws:states:::dynamodb:putItem",
      "Parameters": {
        "TableName": "Sandboxes",
        "Item": {
          "account_id": {
            "S.$": "$.account_id"
          },
          "launched": {
            "S": "false"
          },
          "username": {
            "S": ""
          },
          "user_arn": {
            "S": ""
          }
        }
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "launch_sandbox"{
    name = "launch_sandbox_service"
    assume_role_policy = data.aws_iam_policy_document.stepfucntion_assume_role_policy.json

    inline_policy {
        name="launch_sandbox_role"
        policy=jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:Query"
                    ],
                    "Resource": [
                        aws_dynamodb_table.sandboxes.arn,
                        "${aws_dynamodb_table.sandboxes.arn}/*"
                    ]
                }
            ]
        })
    }
}

resource "aws_iam_role_policy_attachment" "launch_sandbox_xray" {
    role = aws_iam_role.launch_sandbox.name
    policy_arn = aws_iam_policy.stepfunction_xray.arn
}

resource "aws_sfn_state_machine" "launch_sandbox"{
    name = "launch_sandbox"
    role_arn = aws_iam_role.launch_sandbox.arn

    definition = <<EOF
{
  "Comment": "Assign a sandbox to a user",
  "StartAt": "GetAvailableAccount",
  "States": {
    "GetAvailableAccount": {
      "Type": "Task",
      "Next": "Choice",
      "Parameters": {
        "TableName": "Sandboxes",
        "IndexName": "Launched",
        "KeyConditionExpression": "launched = :False",
        "ExpressionAttributeValues": {
          ":False": {
            "S": "false"
          }
        }
      },
      "Resource": "arn:aws:states:::aws-sdk:dynamodb:query",
      "ResultPath": "$.GetAvailableAccount"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.GetAvailableAccount.Count",
          "NumericGreaterThan": 0,
          "Comment": "Account found",
          "Next": "GrantPermissions"
        }
      ],
      "Default": "NotifyFailure"
    },
    "NotifyFailure": {
      "Type": "Pass",
      "Next": "Fail"
    },
    "GrantPermissions": {
      "Type": "Pass",
      "Next": "UpdateDynamoDB"
    },
    "UpdateDynamoDB": {
      "Type": "Pass",
      "Next": "NotifySuccess"
    },
    "NotifySuccess": {
      "Type": "Pass",
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    },
    "Fail": {
      "Type": "Fail"
    }
  }
}
EOF
}