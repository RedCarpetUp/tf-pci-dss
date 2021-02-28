###############################################################################
# IAM
###############################################################################
### SysAdmin
resource "aws_iam_role" "SysAdminRole" {
  name = "SysAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_instance_profile" "SysAdminProfile" {
  name = "SysAdminProfile"
  path = "/"
}

resource "aws_iam_group" "SysAdmin" {
  name = "SysAdmin"
  path = "/"
}

resource "aws_iam_policy" "SysAdminPolicy" {
  name        = "SysAdminPolicy"
  path        = "/"
  description = "SysAdminPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:*"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
          "Bool": {
              "aws:MultiFactorAuthPresent": "true"
          }
      }
    },
    {
      "Action": [
        "aws-portal:*Billing"
      ],
      "Effect": "Deny",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail"
      ],
      "Effect": "Deny",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Create*",
        "kms:Revoke*",
        "kms:Enable*",
        "kms:Get*",
        "kms:Disable*",
        "kms:Delete*",
        "kms:Put*",
        "kms:Update*"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]

}
EOT
}

resource "aws_iam_role_policy_attachment" "SysAdminPolicyAttachRole" {
  role       = aws_iam_role.SysAdminRole.name
  policy_arn = aws_iam_policy.SysAdminPolicy.arn
}

resource "aws_iam_group_policy_attachment" "SysAdminPolicyAttachGroup" {
  group      = aws_iam_group.SysAdmin.name
  policy_arn = aws_iam_policy.SysAdminPolicy.arn
}

### IAMAdmin

resource "aws_iam_group" "IAMAdminGroup" {
  name = "IAMAdminGroup"
  path = "/"
}

resource "aws_iam_role" "IAMAdminRole" {
  name = "IAMAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_instance_profile" "IAMAdminProfile" {
  name = "IAMAdminProfile"
  path = "/"
  role = aws_iam_role.IAMAdminRole.name
}

resource "aws_iam_policy" "IAMAdminPolicy" {
  name        = "IAMAdminPolicy"
  path        = "/"
  description = "IAMAdminPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:*"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
          "Bool": {
              "aws:MultiFactorAuthPresent": "true"
          }
      }
    },
    {
      "Action": [
        "aws-portal:*Billing"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]

}
EOT
}

resource "aws_iam_role_policy_attachment" "IAMAdminPolicyAttachRole" {
  role       = aws_iam_role.IAMAdminRole.name
  policy_arn = aws_iam_policy.IAMAdminPolicy.arn
}

resource "aws_iam_group_policy_attachment" "IAMAdminPolicyPolicyAttachGroup" {
  group      = aws_iam_group.IAMAdminGroup.name
  policy_arn = aws_iam_policy.IAMAdminPolicy.arn
}

### InstanceOps

resource "aws_iam_group" "InstanceOpsGroup" {
  name = "InstanceOpsGroup"
  path = "/"

}

resource "aws_iam_role" "InstanceOpsRole" {
  name = "InstanceOpsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_instance_profile" "InstanceOpsProfile" {
  name = "InstanceOpsProfile"
  path = "/"
  role = aws_iam_role.InstanceOpsRole.name
}

resource "aws_iam_policy" "InstanceOpsPolicy" {
  name        = "InstanceOpsPolicy"
  path        = "/"
  description = "InstanceOpsPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "autoscaling:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "aws-portal:*Billing"
      ],
      "Effect": "Deny",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Create*",
        "kms:Revoke*",
        "kms:Enable*",
        "kms:Get*",
        "kms:Disable*",
        "kms:Delete*",
        "kms:Put*",
        "kms:Update*"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]

}
EOT
}

resource "aws_iam_role_policy_attachment" "InstanceOpsPolicyAttachRole" {
  role       = aws_iam_role.InstanceOpsRole.name
  policy_arn = aws_iam_policy.InstanceOpsPolicy.arn
}

resource "aws_iam_group_policy_attachment" "InstanceOpsPolicyAttachGroup" {
  group      = aws_iam_group.InstanceOpsGroup.name
  policy_arn = aws_iam_policy.InstanceOpsPolicy.arn
}

### ReadOnlyAdmin

resource "aws_iam_group" "ReadOnlyAdminGroup" {
  name = "ReadOnlyAdminGroup"
  path = "/"

}

resource "aws_iam_role" "ReadOnlyAdminRole" {
  name = "ReadOnlyAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_instance_profile" "ReadOnlyAdminProfile" {
  name = "ReadOnlyAdminProfile"
  path = "/"
  role = aws_iam_role.ReadOnlyAdminRole.name
}

resource "aws_iam_policy" "ReadOnlyAdminPolicy" {
  name        = "ReadOnlyAdminPolicy"
  path        = "/"
  description = "ReadOnlyAdminPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "appstream:Get*",
        "autoscaling:Describe*",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStackResources",
        "cloudformation:GetTemplate",
        "cloudformation:List*",
        "cloudfront:Get*",
        "cloudfront:List*",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "directconnect:Describe*",
        "dynamodb:GetItem",
        "dynamodb:BatchGetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DescribeTable",
        "dynamodb:ListTables",
        "ec2:Describe*",
        "elasticache:Describe*",
        "elasticbeanstalk:Check*",
        "elasticbeanstalk:Describe*",
        "elasticbeanstalk:List*",
        "elasticbeanstalk:RequestEnvironmentInfo",
        "elasticbeanstalk:RetrieveEnvironmentInfo",
        "elasticloadbalancing:Describe*",
        "elastictranscoder:Read*",
        "elastictranscoder:List*",
        "iam:List*",
        "iam:Get*",
        "kinesis:Describe*",
        "kinesis:Get*",
        "kinesis:List*",
        "opsworks:Describe*",
        "opsworks:Get*",
        "route53:Get*",
        "route53:List*",
        "redshift:Describe*",
        "redshift:ViewQueriesInConsole",
        "rds:Describe*",
        "rds:ListTagsForResource",
        "s3:Get*",
        "s3:List*",
        "sdb:GetAttributes",
        "sdb:List*",
        "sdb:Select*",
        "ses:Get*",
        "ses:List*",
        "sns:Get*",
        "sns:List*",
        "sqs:GetQueueAttributes",
        "sqs:ListQueues",
        "sqs:ReceiveMessage",
        "storagegateway:List*",
        "storagegateway:Describe*",
        "trustedadvisor:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "aws-portal:*Billing"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]

}
EOT
}

resource "aws_iam_role_policy_attachment" "ReadOnlyAdminPolicyAttachRole" {
  role       = aws_iam_role.ReadOnlyAdminRole.name
  policy_arn = aws_iam_policy.ReadOnlyAdminPolicy.arn
}

resource "aws_iam_group_policy_attachment" "ReadOnlyAdminPolicyAttachGroup" {
  group      = aws_iam_group.ReadOnlyAdminGroup.name
  policy_arn = aws_iam_policy.ReadOnlyAdminPolicy.arn
}

### ReadOnlyBillingGroup

resource "aws_iam_group" "ReadOnlyBillingGroup" {
  name = "ReadOnlyBillingGroup"
  path = "/"

}

resource "aws_iam_policy" "ReadOnlyBillingPolicy" {
  name        = "ReadOnlyBillingPolicy"
  path        = "/"
  description = "ReadOnlyBillingPolicy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "aws-portal:View*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "aws-portal:*Account"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]

}
EOT
}

resource "aws_iam_group_policy_attachment" "ReadOnlyBillingPolicyAttachGroup" {
  group      = aws_iam_group.ReadOnlyBillingGroup.name
  policy_arn = aws_iam_policy.ReadOnlyBillingPolicy.arn
}
