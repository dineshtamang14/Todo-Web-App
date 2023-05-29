# create a Null Resource and Provisioners
resource "null_resource" "jenkins-initialpass" {
  depends_on = [module.ec2-instance]

  # Connection Block for Provisioners to connect to EC2 Inst
  connection {
    type        = "ssh"
    host        = module.ec2-instance.public_ip
    user        = "ubuntu"
    password    = ""
    private_key = file("/home/dinesh/Desktop/aws-projects/application-server-key.pem")
  }


  provisioner "remote-exec" {
    inline = [
      "while ! nc -z localhost 80; do sleep 1; done;",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
      "exit 1"
    ]
    on_failure = continue # Specify the action to take on failure
  }
}
