resource "aws_s3_bucket" "b" {
  bucket = "${var.s3_bucket_name}"

  tags = {
    Name        = "${var.s3_bucket_name}"
    Environment = "Dev"
  }
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

# Upload an object
resource "aws_s3_object" "object1" {

  bucket = aws_s3_bucket.b.id

  key    = "test-s3pull-script.sh"

  acl    = "private"  # or can be "public-read"

  source = "test-s3pull-script.sh"

  # etag = filemd5("test-s3pull-script.sh")

  depends_on = [
    local_file.test-s3pull-script
  ]

}

resource "aws_s3_object" "object2" {

  bucket = aws_s3_bucket.b.id

  key    = "test-s3pull-script2.sh"

  acl    = "private"  # or can be "public-read"

  source = "test-s3pull-script2.sh"

  # etag = filemd5("test-s3pull-script2.sh")

  depends_on = [
    local_file.test-s3pull-script2
  ]

}