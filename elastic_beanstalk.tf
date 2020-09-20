locals {
  backend_environment_variables = {
    SERVER_PORT = 5000
    SERVER_SERVLET_CONTEXT_PATH = "/api"
    SPRING_DATASOURCE_URL = "jdbc:mysql://${aws_db_instance.db.endpoint}/${var.db_name}"
    SPRING_DATASOURCE_USERNAME = aws_db_instance.db.username
    SPRING_DATASOURCE_PASSWORD = aws_db_instance.db.password
    SPRING_MAIL_USERNAME = var.spring_mail_username
    SPRING_MAIL_PASSWORD = var.spring_mail_password
  }
}

##############################
#Elastic Beanstalk Environment
##############################

resource "aws_elastic_beanstalk_environment" "mathenger-env" {
  application = aws_elastic_beanstalk_application.mathenger-app.name
  name = "${var.app_name}-env"
  solution_stack_name = "64bit Amazon Linux 2 v3.1.1 running Corretto 11"
  version_label = aws_elastic_beanstalk_application_version.beanstalk-app-version.name

  dynamic "setting" {
    for_each = local.backend_environment_variables
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name = setting.key
      value = setting.value
    }
  }

  setting {
    name = "VPCId"
    namespace = "aws:ec2:vpc"
    value = aws_vpc.vpc.id
  }

  setting {
    name = "AssociatePublicIpAddress"
    namespace = "aws:ec2:vpc"
    value = true
  }

  setting {
    name = "Subnets"
    namespace = "aws:ec2:vpc"
    value = "${aws_subnet.beanstalk-subnet-1.id},${aws_subnet.beanstalk-subnet-2.id}"
  }

  setting {
    name = "ELBSubnets"
    namespace = "aws:ec2:vpc"
    value = "${aws_subnet.beanstalk-subnet-1.id},${aws_subnet.beanstalk-subnet-2.id}"
  }

  setting {
    name = "MinSize"
    namespace = "aws:autoscaling:asg"
    value = "1"
  }

  setting {
    name = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value = "1"
  }

  setting {
    name = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value = aws_key_pair.key-pair.key_name
  }

  setting {
    name = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    name = "StreamLogs"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value = true
  }

  setting {
    name = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    value = "application"
  }

  setting {
    name = "ServiceRole"
    namespace = "aws:elasticbeanstalk:environment"
    value = "aws-elasticbeanstalk-service-role"
  }

  setting {
    name = "Application Healthcheck URL"
    namespace = "aws:elasticbeanstalk:application"
    value = "/api/actuator/health"
  }

  setting {
    name = "HealthCheckPath"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value = "/api/actuator/health"
  }

}

resource "aws_elastic_beanstalk_application" "mathenger-app" {
  name = var.app_name
}

####################
#Application Version
####################

resource "aws_s3_bucket" "mathenger-app-s3" {
  bucket = "${var.app_name}-app-bucket"
}

resource "aws_s3_bucket_object" "jar-file" {
  bucket = aws_s3_bucket.mathenger-app-s3.id
  key = "beanstalk/mathenger-api-1.1.0.jar"
  source = var.path_to_jar
}

resource "aws_elastic_beanstalk_application_version" "beanstalk-app-version" {
  application = aws_elastic_beanstalk_application.mathenger-app.name
  bucket = aws_s3_bucket.mathenger-app-s3.id
  key = aws_s3_bucket_object.jar-file.id
  name = "${var.app_name}-app-version"
}

