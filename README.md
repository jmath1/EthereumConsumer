<h1>Ethereum Consumer<h1>

<h3>Overview</h3>
<p>
This project is experimental and it being developed using a cloud playground in ACloudGuru. It is not recommended to deploy this application without first understanding the associated costs. Along the way, I will be creating tools to estimate costs when deploying infrastructure, but for now it can become very expensive if you don't know what you are doing.
</p>

<h3>Set Up</h3>
Copy the .env.template file to a file called .env. Fill it out and source it before deploying the docker stack.
I made a Taskfile for this project to make things simple. Run task help to get descriptions of each command. First deploy the docker and persistence stacks. Then deploy the data stack and finally the service stack.

<h3>TO-DO</h3>
- [x] Create a Kinesis Data Stream to allow a script to send Ethereum data to a Kinesis data stream using Terraform
- [x] Create Python script to consume Ethereum data
- [x] Create a Docker implementation for the consumer script
- [ ] Create a Fargate implementation for the new Docker container using Terraform
