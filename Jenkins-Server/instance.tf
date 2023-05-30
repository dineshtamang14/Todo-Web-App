module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name = "jenkins-server"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.jenkins-sg.id}"]

  hibernation = false
  key_name    = "application-server-key"
  user_data   = file("${path.module}/userdata/script.sh")

  iam_instance_profile = "Jenkins-Roles"
  # iam_role_path = "arn:aws:iam::120211568300:instance-profile/Jenkins-Roles"

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 16
    }
  ]

  tags = {
    Owner       = "Dinesh Tamang"
    Environment = "${local.env}"
  }

  depends_on = [data.aws_ami.ubuntu, aws_security_group.jenkins-sg]
}

output "ec2_ip" {
  value = module.ec2-instance.public_ip
}
