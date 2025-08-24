############################################
# FinOps: Budgets, Tag Policy, Anomaly Monitor
# + sample tagged resource for guardrail checks
############################################

# --- Sample taggable resource (kept tiny) ---
resource "aws_s3_bucket" "reports" {
  bucket = "${var.name_prefix}-reports-${var.environment}"
  tags = {
    Name = "${var.name_prefix}-reports-${var.environment}"
    # default_tags adds: Project, Environment, Owner, CostCenter
  }
}

# --- AWS Budgets: monthly total budget (plan only) ---
resource "aws_budgets_budget" "monthly_total" {
  name         = "${var.name_prefix}-monthly-total"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "10000"
  limit_unit   = "USD"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold_type             = "PERCENTAGE"
    threshold                  = 80
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["finops-alerts@example.com"]
  }

  # Optional: uncomment to scope by tag
  # cost_filter {
  #   name   = "TagKeyValue"
  #   values = ["Project$${var.project}"]
  # }
}

# --- Cost Explorer Anomaly Detection: monitor by AWS Service ---
resource "aws_ce_anomaly_monitor" "services" {
  name              = "${var.name_prefix}-service-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

# --- Organizations Tag Policy to require core cost tags ---
resource "aws_organizations_policy" "tag_policy" {
  name        = "RequireCoreCostTags"
  description = "Require core FinOps tags on resources"
  type        = "TAG_POLICY"

  # Minimal, valid-looking tag policy content (dry run only)
  content = jsonencode({
    "tags" : {
      "Project" : { "tag_key" : { "@@assign" : "Project" } },
      "Environment" : { "tag_key" : { "@@assign" : "Environment" } },
      "Owner" : { "tag_key" : { "@@assign" : "Owner" } },
      "CostCenter" : { "tag_key" : { "@@assign" : "CostCenter" } }
    }
  })
}

resource "aws_organizations_policy_attachment" "tag_policy_attach" {
  policy_id = aws_organizations_policy.tag_policy.id
  target_id = var.org_target_id
}

# --- Outputs (handy in human-readable plan) ---
output "finops_summary" {
  value = {
    s3_reports_bucket = aws_s3_bucket.reports.bucket
    budget_name       = aws_budgets_budget.monthly_total.name
    anomaly_monitor   = aws_ce_anomaly_monitor.services.name
    tag_policy_name   = aws_organizations_policy.tag_policy.name
  }
}

