data "aws_caller_identity" "current" {

}

# Creates the lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Runs the hello-world
module "lambda" {
  source  = "./lambda"
  name    = "hello-world"
  runtime = var.runtime
  role    = aws_iam_role.lambda_role.arn
}

# Creates the API
resource "aws_api_gateway_rest_api" "hello_api" {
  name = "Hello API"
}

# Creates the API endpoint
resource "aws_api_gateway_resource" "hello_api_res_hello" {
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
  parent_id   = aws_api_gateway_rest_api.hello_api.root_resource_id
  path_part   = "hello"
}

# Sets up the /GET HTTP method
module "api_method" {
  source      = "./api_method"
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
  resource_id = aws_api_gateway_resource.hello_api_res_hello.id
  method      = var.method
  path        = aws_api_gateway_resource.hello_api_res_hello.path
  lambda      = module.lambda.name
  region      = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id
}

# Deploys the API
resource "aws_api_gateway_deployment" "hello_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
  stage_name  = var.environment
  description = "Deploy methods: ${module.api_method.http_method}"
}

# Creates the VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Creates the security group with ingress and egress
resource "aws_security_group" "demo_security_group" {
  name = "demo_security_group"
  description = "Security group for Lambda to RDS"
  vpc_id = aws_vpc.demo_vpc.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["127.0.0.1/32"]
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates our 1st subnet in availability one ${aws_region}a
resource "aws_subnet" "demo_subnet1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
}

# Creates our 2nd subnet in availability one ${aws_region}b
resource "aws_subnet" "demo_subnet2" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
}

# Creates our 3rd subnet in availability one ${aws_region}b
resource "aws_subnet" "demo_subnet3" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"
}

# Creates a subnet group of all our subnets defined above
resource "aws_db_subnet_group" "demo_db_subnet" {
  name = "main"
  subnet_ids = [aws_subnet.demo_subnet1.id, aws_subnet.demo_subnet2.id, aws_subnet.demo_subnet3.id]
}

# Defining our RDS resource
resource "aws_db_instance" "LambdaMySQL" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  instance_class = "db.t2.micro"
  name = "ExambleLambdaMySQL"
  identifier = "mysql"
  username = var.dbusername
  password = var.dbpassword
  db_subnet_group_name = aws_db_subnet_group.demo_db_subnet.id
  vpc_security_group_ids = list(aws_security_group.demo_security_group.id)
  final_snapshot_identifier = "final-id-${random_id.final_snapshot.hex}"
}

# Attaching our role policies
resource "aws_iam_role_policy_attachment" "test-attach" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Random_id generator for our RDS final snapshot
resource "random_id" "final_snapshot" {
  byte_length = 8
}
