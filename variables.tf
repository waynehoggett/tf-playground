variable "tags" {
  type        = map(string)
  description = "Set of tags to apply to the resources"
  default = {
    "Workload name"         = "linuxtestvm"
    "Business criticality"  = "Low"
    "Operations commitment" = "Baseline only"
    "Operations team"       = "Central IT"
    "Environment"           = "Dev"
  }
}
