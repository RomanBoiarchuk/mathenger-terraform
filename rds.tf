resource "aws_db_subnet_group" "db-subnet-group" {
  subnet_ids = [aws_subnet.db-subnet-1.id, aws_subnet.db-subnet-2.id]
  name = "${var.app_name}-db-subnet-group"
  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

resource "aws_security_group" "db-security-group" {
  name = "${var.db_name}-security-group"
  vpc_id = aws_vpc.vpc.id
  description = "DB security group"
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.17"
  instance_class       = "db.t2.micro"
  identifier = "${var.app_name}-db"
  name                 = var.db_name
  username             = var.mysql_username
  password             = var.mysql_password
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.db-security-group.id]
  publicly_accessible = true
  skip_final_snapshot = true
}
