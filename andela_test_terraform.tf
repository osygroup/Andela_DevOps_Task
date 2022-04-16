provider "aws" {
  region  = "eu-west-2"
}

data "aws_availability_zones" "available" {
		  state = "available"
		}

resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}


resource "aws_subnet" "PublicSubnet1" {
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Public Subnet AZ A"
  }
}


resource "aws_subnet" "PublicSubnet2" {
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Public Subnet AZ B"
  }
}


resource "aws_subnet" "PublicSubnet3" {
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Public Subnet AZ C"
  }
}


resource "aws_subnet" "PrivateSubnet1" {
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Private Subnet AZ A"
  }
}


resource "aws_subnet" "PrivateSubnet2" {
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private Subnet AZ B"
  }
}


resource "aws_subnet" "PrivateSubnet3" {
  cidr_block = "10.0.12.0/24"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.VPC.id
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Private Subnet AZ C"
  }
}

resource "aws_route_table" "RouteTablePublic" {
  vpc_id = aws_vpc.VPC.id
  depends_on = [ aws_internet_gateway.Igw ]

  tags = {
    Name = "Public Route Table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePublic0" {
  subnet_id = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

resource "aws_route_table_association" "AssociationForRouteTablePublic1" {
  subnet_id = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

resource "aws_route_table_association" "AssociationForRouteTablePublic2" {
  subnet_id = aws_subnet.PublicSubnet3.id
  route_table_id = aws_route_table.RouteTablePublic.id
}


resource "aws_route_table" "RouteTablePrivate1" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Private Route Table A"
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate10" {
  subnet_id = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.RouteTablePrivate1.id
}


resource "aws_route_table" "RouteTablePrivate2" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Private Route Table B"
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate20" {
  subnet_id = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.RouteTablePrivate2.id
}


resource "aws_route_table" "RouteTablePrivate3" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Private Route Table C"
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate30" {
  subnet_id = aws_subnet.PrivateSubnet3.id
  route_table_id = aws_route_table.RouteTablePrivate3.id
}


resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id
}


resource "aws_security_group" "SecurityGroup1" {
  name = "NginxSecurityGroup"
  description = "Build a custom security group."
  vpc_id = aws_vpc.VPC.id
}


resource "aws_security_group" "SecurityGroup2" {
  name = "NodejsSecurityGroup"
  description = "Build a custom security group."
  vpc_id = aws_vpc.VPC.id
}


resource "aws_s3_bucket" "FinanceS3Bucket" {

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = "aws/s3"
      }
    }
  }
}


resource "aws_s3_bucket_public_access_block" "blockPublicAccess" {
  bucket = aws_s3_bucket.S3Bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "nginx_asg" {
  availability_zones = ["eu-west-2a","eu-west-2b","eu-west-2c"]
  desired_capacity   = 3
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}


resource "aws_autoscaling_group" "nodejs_asg" {
  availability_zones = ["eu-west-2a","eu-west-2b","eu-west-2c"]
  desired_capacity   = 3
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}


resource "aws_lb_target_group" "ApplicationLoadBalancerTargetGroup1" {
  name = "Nginx_TG"
  target_type = "instance"
  vpc_id = aws_vpc.VPC.id
  protocol = "HTTP"
  protocol_version = "HTTP2"
  port = 80

  health_check {
    enabled = true
    path = "/"
    interval = 30
    protocol = "HTTP"
    port = 80
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "ApplicationLoadBalancerTargetGroup1Target1" {
  target_group_arn = aws_lb_target_group.ApplicationLoadBalancerTargetGroup1.arn
  target_id = "aws_autoscaling_group.nginx_asg.id"
  port = 80
}

resource "aws_lb" "ApplicationLoadBalancer" {
  name = "Nginx_LB"
  load_balancer_type = "application"
  internal = false
  ip_address_type = "ipv4"
  security_groups = aws_security_group.SecurityGroup1.name
  subnets = ["aws_subnet.PublicSubnet1.id","aws_subnet.PublicSubnet2.id","aws_subnet.PublicSubnet3.id"]
  enable_deletion_protection = false
  idle_timeout = 60
  desync_mitigation_mode = "defensive"
  drop_invalid_header_fields = false
  enable_http2 = true
  enable_waf_fail_open = false
}

resource "aws_lb_listener" "ApplicationLoadBalancerListener2" {
  load_balancer_arn = aws_lb.ApplicationLoadBalancer.arn
  protocol = "HTTP"
  port = 80

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = ""
      }
    }
  }
}


resource "aws_lb_target_group" "ApplicationLoadBalancerTargetGroup1" {
  name = "Nodejs_TG"
  target_type = "instance"
  vpc_id = "aws_vpc.VPC.id"
  protocol = "HTTP"
  protocol_version = "HTTP2"
  port = 80

  health_check {
    enabled = true
    path = "/"
    interval = 30
    protocol = "HTTP"
    port = 80
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "ApplicationLoadBalancerTargetGroup1Target1" {
  target_group_arn = aws_lb_target_group.ApplicationLoadBalancerTargetGroup1.arn
  target_id = "aws_autoscaling_group.nodejs_asg.id"
  port = 80
}

resource "aws_lb" "ApplicationLoadBalancer" {
  name = "Nginx_LB"
  load_balancer_type = "application"
  internal = true
  ip_address_type = "ipv4"
  security_groups = ["aws_security_group.SecurityGroup2.name"]
  subnets = ["aws_subnet.PrivateSubnet1.id","aws_subnet.PrivateSubnet2.id","aws_subnet.PrivateSubnet3.id"]
  enable_deletion_protection = false
  idle_timeout = 60
  desync_mitigation_mode = "defensive"
  drop_invalid_header_fields = false
  enable_http2 = true
  enable_waf_fail_open = false
}

resource "aws_lb_listener" "ApplicationLoadBalancerListener2" {
  load_balancer_arn = aws_lb.ApplicationLoadBalancer.arn
  protocol = "HTTP"
  port = 80

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = ""
      }
    }
  }
}


resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mongodb-docdb-cluster"
  engine                  = "docdb"
  master_username         = "samuel"
  master_password         = "mustbeeightchars"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}
