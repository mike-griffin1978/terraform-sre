terraform {
  backend "s3" {
    bucket         = "onecloud-kube"
    key            = "pod1-kube.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
