resource "helm_release" "gatekeeper" {
  name                 = "openpolicyagent"
  namespace            = "openpolicyagent"
  repository           = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart                = "gatekeeper"
  version              = "3.15.0"
  create_namespace     = true
  depends_on           = [ module.eks, module.vpc ]
}