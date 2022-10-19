# Backend block pointing to s3. Must provision s3 manually, due to limitation.
# TODO : inplement state locking with dynamoDB

# terraform {
#  backend "s3" {
#    bucket      = "exercisebucketdido"
#    key         = "terraform.state"
#    region      = "eu-west-3"
#  }
#}
