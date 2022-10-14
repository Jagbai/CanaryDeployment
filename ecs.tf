resource "aws_ecr_repository" "worker" {
    name  = "worker"
}

resource "aws_ecs_cluster" "rscluster" {
  name = "rscluster"
}

resource "aws_ecs_task_definition" "rstaskdef" {
  family = "rubyservice"
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "rubyservice"
      image     = "rubyserver:latest"
      cpu       = 10
      memory    = 512
      essential = true
      environment =  [
        {
          name = "APPVERSION"
          value = "1.0.0"
        }
      ],
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "rsservice" {
  name            = "rsservice"
  cluster         = aws_ecs_cluster.rscluster.id
  deployment_controller {
    type = "EXTERNAL"
  }
  tags = [
    {
      Key = "StableService"
      Value = "Blue"
    }
  ]

}

resource "aws_ecs_task_set" "rsGreentask_set" {
  service         = aws_ecs_service.rsservice.id
  cluster         = aws_ecs_cluster.rscluster.id
  task_definition = aws_ecs_task_definition.rstaskdef.arn
  external_id = "Blue"

    scale {
    value = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.GreenTargetGroup.arn
    container_name   = "rubyservice"
    container_port   = 100
  }

  depends_on = [
    "rsservice",
    "GreenTargetGroup"
  ]
}

resource "aws_ecs_task_set" "rsGreentask_set" {
  service         = aws_ecs_service.rsservice.id
  cluster         = aws_ecs_cluster.rscluster.id
  task_definition = aws_ecs_task_definition.rstaskdef.arn
  external_id = "Green"

    scale {
    value = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.BlueTargetGroup.arn
    container_name   = "rubyservice"
    container_port   = 100
  }

    depends_on = [
    "rsservice",
    "BlueTargetGroup"
  ]
}