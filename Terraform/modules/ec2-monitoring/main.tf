data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids     = [var.security_group_id]
  key_name                    = var.key_name
  iam_instance_profile       = var.iam_instance_profile
  associate_public_ip_address = true

  user_data = file("${path.root}/scripts/monitoring-user-data.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-monitoring"
    Role = "Monitoring"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"

  instance = aws_instance.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-monitoring-eip"
  }
}
