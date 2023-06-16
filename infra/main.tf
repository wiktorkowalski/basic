//terraform cloud
terraform {
  cloud {
    organization = "wiktor9196667"

    workspaces {
      name = "basic"
    }
  }
}

// aws
provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

// import existing aws route 53 zone
data "aws_route53_zone" "wiktorkowalski" {
  name = "wiktorkowalski.pl"
}

//aws amplify app
resource "aws_amplify_app" "basic" {
  name         = "basic"
  repository   = "https://github.com/wiktorkowalski/basic"
  access_token = "*"

  build_spec = file("build_spec.yml")
}

// aws amplify branch
resource "aws_amplify_branch" "master" {
  app_id      = aws_amplify_app.basic.id
  branch_name = "master"
}

// aws amplify domain
resource "aws_amplify_domain_association" "basic" {
  app_id      = aws_amplify_app.basic.id
  domain_name = "wiktorkowalski.pl"
  sub_domain {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = "basic"
  }
}

# resource "aws_route53_record" "basic_subdomain" {
#   zone_id = data.aws_route53_zone.wiktorkowalski.zone_id
#   name    = "basic.wiktorkowalski.pl"
#   type    = "CNAME"
#   ttl     = "300"
#   records =  [aws_amplify_domain_association.basic.domain_name]
# }
