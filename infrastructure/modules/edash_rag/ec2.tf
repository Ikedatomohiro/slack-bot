resource "aws_instance" "edash_rag" {
  ami             = "ami-09006835f19e96fcb" # Amazon Linux 2023 AMI
  instance_type   = "t4g.medium" # ARM instance type
  key_name        = "edash_rag_key"
  security_groups = [aws_security_group.edash_rag_sg.name]

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
    Name = "edash-rag"
  }
}

resource "aws_security_group" "edash_rag_sg" {
  name        = "edash_rag_security_group"
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
