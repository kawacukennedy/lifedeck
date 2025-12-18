terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lifedeck-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "lifedeck_db" {
  identifier             = "lifedeck-${var.environment}"
  engine                 = "postgres"
  engine_version         = "16.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_encrypted      = true
  username               = var.db_username
  password               = var.db_password
  db_name                = "lifedeck"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.lifedeck.name
  skip_final_snapshot    = true

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_db_subnet_group" "lifedeck" {
  name       = "lifedeck-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "lifedeck_redis" {
  cluster_id           = "lifedeck-${var.environment}"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.lifedeck.name

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_elasticache_subnet_group" "lifedeck" {
  name       = "lifedeck-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# ECS Cluster and Services
resource "aws_ecs_cluster" "lifedeck" {
  name = "lifedeck-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "lifedeck-backend-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "lifedeck-backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"

      environment = [
        { name = "DATABASE_URL", value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.lifedeck_db.endpoint}/${aws_db_instance.lifedeck_db.db_name}" },
        { name = "REDIS_HOST", value = aws_elasticache_cluster.lifedeck_redis.cache_nodes[0].address },
        { name = "REDIS_PORT", value = tostring(aws_elasticache_cluster.lifedeck_redis.port) },
        { name = "JWT_SECRET", value = var.jwt_secret },
        { name = "OPENAI_API_KEY", value = var.openai_api_key },
        { name = "PLAID_CLIENT_ID", value = var.plaid_client_id },
        { name = "PLAID_SECRET", value = var.plaid_secret },
        { name = "GOOGLE_CLIENT_ID", value = var.google_client_id },
        { name = "GOOGLE_CLIENT_SECRET", value = var.google_client_secret },
        { name = "STRIPE_SECRET_KEY", value = var.stripe_secret_key }
      ]

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:3000/v1/health || exit 1"]
        interval = 30
        timeout = 5
        retries = 3
      }
    }
  ])

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_ecs_service" "backend" {
  name            = "lifedeck-backend-${var.environment}"
  cluster         = aws_ecs_cluster.lifedeck.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "lifedeck-backend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.backend]

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# Application Load Balancer
resource "aws_lb" "backend" {
  name               = "lifedeck-backend-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "lifedeck-backend-${var.environment}"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/v1/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.backend.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# ECR Repository
resource "aws_ecr_repository" "backend" {
  name                 = "lifedeck/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/lifedeck-backend-${var.environment}"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# IAM Roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "lifedeck-ecs-execution-role-${var.environment}"

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

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "lifedeck-ecs-task-role-${var.environment}"

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

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# Security Groups
resource "aws_security_group" "alb" {
  name   = "lifedeck-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_security_group" "ecs" {
  name   = "lifedeck-ecs-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_security_group" "rds" {
  name   = "lifedeck-rds-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

resource "aws_security_group" "redis" {
  name   = "lifedeck-redis-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}

# ACM Certificate (placeholder - would need domain)
resource "aws_acm_certificate" "backend" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
    Project     = "LifeDeck"
  }
}