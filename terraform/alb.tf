resource "aws_alb" "assignment1_alb" {
  #count = length(var.subnet_cidr_blocks)
  name               = "app-alb"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.clo835_subnet[0].id, aws_subnet.clo835_subnet[1].id]
  load_balancer_type = "application"

}

resource "aws_alb_target_group" "p8081" {
  name        = "blue-color"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.clo835_vpc.id
  target_type = "instance"
}

resource "aws_alb_target_group_attachment" "target_one" {
  target_group_arn = aws_alb_target_group.p8081.arn
  target_id        = aws_instance.assignment_instance.id
  port             = 8081


}

resource "aws_alb_target_group" "p8082" {
  name        = "pink-color"
  port        = 8082
  target_type = "instance"
  vpc_id      = aws_vpc.clo835_vpc.id
  protocol    = "HTTP"

}
resource "aws_alb_target_group_attachment" "target_two" {
  target_group_arn = aws_alb_target_group.p8082.arn
  target_id        = aws_instance.assignment_instance.id
  port             = 8082


}
resource "aws_alb_target_group" "p8083" {
  name        = "lime-color"
  port        = 8083
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.clo835_vpc.id

}
resource "aws_alb_target_group_attachment" "target_three" {
  target_group_arn = aws_alb_target_group.p8083.arn
  target_id        = aws_instance.assignment_instance.id
  port             = 8083

}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP Traffic"
  vpc_id      = aws_vpc.clo835_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/*resource "aws_alb_listener" "app_alb_listener" {
  load_balancer_arn = aws_alb.assignment1_alb.arn
  port              = "80"
  default_action {
    target_group_arn = aws_alb_target_group.p8081.arn
    type             = "forward"
  }
  condition {
    path_pattern {
      values = ["/app2/*"]
    }

    values = [
      {
        target_group_arn = aws_alb_target_group.p8082.arn
        type             = "forward"
      },
      {
        path_pattern     = "/app3/*"
        target_group_arn = aws_alb_target_group.p8083.arn
        type             = "forward"
      }
    ]
  }
}
locals {
  rules = [
    {
      path_pattern     = ["/app2/*"],
      target_group_arn = aws_alb_target_group.p8082.arn,
      type             = "forward"
    },
    {
      path_pattern     = ["/app3/*"],
      target_group_arn = aws_alb_target_group.p8083.arn,
      type             = "forward"
    }
  ]
}*/

resource "aws_alb_listener" "app_alb_listener" {
  load_balancer_arn = aws_alb.assignment1_alb.arn
  port              = "80"
  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_alb_target_group.p8081.arn
        weight = 1
      }
      target_group {
        arn    = aws_alb_target_group.p8082.arn
        weight = 1
      }
      target_group {
        arn    = aws_alb_target_group.p8083.arn
        weight = 1
      }
      #target_group_arn = aws_alb_target_group.p8081.arn
      #type             = "forward"
      #priority         =1

    }
  }
}

# default_action {
#  target_group_arn = aws_alb_target_group.p8082.arn
# type             = "forward"
# priority         = 1
#}

#default_action {
#   target_group_arn = aws_alb_target_group.p8083.arn
#  type             = "forward"
# priority         = 1
#}
#}  


#resource "aws_alb_listener_rule" "app_alb_listener_rule" {
# count        = length(local.rules)
#listener_arn = aws_alb_listener.app_alb_listener.arn
#priority     = count.index + 1
#action {
#  type             = "forward"
#  target_group_arn = local.rules[count.index].target_group_arn
#}
#condition {
#  path_pattern {
#    values = local.rules[count.index].path_pattern
#  }
#}
#}



