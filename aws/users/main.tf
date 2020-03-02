provider "aws" {
  version = "~> 2.43.0"
  region = "us-east-2"
}

# Creating access credentials for the user created in above step.
resource "aws_iam_access_key" "eksid" {
  user = "${aws_iam_user.eksuser.name}"
}

resource "aws_iam_user" "eksuser" {
  name = "eks"
}

# Creating policies for the user.
resource "aws_iam_policy" "eksuserpolicy" {
  name = "EKSUserPolicy"
  policy = "${file("eks-user-policy.json")}"
}

# Attaching the policies with the user.
resource "aws_iam_user_policy_attachment" "eksuserpolicyattachement" {
  user       = "${aws_iam_user.eksuser.name}"
  policy_arn = "${aws_iam_policy.eksuserpolicy.arn}"
}
