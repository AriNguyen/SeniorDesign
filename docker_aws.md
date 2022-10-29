# Using Docker Mrtrix image on AWS  

## Requirements
1. Install Docker
2. [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Create AWS account (use the free one) 
4. [Create AWS ECR private repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)

[Do configure on your console:](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
```console
aws configure
```

## 1. Pusing Docker Mrtrix image to AWS ECR  

Latest MRtrix3 Docker image : [link](https://hub.docker.com/r/mrtrix3/mrtrix3)

```console
docker pull mrtrix3/mrtrix3
```

[Running MRtrix3 using containers](https://mrtrix.readthedocs.io/en/dev/installation/using_containers.html)

[Pushing a Docker image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

```
docker images
```
![](misc_img/docker_images_cmd.png)


```console
docker tag 5902d5a6aa38 aws_account_id.dkr.ecr.region.amazonaws.com/my-repository:tag
```

```console
docker push aws_account_id.dkr.ecr.region.amazonaws.com/my-repository:tag
```

## 2. Using Amazon ECR images with Amazon ECS



## 3. 