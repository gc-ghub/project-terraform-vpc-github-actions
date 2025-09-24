#ALB
resource "aws_lb" "alb" {
  name               = local.name_suffix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_id
  tags = local.tags
}

#Listeners
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#Target Group
resource "aws_lb_target_group" "tg" {
  name     = local.name_suffix
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}



#target group attachments
resource "aws_lb_target_group_attachment" "tga" {
    count = length(var.instace_id)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instace_id[count.index]
  port             = 80
}
