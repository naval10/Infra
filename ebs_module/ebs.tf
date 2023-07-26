variable "private_id" {
 type = list(string)
}

variable "vpc_id" {}

variable "sg_id" {}

variable "public_id" {
 type = list(string)
}

resource "aws_elastic_beanstalk_application" "tftest" {
  name        = "tf-test-name"
  description = "tf-test-desc"
}

resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v5.8.3 running Node.js 18"
  tier                = "WebServer"
  
  setting {
   namespace = "aws:elasticbeanstalk:environment"
   name      = "ServiceRole"
   value     = "arn:aws:iam::490662223625:role/service-role/aws-elasticbeanstalk-service-role"
  }

  setting {
   namespace = "aws:elasticbeanstalk:environment"
   name      = "EnvironmentType"
   value     = "LoadBalanced"
  }

  setting {
   namespace = "aws:elasticbeanstalk:environment"
   name      = "LoadBalancerType"
   value     = "application"
  }

  setting {
   namespace = "aws:autoscaling:launchconfiguration"
   name      = "IamInstanceProfile"
   value     = "instance-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
   namespace = "aws:ec2:vpc"
   name      = "VPCId"
   value     = var.vpc_id
  }
  setting {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = "${join(",", var.public_id)}"
  }
  
  setting {
      namespace = "aws:ec2:vpc"
      name      = "DBSubnets"
      value     = "${join(",", var.private_id)}"
  }
  
  setting {
     namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = "${join(",", var.public_id)}"
  }
   
   setting {
     namespace = "aws:autoscaling:asg"
     name = "MinSize"
     value = "2"
   }

    setting {
     namespace = "aws:autoscaling:asg"
     name = "MaxSize"
     value = "4"
   }
   
   setting {
     namespace = "aws:autoscaling:launchconfiguration"
     name  = "EC2KeyName"
     value = "Web_key"
   }

   setting {
     namespace = "aws:autoscaling:trigger"
     name  = "MeasureName"
     value = "CPUUtilization"
   }

   setting {
     namespace = "aws:autoscaling:trigger"
     name  = "Period"
     value = "10"
   }

   setting {
     namespace = "aws:ec2:vpc"
     name  = "AssociatePublicIpAddress"
     value = "true"
   }

   setting {
     namespace = "aws:ec2:vpc"
     name  = "ELBScheme"
     value = "public"
   }

   setting {
     namespace = "aws:elasticbeanstalk:healthreporting:system"
     name      = "SystemType"
     value     = "enhanced"
   }

    setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
  
    setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteonTerminate"
    value     = "true"
  }
   
   setting {
     namespace = "aws:elasticbeanstalk:cloudwatch:logs:Health"
     name      = "HealthStreamingEnabled"
     value     = "true"
   }

   setting {
     namespace = "aws:elasticbeanstalk:cloudwatch:logs:Health"
     name      = "DeleteOnTerminate"
     value     = "true"
   }
   
   setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }

   setting {
     namespace = "aws:rds:dbinstance"
     name = "DBAllocatedStorage"
     value = "10"
   }

   setting {
     namespace = "aws:rds:dbinstance"
     name = "DBEngine"
     value = "mysql"
   }

   setting {
     namespace = "aws:rds:dbinstance"
     name = "DBInstanceClass"
     value = "db.t2.micro"
   }
   
   setting {
     namespace = "aws:rds:dbinstance"
     name = "DBUser"
     value = "admin"
   }

   setting {
     namespace = "aws:rds:dbinstance"
     name = "DBPassword"
     value = "foobarbaz"
   }

   setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBEngineVersion"
    value     = "5.7.37"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBDeletionPolicy"
    value     = "Delete"
  }

  setting {
    namespace = "aws:rds:dbinstance"
    name      = "HasCoupledDatabase"
    value     = "true"
  }
}

output "elb_dns_name" {
  value = "${aws_elastic_beanstalk_environment.tfenvtest.cname}"
}
