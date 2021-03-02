###############################################################################
# S3
###############################################################################
resource "aws_s3_bucket" "s3cloudtrailbuckets" {
  bucket        = var.BucketName
  force_destroy = true
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.BucketName}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.BucketName}/prefix/AWSLogs/${var.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "s3bucketblock" {
  bucket = aws_s3_bucket.s3cloudtrailbuckets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###############################################################################
# Cloudtrail
###############################################################################
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "tf-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.s3cloudtrailbuckets.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.CloudWatchLogGroup.arn}:*"
}

# This policy allows the CloudTrail service for any account to assume this role.
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# This role is used by CloudTrail to send logs to CloudWatch.
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name               = "CloudWatchLogsRole"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

###############################################################################
# CloudWatch
###############################################################################
resource "aws_cloudwatch_log_group" "CloudWatchLogGroup" {
  name              = "CentralCloudWatchLogGroupPCI"
  retention_in_days = 365
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.CloudWatchLogGroup.name}:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch_role.name]
}

### Metric Filter - IAM Root Activity
resource "aws_cloudwatch_log_metric_filter" "IAMRootActivity" {
  name    = "IAMRootActivity"
  pattern = <<PATTERN
  {
    ($.userIdentity.type = "Root") &&
    ($.userIdentity.invokedBy NOT EXISTS) &&
    ($.eventType != "AwsServiceEvent")
  }
  PATTERN

  log_group_name = aws_cloudwatch_log_group.CloudWatchLogGroup.name

  metric_transformation {
    name      = "RootUserPolicyEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "RootActivityAlarm" {
  alarm_name          = "RootActivityAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootUserPolicyEventCount"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Root user activity detected!"

}

### Metric Filter - Unauthorized Attempts
resource "aws_cloudwatch_log_metric_filter" "UnauthorizedAttempts" {
  name    = "UnauthorizedAttempts"
  pattern = <<PATTERN
  {
    ($.errorCode=AccessDenied) ||
    ($.errorCode=UnauthorizedOperation) ||
    ($.eventName = ConsoleLogin) && ($.errorMessage = "Failed authentication")
  }
  PATTERN

  log_group_name = aws_cloudwatch_log_group.CloudWatchLogGroup.name

  metric_transformation {
    name      = "UnauthorizedAttemptCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "UnauthorizedAttemptAlarm" {
  alarm_name          = "UnauthorizedAttemptAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAttemptCount"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Multiple unauthorized actions or logins attempted!"

}

### Metric Filter - IAM Policy Changes
resource "aws_cloudwatch_log_metric_filter" "IAMPolicyChangesMetricFilter" {
  name    = "IAMPolicyChangesMetricFilter"
  pattern = <<PATTERN
  {
    ($.eventName=DeleteGroupPolicy) ||
    ($.eventName=DeleteRolePolicy) ||
    ($.eventName=DeleteUserPolicy) ||
    ($.eventName=PutGroupPolicy) ||
    ($.eventName=PutRolePolicy) ||
    ($.eventName=PutUserPolicy) ||
    ($.eventName=CreatePolicy) ||
    ($.eventName=DeletePolicy) ||
    ($.eventName=CreatePolicyVersion) ||
    ($.eventName=DeletePolicyVersion) ||
    ($.eventName=AttachRolePolicy) ||
    ($.eventName=DetachRolePolicy) ||
    ($.eventName=AttachUserPolicy) ||
    ($.eventName=DetachUserPolicy) ||
    ($.eventName=AttachGroupPolicy) ||
    ($.eventName=DetachGroupPolicy)
  }
  PATTERN

  log_group_name = aws_cloudwatch_log_group.CloudWatchLogGroup.name

  metric_transformation {
    name      = "IAMPolicyEventCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "IAMPolicyChangesAlarm" {
  alarm_name          = "IAMPolicyChangesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "IAMPolicyEventCount"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "IAM Configuration changes detected!"

}

### Metric Filter - IAM Create Access Key
resource "aws_cloudwatch_log_metric_filter" "IAMCreateAccessKeyFilter" {
  name    = "IAMCreateAccessKeyFilter"
  pattern = <<PATTERN
  {
    ($.eventName=CreateAccessKey)
  }
  PATTERN

  log_group_name = aws_cloudwatch_log_group.CloudWatchLogGroup.name

  metric_transformation {
    name      = "NewAccessKeyCreated"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "IAMCreateAccessKeyAlarm" {
  alarm_name          = "IAMCreateAccessKeyAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NewAccessKeyCreated"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Warning: New IAM access key was created. Please be sure this action was neccessary."

}

### Metric Filter - CloudTrailChange
resource "aws_cloudwatch_log_metric_filter" "CloudTrailChangeFilter" {
  name    = "CloudTrailChange"
  pattern = <<PATTERN
  {
    ($.eventSource = cloudtrail.amazonaws.com) &&
    (
      ($.eventName != Describe*) &&
      ($.eventName != Get*) &&
      ($.eventName != Lookup*) &&
      ($.eventName != List*)
    )
  }
  PATTERN

  log_group_name = aws_cloudwatch_log_group.CloudWatchLogGroup.name

  metric_transformation {
    name      = "CloudTrailChangeCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "CloudTrailChangeAlarm" {
  alarm_name          = "CloudTrailChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CloudTrailChangeCount"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Warning: Changes to CloudTrail log configuration detected in this account"

}
