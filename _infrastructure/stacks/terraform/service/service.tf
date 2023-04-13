
resource "aws_ecs_cluster" "eth_consumer" {
  name = "eth-consumer-cluster"
}


resource "aws_ecs_task_definition" "eth_consumer" {
  family                   = "eth-consumer-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.service_cpu
  memory                   = var.service_memory
  execution_role_arn       = aws_iam_role.eth_consumer.arn

  container_definitions = jsonencode([{
    name   = "eth-consumer"
    image  = "${data.terraform_remote_state.docker.outputs.ecr_uri}:latest"
    memory = 512
    portMappings = [
      {
        containerPort = 80
        protocol      = "tcp"
      }
    ]
    env = [
      {
        "name" : "ETHEREUM_NODE",
        "value" : "${data.terraform_remote_state.data.outputs.node_ip}"
      },
      {
        "name" : "CONSUMER_STREAM_NAME",
        "value" : "${data.terraform_remote_state.data.outputs.consumer_stream_name}"
      }
    ]

    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group._.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "eth-consumer-"
        "awslogs-stream-name"   = "eth-consumer-container"
      }
    }
  }])

}

resource "aws_iam_role" "eth_consumer" {
  name = "eth-consumer-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eth_consumer" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.eth_consumer.name
}

resource "aws_ecs_service" "eth_consumer" {
  name            = "eth-consumer-service"
  cluster         = aws_ecs_cluster.eth_consumer.id
  task_definition = aws_ecs_task_definition.eth_consumer.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private.*.id
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}


resource "aws_security_group" "ecs_tasks" {
  name_prefix = "eth-consumer-ecs-tasks"
  vpc_id      = aws_vpc._.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.eth_consumer.name}/${aws_ecs_service.eth_consumer.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_service_cpu" {
  name               = "ecs-service-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 50.0
  }
}