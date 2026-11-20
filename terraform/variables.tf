variable "aws_region" {
  type        = string
  default     = "ap-south-2"
  description = "AWS region for resources"
}

variable "microservices" {
  type = list(string)
  default = [
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice"
  ]
  description = "List of microservices for ECR"
}
