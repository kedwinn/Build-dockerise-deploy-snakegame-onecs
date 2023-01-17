resource "aws_ecr_repository" "snake_game" {
  name = "snake_game"
}

resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_role_policy" {
  name = "ecs_role_policy"
  role = aws_iam_role.ecs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:
        ...
"ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:ListTaskDefinitions",
        "ecs:CreateService",
        "ecs:UpdateService",
        "ecs:DeleteService",
        "ecs:DescribeServices",
        "ecs:ListServices",
        "ecs:CreateTaskSet",
        "ecs:DeleteTaskSet",
        "ecs:DescribeTaskSets",
        "ecs:ListTaskSets",
        "ecs:UpdateTaskSet",
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DescribeInstanceHealth"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "snake_game" {
  family                = "snake_game"
  task_role_arn         = aws_iam_role.ecs_role.arn
  execution_role_arn    = aws_iam_role.ecs_role.arn
  network_mode          = "awsvpc"

  container_definitions = <<EOF
[
  {
    "name": "snake_game",
    "image": "${aws_ecr_repository.snake_game.repository_url}/snake_game:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "production"
      }
    ]
  }
]
...
EOF
}

resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "aws_ecs_service" "snake_game" {
  name            = "snake_game"
  task_definition = aws_ecs_task_definition.snake_game.arn
  cluster         = aws_ecs_cluster.main.id
  desired_count   = 1
  launch_type     = "FARGATE"
}

resource "aws_elbv2_load_balancer" "snake_game" {
  name            = "snake_game"
  internal        = false
  security_groups = [aws_security_group.snake_game.id]
  subnets         = aws_subnet.main.*.id
}

resource "aws_elbv2_target_group" "snake_game" {
  name                = "snake_game"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.main.id
  target_type         = "ip"
  health_check {
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_elbv2_listener" "http" {
  load_balancer_arn = aws_elbv2_load_balancer.snake_game.arn
  protocol         = "HTTP"
  port             = 80
  default_action {
    target_group_arn = aws_elbv2_target_group.snake_game.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "snake_game" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "snake-game.example.com"
  type    = "A"
  alias {
    name                   = aws_elbv2_load_balancer.snake_game.dns_name
    zone_id                = aws_elbv2_load_balancer.snake_game.zone_id
    evaluate_target_health = true
  }
}

