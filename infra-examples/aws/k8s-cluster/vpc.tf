data "aws_vpc" "reference" {
  filter {
    name   = "tag:Name"
    values = [var.name]
  }
}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.reference.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}
