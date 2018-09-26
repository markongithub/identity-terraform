variable "env_name" {
    description = "Envrionment name"
}
variable "source_bucket_name" {
    description = "S3 Bucket Name where Lambda code package is stored"
}
variable "source_key" {
    description = "Path and filename for Lambda code in S3 bucket"
}
variable "lambda_name" {
    description = "Lambda function name"
}
variable "lambda_handler" {
    description = "Lambda handler function name"
}
variable "lambda_description" {
    description = "Description of Lambda function"
}
variable "lambda_runtime" {
    description = "Lambda runtime"
}
variable "lambda_memory" {
    description = "Amount of RAM for Lambda function"
}
variable "lambda_timeout" {
    description = "Lambda timeout setting"
}
variable "lambda_role_arn" {
    description = "Lamba execution role arn"
}
variable "source_code_hash" {
    description = "Hash value for Lambda code package"
}