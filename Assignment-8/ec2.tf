resource "aws_instance" "ec2" {
  ami           = "ami-052064a798f08f0d3"  # Replace with your desired AMI
  instance_type = "t3.micro"
  
  tags = {
    Name = "tf-ec2-instance"
  }
}



# Private ec2
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  #availability_zone      = "${data.aws_region.current.name}a"
  availability_zone = "${data.aws_region.current.id}a"
  vpc_security_group_ids = [aws_security_group.ssh.id, ]
  key_name               = "keypairlinux"
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-ec2" })
  )
}

# Public ec2
resource "aws_instance" "public" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id, ]
  key_name               = "keypairlinux"
  availability_zone      = "${data.aws_region.current.id}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-ec2" })
  )
}