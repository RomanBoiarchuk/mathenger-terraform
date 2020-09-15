resource "aws_key_pair" "key-pair" {
  key_name = "${var.app_name}-key-pair"
  public_key = var.public_key
}
