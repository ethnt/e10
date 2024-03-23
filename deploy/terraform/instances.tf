resource "aws_instance" "gateway" {
  ami                    = module.nixos_image.ami
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.gateway.id]
  key_name               = aws_key_pair.deploy_key.key_name
  subnet_id              = aws_subnet.public_subnet.id

  root_block_device {
    volume_size = 64
  }

  tags = {
    Name = "gateway"
  }
}

resource "aws_instance" "monitor" {
  ami                    = module.nixos_image.ami
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.monitor.id]
  key_name               = aws_key_pair.deploy_key.key_name
  subnet_id              = aws_subnet.public_subnet.id

  root_block_device {
    volume_size = 256
  }

  tags = {
    Name = "monitor"
  }
}
