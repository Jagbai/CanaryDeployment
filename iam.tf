resource "aws_iam_user" "jagbaiadmin" {
  name = "jagbaiadmin"
  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_user_policy" "adminpolicy" {
  name = "admin"
  user = aws_iam_user.jagbaiadmin.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}