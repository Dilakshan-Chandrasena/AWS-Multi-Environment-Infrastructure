
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "iam"
  })
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name_prefix        = "${var.name}-execution-"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name_prefix        = "${var.name}-task-"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-task-role"
  })
}
