resource "aws_lb" "this" {

  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-alb"
    }
  )
}

# Target group for the ALB
resource "aws_lb_target_group" "this" {

  name = "${var.project_name}-tg"

  port     = 80
  protocol = "HTTP"

  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {
    enabled = true

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-tg"
    }
  )
}

# Attaching the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "this" {

  target_group_arn = aws_lb_target_group.this.arn

  target_id = var.instance_id

  port = 80
}

# Http listener for the ALB
resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.this.arn
  }
}

