###############################################################################
# Data Sources
###############################################################################
data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

###############################################################################
# Security Groups
###############################################################################
## PublicWebAlbSg
resource "aws_security_group" "web_alb_sg" {
  name_prefix = "alb-sg-"
  description = "Public Web Traffic"
  vpc_id      = var.ProductionVPC

  tags = {
    Name        = "alb-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_alb_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
}

resource "aws_security_group_rule" "web_alb_sg_ingress_tcp_80_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
  description       = "Ingress from 0.0.0.0/0 (TCP:80)"
}

resource "aws_security_group_rule" "web_alb_sg_ingress_tcp_443_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_alb_sg.id
  description       = "Ingress from 0.0.0.0/0 (TCP:443)"
}

## PrivateWebEc2Sg
resource "aws_security_group" "web_ec2_sg" {
  name_prefix = "web-sg-"
  description = "Access to Web instance(s)"
  vpc_id      = var.ProductionVPC

  tags = {
    Name        = "web-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_ec2_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_ec2_sg.id
}

resource "aws_security_group_rule" "web_ec2_sg_ingress_tcp_80_web_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_alb_sg.id
  security_group_id        = aws_security_group.web_ec2_sg.id
  description              = "Ingress from alb-sg (TCP:80)"
}

resource "aws_security_group_rule" "web_ec2_sg_ingress_tcp_22_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.web_alb_sg.id
  cidr_blocks       = [var.managementcidr]
  description       = "Ingress from Bastion Host VPC (TCP:22)"
}

## PrivateRdsSg
resource "aws_security_group_rule" "rds_sg_ingress_tcp_5432_web_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_ec2_sg.id
  security_group_id        = var.rds_sg_id
  description              = "Ingress from web-sg (TCP:3306)"
}

###############################################################################
# S3
###############################################################################
resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "log_bucket" {
  acl           = "private"
  bucket        = "elbaccesslogs-${random_string.random.result}"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "log_bucket_policy" {
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.log_bucket.arn}/*"]

    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.log_bucket_policy.json
}

###############################################################################
# Application Load Balancer
###############################################################################
resource "tls_private_key" "self" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "self" {
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.self.private_key_pem
  validity_period_hours = 2160

  subject {
    common_name         = "self.sandys.com"
    organization        = "Sandys"
    organizational_unit = "Cloud Architecture"
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self" {
  private_key      = tls_private_key.self.private_key_pem
  certificate_body = tls_self_signed_cert.self.cert_pem
}

resource "aws_lb" "alb" {
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "alb"
  security_groups    = [aws_security_group.web_alb_sg.id]
  subnets            = [var.DMZSubnetA, var.DMZSubnetB]

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.bucket
    prefix  = "Logs"
    enabled = true
  }

  depends_on = [
    aws_s3_bucket_policy.log_bucket_policy,
  ]

  tags = {
    Name        = "ELBWeb",
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "main" {
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.ProductionVPC

  depends_on = [aws_lb.alb]

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  certificate_arn   = aws_acm_certificate.self.arn
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}

###############################################################################
# AutoScaling Group
###############################################################################
resource "aws_launch_template" "launch_template" {
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_ec2_sg.id]
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = [var.AppPrivateSubnetA, var.AppPrivateSubnetB]
  target_group_arns   = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}
