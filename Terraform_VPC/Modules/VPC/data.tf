data "aws_availability_zones" "available" {
  state = "available" # Optional: filters for only "available" AZs
}

