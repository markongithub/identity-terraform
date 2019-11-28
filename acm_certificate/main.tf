# -- Variables --

variable "domain_name" {
  description = "The primary name used on the issued TLS certificate"
}

variable "enabled" {
  default     = 1
  description = "Like count, but for the whole module. 1 for True, 0 for False."
}

variable "subject_alternative_names" {
  default     = []
  description = "A list of additional names to add to the certificate"
}

variable "validation_zone_id" {
  description = "Zone ID used to create the validation CNAMEs"
}

variable "validation_cname_ttl" {
  default = 300
}

# -- Outputs --

output "cert_arn" {
  description = "ARN of the issued ACM certificate"
  value       = element(concat(aws_acm_certificate.main.*.arn, [""]), 0)
}

output "finished_id" {
  description = "Reference this output in order to depend on validation being complete."
  value       = element(concat(aws_acm_certificate_validation.main.*.id, [""]), 0)
}

# -- Resources --

# Create the certificate with the specified SubjectAltNames
resource "aws_acm_certificate" "main" {
  count = var.enabled

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true

    # TODO: this is a workaround for an AWS API / Terraform AWS provider bug
    # https://github.com/terraform-providers/terraform-provider-aws/issues/8531
    # https://github.com/18F/identity-devops/issues/1469
    ignore_changes = [subject_alternative_names]
  }
}

# Create each validation CNAME
resource "aws_route53_record" "validation-cnames" {
  count   = length(var.subject_alternative_names) + 1 * var.enabled
  name    = aws_acm_certificate.main.0.domain_validation_options[count.index]["resource_record_name"]
  type    = aws_acm_certificate.main.0.domain_validation_options[count.index]["resource_record_type"]
  zone_id = var.validation_zone_id
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [aws_acm_certificate.main.0.domain_validation_options[count.index]["resource_record_value"]]
  ttl     = var.validation_cname_ttl
}

# Synthetic Terraform resource that blocks on validation completion
# You can depend_on this to wait for the ACM cert to be ready.
resource "aws_acm_certificate_validation" "main" {
  count = var.enabled

  certificate_arn = aws_acm_certificate.main[0].arn

  validation_record_fqdns = aws_route53_record.validation-cnames.*.fqdn
}

