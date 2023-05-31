# Resource Block

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "${var.podname}-bucket"
  tags = {
    env = var.env
    bucketname  = "${var.podname}-bucket"
    owner   = var.podname
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketowner" {
  bucket = aws_s3_bucket.mys3bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucketowner]

  bucket = aws_s3_bucket.mys3bucket.id
  acl    = "private"
}

resource "local_file" "ansible_vars" {
  filename = "/home/ubuntu/artifacts/vars.yaml"
  file_permission = "0600"
  content = templatefile("./templates/vars.tpl",
    {
      podname = var.podname
      bucket = aws_s3_bucket.mys3bucket.id
    }
)
}
