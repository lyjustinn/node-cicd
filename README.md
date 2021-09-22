# node-cicd
Demo repository to use with a CI/CD pipeline created using Terraform. Contains basic unit tests as well as Terraform files to create pipeline infrastructure.

## Resources

The resources used by this pipeline are quite straight forward
1. EC2 instance to run Jenkins (this is running on t2.micro)
2. Elastic Beanstalk (this include an autoscaling group, load balancers, etc!)
3. Multiple S3 Buckets
4. 2 VPCs (one for Elastic Beanstalk one for Jenkins)
5. A codepipeline is used to trigger a deployment when we update the source artifact in S3

These resources should fit within free tier assuming you are not running the pipeline 24/7 (the EC2 instances used for Jenkins and the ASG will definitely reach the free tier limit if both are running concurrently for an entire month)

## Setup

Follow the steps below to try out the repo:
1. To start, you should fork and clone the repository on your own local, you should also create an AWS account [here](https://aws.amazon.com/free/?trk=ps_a134p000003yhNNAAY&trkCampaign=acq_paid_search_brand&sc_channel=ps&sc_campaign=acquisition_CA&sc_publisher=google&sc_category=core&sc_country=CA&sc_geo=NAMER&sc_outcome=Acquisition&sc_detail=aws%20sign%20up&sc_content=Signup_e&sc_matchtype=e&sc_segment=453053794449&sc_medium=ACQ-P|PS-GO|Brand|Desktop|SU|AWS|Core|CA|EN|Text&s_kwcid=AL!4422!3!453053794449!e!!g!!aws%20sign%20up&ef_id=CjwKCAjwhaaKBhBcEiwA8acsHITaYDvRGeMAHe9LYZwXZB4-8UeCFNB9AqeM81jV9kNydBMvt2CyIBoCfq8QAvD_BwE:G:s&s_kwcid=AL!4422!3!453053794449!e!!g!!aws%20sign%20up&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all "Create an AWS account!") if you don't have on already!
2. Next, download Terraform, HashiCorp has instructions [here](https://www.terraform.io/downloads.html "Download Terraform!")
3. Now you will need to setup your AWS credentials, I recommend using the AWS CLI and authenticate using a pair of IAM access keys. Otherwise you could follow the steps [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) and create a aws credentials file in your home directory
4. Using a code editor of your choice create a file called terraform.tfvars (or another name, which you can specify when you run Terraform!):
    1. Copy the below snippet and fill out the fields
       ```region = "region"
       ssh_ip = "your ssh ip ie. 0.0.0.0/0"
       elb_solution_stack = "your chosen solution stack"
       elb_az = "availability zone in your region"
       ```
5. CD into the terraform directory and run `terraform plan` and then `terraform apply` if you're happy with everything. Then grab the dns of the EC2 instance called "jenkins instance" 
6. You're going to want to create a GitHub app now
    1. Grant the app the follow repository permissions
       ```Commit Status: Read & write
       Checks: Read & write
       Contents: Read-only
       Metadata: Read-only
       Pull requests: Read-only
       ```
    2. Suscribe to these events: Check run, Check suite, Pull request, Push, Repository
    3. Pick a name of your choice
    4. Set the web hook url to `https://your-jenkins-dns-or-ip:8080/github-webhook/`
    5. Generate a private RSA key for your GitHub app.
        1. First run `openssl pkcs8 -topk8 -inform PEM -outform PEM -in key-in-your-downloads-folder.pem -out converted-github-app.pem -nocrypt`
        2. Then `openssl rsa -in converted-github-app.pem > key.pub`
        3. Finally `cat key.pub`
        4. The above will print out the RSA private key for you to use, make sure you replace the `BEGIN RSA PRIVATE KEY` with just `BEGIN PRIVATE KEY` and ditto for ending
7. Go to port 8080 on yor EC2 instance, make note of the location specified by Jenkins on the landing page
8. Finally you can SSH into your jenkins instance, sudo to the location and cat the access code file. Once you have the access code, you can configure Jenkins with your desired plugins and any other user secrets
9. Once your Jenkins is configured go to your credential store and create a new GitHub app credential. For ID, place the app name, for App ID place the App ID and for private key, place the key you got from earlier! I recommend you test the connection
10. You can configure a multi branch pipeline now to use with the Jenkinsfile included or use your own
