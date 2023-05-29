module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name = "jenkins-server"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.jenkins-sg.id}"]

  hibernation = false
  key_name    = "application-server-key"
  user_data   = file("${path.module}/userdata/script.sh")

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 16
      tags = {
        Name = "root-ebs"
      }
    },
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
