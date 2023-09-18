variable "region" {
    type = string
    default = "de/txl"
}

variable "cpu_family" {
    type = string
    default = "INTEL_SKYLAKE"
}



# Define an external data source to fetch the Prometheus values.yaml from GitHub
data "http" "prometheus_values" {
  url = "https://raw.githubusercontent.com/yourusername/your-repo/main/prometheus_values.yaml"
}

# Define an external data source to fetch the Blackbox Operator values.yaml from GitHub

