resource "aws_instance" "edash_rag" {
  ami                    = "ami-09006835f19e96fcb" # Amazon Linux 2023 AMI
  instance_type          = "t4g.medium"            # ARM instance type
  key_name               = "edash_rag_key"
  vpc_security_group_ids = [aws_security_group.edash_rag_sg.id]
  subnet_id              = aws_subnet.edash_rag_private_subnet.id

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

