terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "Private"
  }
}

resource "random_string" "rds_root_username" {
  length  = 16
  special = false
  numeric = false
}

resource "random_password" "rds_root_password" {
  length           = 32
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?" # removes @ from special char list
}

resource "random_string" "rds_final_snapshot_suffix" {
  length  = 16
  special = false
  numeric = false
}

resource "aws_kms_key" "rds_encryption" {
  count       = var.is_database_storage_encrypted ? 1 : 0
  description = "${title(var.database_cluster_name)} RDS Encryption"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.database_cluster_name} rds subnet group"
  subnet_ids = data.aws_subnets.main.ids

  tags = merge(var.tags, {
    name = "${var.database_cluster_name} rds subnet group"
  })
}

resource "aws_security_group" "rds_security_group" {
  name   = "${var.database_cluster_name} rds security group"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "rds_instance" {
  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
    ]
  }

  identifier             = "${var.database_cluster_name}-${var.environment}"
  allocated_storage      = var.database_min_storage
  max_allocated_storage  = var.database_max_storage
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  ca_cert_identifier     = var.database_ca_cert_identifier
  instance_class         = var.database_cluster_instance_size
  username               = random_string.rds_root_username.result
  password               = random_password.rds_root_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  auto_minor_version_upgrade  = var.is_auto_minor_version_upgrade_enabled
  allow_major_version_upgrade = var.is_auto_major_version_upgrade_enabled

  backup_retention_period = var.database_backup_retention_period

  storage_encrypted = var.is_database_storage_encrypted
  kms_key_id        = var.is_database_storage_encrypted ? aws_kms_key.rds_encryption[0].arn : ""

  final_snapshot_identifier = "${var.database_cluster_name}-db-final-snapshot-${random_string.rds_final_snapshot_suffix.result}"

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_alarm" {
  count = var.is_database_storage_alarm_enabled ? 1 : 0

  alarm_name          = "${var.database_cluster_name}-db-storage-alarm"
  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"

  dimensions = {
    DBInstanceIdentifier = var.database_cluster_name
  }

  threshold          = var.database_storage_alarm_threshold
  period             = var.database_storage_alarm_period
  evaluation_periods = var.database_storage_alarm_evaluation_periods
  alarm_actions      = var.database_storage_alarm_alarm_actions
}
