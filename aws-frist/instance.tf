
provider "aws" {
    region = "us-west-1"  
    profile = "aws-provider"
}

resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
   public_key = file("${path.module}/id_rsa.pub")
}
output "keyname" {
    value = "${aws_key_pair.id_rsa.key_name}"
  
} 

resource "aws_instance" "My-first" {
  ami           = "ami-01f87c43e618bf8f0"
  instance_type = "t2.micro"
 tags = {
    Name = "my_first"
  }
}