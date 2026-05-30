data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "jenkins" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name        = var.key_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}


resource "aws_security_group" "controller" {
  name        = "${var.environment}-jenkins-controller-sg"
  description = "Security group for Jenkins controller"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Jenkins UI from my IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Agent inbound TCP if needed"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-jenkins-controller-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}

resource "aws_security_group" "agent" {
  name        = "${var.environment}-jenkins-agent-sg"
  description = "Security group for Jenkins agents"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Jenkins controller"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.controller.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-jenkins-agent-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}

resource "aws_iam_role" "jenkins_ec2_role" {
  name = "${var.environment}-jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-jenkins-ec2-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.environment}-jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}

resource "aws_instance" "controller" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.controller_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.controller.id]
  key_name                    = aws_key_pair.jenkins.key_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.environment}-jenkins-controller"
    Role        = "jenkins-controller"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}

resource "aws_instance" "agents" {
  count = var.agent_count

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.agent_instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.agent.id]
  key_name                    = aws_key_pair.jenkins.key_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = var.agent_associate_public_ip

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.environment}-jenkins-agent-${count.index + 1}"
    Role        = "jenkins-agent"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "digipipeline"
  }
}
