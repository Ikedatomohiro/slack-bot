resource "aws_instance" "ec2_dify" {
  ami             = "ami-0e2612a08262410c8"
  instance_type   = "t2.medium"
  key_name        = "test_ikeda"
  security_groups = [aws_security_group.dify_ikeda_sg.name]

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }

  user_data = <<EOF
  #!/bin/bash
  sudo growpart /dev/xvda 1
  sudo resize2fs /dev/xvda1
  EOF

  tags = {
    Name = "dify_ikeda"
  }
}

resource "aws_security_group" "dify_ikeda_sg" {
  name        = "dify_ikeda_security_group"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
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
}

output "dify_ikeda_arn" {
  value = aws_instance.ec2_dify.arn
}
