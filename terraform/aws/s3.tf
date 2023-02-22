resource "aws_s3_bucket" "data" {
  # bucket is public
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-data"
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-data"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "3f5b66d407a8fab9148c7ae9edc5a600d42f00b4"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2021-12-13 06:34:51"
    git_last_modified_by = "34870196+LironElbaz@users.noreply.github.com"
    git_modifiers        = "34870196+LironElbaz/nimrodkor"
    git_org              = "MilanGit12"
    git_repo             = "terragoat"
    yor_trace            = "0874007d-903a-4b4c-945f-c9c233e13243"
  })
}


resource "aws_s3_bucket_object" "data_object" {
  bucket = aws_s3_bucket.data.id
  key    = "customer-master.xlsx"
  source = "resources/customer-master.xlsx"
  tags = merge({
    Name        = "${local.resource_prefix.value}-customer-master"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_last_modified_by = "nimrodkor@gmail.com"
    git_modifiers        = "nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "a7f01cc7-63c2-41a8-8555-6665e5e39a64"
  })
}

resource "aws_s3_bucket" "financials" {
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  # checking to see if comments update yor tags in financials bucket
  bucket        = "${local.resource_prefix.value}-financials"
  acl           = "private"
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-financials"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "8882e2235449b1af570846f64e382caf838b2c6b"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2023-02-07 21:58:29"
    git_last_modified_by = "milpatel@paloaltonetworks.com"
    git_modifiers        = "milpatel/nimrodkor"
    git_org              = "MilanGit12"
    git_repo             = "terragoat"
    yor_trace            = "0e012640-b597-4e5d-9378-d4b584aea913"
  })

}


resource "aws_s3_bucket_versioning" "financials" {
  bucket = aws_s3_bucket.financials.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "operations" {
  # bucket is not encrypted
  # bucket does not have access logs
  # testing yor workflow change
  bucket = "${local.resource_prefix.value}-operations"
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-operations"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "N/A"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2023-02-22 20:20:29"
    git_last_modified_by = "milpatel@paloaltonetworks.com"
    git_modifiers        = "milpatel/nimrodkor"
    git_org              = "MilanGit12"
    git_repo             = "terragoat"
    yor_trace            = "29efcf7b-22a8-4bd6-8e14-1f55b3a2d743"
  })
}


resource "aws_s3_bucket_versioning" "operations" {
  bucket = aws_s3_bucket.operations.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = aws_s3_bucket.operations.id
  versioning_configuration {
    status = "Enabled"
  }
  tags = {
    yor_trace = "055c9fe1-c645-46c3-8a4b-a5823d6001b2"
  }
}

resource "aws_iam_role" "replication" {
  name               = "aws-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags = {
    yor_trace = "4b267e3a-651e-4ea8-8c8d-003107ac4a87"
  }
}

resource "aws_s3_bucket_replication_configuration" "operations" {
  depends_on = [aws_s3_bucket_versioning.operations]
  role       = aws_iam_role.operations.arn
  bucket     = aws_s3_bucket.operations.id
  rule {
    id     = "foobar"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}






resource "aws_s3_bucket" "operations_log_bucket" {
  bucket = "operations-log-bucket"
  tags = {
    git_commit           = "02be5d2dd3974084dc3ee6204c038deec5467ed5"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2023-02-08 19:10:42"
    git_last_modified_by = "milpatel@paloaltonetworks.com"
    git_modifiers        = "milpatel"
    git_org              = "MilanGit12"
    git_repo             = "terragoat"
    yor_trace            = "7ac724dc-625f-4720-a9c0-d1a99b1a7e3c"
  }
}

resource "aws_s3_bucket_logging" "operations" {
  bucket = aws_s3_bucket.operations.id

  target_bucket = aws_s3_bucket.operations_log_bucket.id
  target_prefix = "log/"
}






resource "aws_s3_bucket_server_side_encryption_configuration" "operations" {
  bucket = aws_s3_bucket.operations.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


resource "aws_s3_bucket" "data_science" {
  # bucket is not encrypted
  bucket = "${local.resource_prefix.value}-data-science"
  acl    = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "log/"
  }
  force_destroy = true
  tags = {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_last_modified_by = "nimrodkor@gmail.com"
    git_modifiers        = "nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "9a7c8788-5655-4708-bbc3-64ead9847f64"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.resource_prefix.value}-logs"
  acl    = "log-delivery-write"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "${aws_kms_key.logs_key.arn}"
      }
    }
  }
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-logs"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_last_modified_by = "nimrodkor@gmail.com"
    git_modifiers        = "nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "01946fe9-aae2-4c99-a975-e9b0d3a4696c"
  })
}
