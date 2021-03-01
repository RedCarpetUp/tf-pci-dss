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
resource "aws_security_group" "rds_sg" {
  description = "Port 3306 database for access"
  vpc_id      = var.ProductionVPC

  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-database-access"
    Environment = var.environment
  }
}


###############################################################################
# Database
###############################################################################
resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.r4.large"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "aurora-cluster-demo"
  database_name          = "mydb"
  master_username        = "foo"
  master_password        = random_password.master_password.result
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  availability_zones     = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  storage_encrypted      = true
  skip_final_snapshot    = true
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.03.2"
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_db_subnet_group" "aurora_subnet_group" {

  name        = "aurora-cluster-demo-aurora-db-subnet-group"
  description = "Allowed subnets for Aurora DB cluster instances"
  subnet_ids = [
    var.DB_subnetA,
    var.DB_subnetB
  ]

  tags = {
    Name        = "aurora-cluster-demo-Aurora-DB-Subnet-Group"
    Environment = var.environment
  }

}

resource "random_password" "master_password" {
  length  = 10
  special = true
}

resource "aws_ssm_parameter" "rds_pwd_ssm" {

  name  = "RDS Password"
  type  = "SecureString"
  value = random_password.master_password.result
}
