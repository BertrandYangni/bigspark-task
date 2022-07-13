#Creating users
resource "aws_iam_user" "newusers" {
  count = length(var.username)
  name  = element(var.username, count.index)
}

resource "aws_iam_user_policy_attachment" "ec2-user-administratoraccess" {
  count      = length(var.username)
  user       = element(aws_iam_user.newusers.*.name, count.index)
  #policy_arn = "${aws_iam_policy.ec2_readonly.arn}"
  policy_arn = aws_iam_policy.ec2_administratoraccess.arn
}


resource "aws_iam_policy_attachment" "admin-attach" {
  name = "admin-attach"
  groups = ["${aws_iam_group.user_admin.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_group" "user_admin" {
  name = "admin2"
}

module "enforce_mfa" {
  source  = "terraform-module/enforce-mfa/aws"

  policy_name                     = "managed-mfa-enforce"
  account_id                      = data.aws_caller_identity.current.id
  groups                          = [aws_iam_group.user_admin.name]
# manage_own_password_without_mfa = true
  manage_own_signing_certificates = true
  manage_own_ssh_public_keys      = true
  manage_own_git_credentials      = true
}
