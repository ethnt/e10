resource "aws_instance" "bastion" {
  ami                    = var.aws_ami_nixos_arm64
  instance_type          = "t4g.small"
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.bastion.id]
  key_name               = aws_key_pair.deploy_key.key_name
  subnet_id              = aws_subnet.public_subnet.id

  root_block_device {
    volume_size           = 64
    volume_type           = "gp2"
    delete_on_termination = false
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "monitor" {
  ami                    = var.aws_ami_nixos_arm64
  instance_type          = "t4g.medium"
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.monitor.id]
  key_name               = aws_key_pair.deploy_key.key_name
  subnet_id              = aws_subnet.public_subnet.id

  root_block_device {
    volume_size           = 256
    volume_type           = "gp2"
    delete_on_termination = false
  }

  tags = {
    Name = "monitor"
  }
}
