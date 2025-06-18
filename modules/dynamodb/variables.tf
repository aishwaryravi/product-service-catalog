variable "tables" {
  description = "Map of table configurations per environment"
  type = map(object({
    billing_mode    = string
    read_capacity  = optional(number)
    write_capacity = optional(number)
  }))
}