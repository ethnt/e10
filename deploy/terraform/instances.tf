resource "aws_instance" "gateway" {
  ami                    = data.aws_ami.nixos_x86_64.id
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

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.nixos_arm64.id
  instance_type          = "t4g.small"
  vpc_security_group_ids = [aws_security_group.common.id, aws_security_group.gateway.id]
  key_name               = aws_key_pair.deploy_key.key_name
  subnet_id              = aws_subnet.public_subnet.id

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 64
    volume_type = "gp2"
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "monitor" {
  ami                    = data.aws_ami.nixos_x86_64.id
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
