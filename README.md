# Lambda + API Gateway + RDS

This is an example project of an AWS Lambda, API Gateway, and RDS all configured with Terraform. We utilize an API endpoint to trigger our lambda function on a GET HTTP request, with the proper VPC and security group configured for the RDS should it be needed in the future.

## Lambda

The API Gateway creates a `/hello` endpoint with a GET method. We have a single handler for this method, defined by the function below:
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

Initialize the module plugins and our cloud provider by running `terraform init` from the root level.

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

**Command**: 
```
curl https://sgrn757d2d.execute-api.us-east-1.amazonaws.com/demo/hello
```

**Output**: 
```
{"statusCode":200,"headers":{"Content-Type":"text/html; charset=utf-8"},"body":"Hello world!"}
```

The main body of our response contains the `"Hello World"` we defined in our `hello-world.js` file.

## Optional Configuration
While this is just a demo project, we could easily add API Keys to our REST API resource to further increase security.


Our REST API resource:
```terraform
resource "aws_api_gateway_rest_api" "hello_api" {
  name = "Hello API"
}
```

To add an API key to this resource, we can specify API Key resources in our root `main.tf`, such as the following:

```terraform
resource "aws_api_gateway_api_key" "api_key" {
  name = var.key_name
  description = "Our API Key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = var.key_name
  description = "Usage plan for our API key"
  quota_settings { 
    limit = 
    period = 
  }
  throttle_settings {
    burst_limit = 
    rate_limit = 
  }
  api_stages {
    api_id = aws_api_gateway_rest_api.hello_api.id
    stage = aws_api_gateway_deployment.hello_api_deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "mykey" {
  key_id = aws_api_gateway_api_key.api_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
```

This will create an `aws_api_gateway_api_key` resource, a usage_plan defined by the resource `aws_api_gateway_usage_plan`, and finally attach those two items together for the API key using the resource `aws_api_gateway_usage_plan_key`.

We will have to define a `var.key_name` in our `variables.tf` to pass the key_name in properly to the resources.

## Throttling
The API key example above has additional options for rate limiting, defined by this block:
```terraform
quota_settings { # maximum number of requests with this API key over specified time interval
    limit = # max requests, such as 20
    period = # time period limit applies. Values are DAY, WEEK, or MONTH
  }
  throttle_settings { # request rate limit applied to this key
    burst_limit = # max rate limit time over seconds, such as 5
    rate_limit = # the steady state rate limit, such as 10
  }
```

Adding all of these resources will ensure an API key attached to your API Gateway, with the appropriate rate limiting in place so it doesn't get overwhelmed should that be an issue in the future.

## Final Thoughts
This project can be improved in more ways than I'm aware of at this moment. Please feel free to submit a PR to this repository if you see things that could be improved.

