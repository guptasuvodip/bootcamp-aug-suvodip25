data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {

    name   = "image-id"
    values = ["ami-052064a798f08f0d3"]

  }
  owners = ["amazon"]

}

data "aws_region" "current" {

}