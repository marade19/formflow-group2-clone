resource "aws_launch_template" "this" {

  name = "${var.project_name}-launch-template"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = base64encode(
    templatefile("${path.module}/user_data.sh", {})
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-ec2"
      }
    )
  }
}