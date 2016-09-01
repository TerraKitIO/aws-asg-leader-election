##
# Leader election automatically determines a "leader" instance within an autoscaling
# group.  Scaling events will trigger leader election, insuring there is always one
# leader whenever instances are added or removed.

resource "aws_lambda_function" "leader" {
  function_name = "${var.name}"
  description = "Elects a leader in an autoscaling upon receiving scaling events"
  runtime = "nodejs"
  filename = "${path.module}/files/ElectASGLeader.zip"
  source_code_hash = "${base64sha256(file("${path.module}/files/exports.zip"))}"
  handler = "exports.handler"
  role = "${aws_iam_role.lambda.arn}"
  timeout = "30"
  runtime = "nodejs4.3"
}

resource "aws_lambda_permission" "sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.leader.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${var.asg_event_topic_arn}"
}

resource "aws_sns_topic_subscription" "leader" {
    topic_arn = "${var.asg_event_topic_arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.leader.arn}"
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-lambda-role"
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

resource "aws_iam_role_policy" "lambda" {
    name = "${var.name}-lambda-role-policy"
    role = "${aws_iam_role.lambda.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Resource": [ "*" ],
            "Action": [
                "ec2:*Tags",
                "ec2:Describe*"
            ],
            "Sid": "Stmt1447795937000",
            "Effect": "Allow"
        },
        {
            "Resource": "arn:aws:logs:*:*:*",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Effect": "Allow"
        },
        {
            "Resource": [
                "*"
            ],
            "Action": [
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "s3:ListMyBuckets"
            ],
            "Sid": "Stmt1447796511000",
            "Effect": "Allow"
        }
    ]
}
EOF
}
