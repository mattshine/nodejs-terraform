# Lambda + API Gateway + RDS

This is an example project of an AWS Lambda, API Gateway, and RDS all configured with Terraform. We utilize an API endpoint to trigger our lambda function on a GET HTTP request, with the proper VPCs configured for the RDS should it be needed in the future.

## Lambda

The API Gateway creates a `/hello` endpoint with a GET method. We have a single handler for thsi method, defined by the function below:
```js
exports.handler = function (event, context, callback) {
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: 'Hello world!',
    };
    callback(null, response);
};
```

## Terraform
Our Terraform configuration utilizes two modules, a `lambda` module and an `api_method` module. Our terraform run will create the lambda function, a REST API with a single endpoint, a GET HTTP method on the API Gateway for accessibility, as well as a small RDS database.

## Using Terraform
To utilize this repository to create your environment, you'll need to have terraform installed already. Instructions can be found [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).

We can check the expected configuration of the terraform run by invoking `terraform plan`, and if we are satisfied with the result, by running `terraform apply`. You will be prompted for confirmation.

## Networking
This Terraform run will create subnets in the `a`, `b`, and `c` availability zones for the `aws_region` we have defined in our root `variables.tf` file, defaulting to `us-east-1`. 

## RDS
We have a small private MySQL RDS (Relational Database Service) configured in the same VPC as our lambda function, called `ExampleLambdaMySQL`. We have a security group assigned to this VPC that allows our MySQL database to connect across these subnets to our lambda function.

The username and password of our RDS database are declared in our `variables.tf` file, but are actually passed in a `terraform.tfvars` file. You will need to create this file and enter a username and password as desired in the following format:

```
dbusername = "username"
dbpassword = "randompassword1234"
```

**_Note_**: We are allowing a final snapshot of our RDS database. To avoid final snapshot naming conflicts, we're passing a `random_id` resource of `byte_length = 8` to the final_snapshot identifier, to keep them unique.

We are currently not utilizing the RDS, but it's available should you need it in the future.

## Accessing the API
When Terraform runs, our `output.tf` will output the API endpoint to the console from our `value = aws_api_gateway_deployment.hello_api_deployment.invoke_url` stated in there. You can hit this by running a `curl ${invoke_url}`, with an example below:

## Example

**Command**: `curl https://sgrn757d2d.execute-api.us-east-1.amazonaws.com/demo/hello`

**Output**: `{"statusCode":200,"headers":{"Content-Type":"text/html; charset=utf-8"},"body":"Hello world!"}`


