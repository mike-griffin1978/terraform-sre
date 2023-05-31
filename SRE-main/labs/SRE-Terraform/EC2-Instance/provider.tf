# Provider Block
provider "aws" {
  profile = "srelab" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
  region  = "us-east-1"
}

provider "local" {
  # Configuration options
}