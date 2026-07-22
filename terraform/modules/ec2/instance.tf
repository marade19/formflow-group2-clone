resource "aws_instance" "this" {

  subnet_id = var.subnet_id

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ec2"
    }
  )
}