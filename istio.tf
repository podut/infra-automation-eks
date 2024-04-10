resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  version    = "1.21.0"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = "istio-system"
  create_namespace = true
  depends_on = [ module.eks, module.vpc ]
}

resource "helm_release" "istio-base" {
  name       = "istio-base"
  chart      = "base"
  version    = "1.21.0"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = "istio-system"
  create_namespace = true
  depends_on = [ module.eks, module.vpc ]
}

resource "helm_release" "istio-ingress" {
  name       = "istio-ingress"
  chart      = "gateway"
  version    = "1.21.0"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = "istio-ingress"
  create_namespace = true
  depends_on = [ module.eks, module.vpc ]

  values = [ templatefile("istio-ingress-values.yaml.tftpl", {
    lb_security_group_id = aws_security_group.istio-gateway-lb.id
  }) ]
}

resource "aws_security_group" "istio-gateway-lb" {
    name = "istio-ingress"
    vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "lb-http" {
  security_group_id = aws_security_group.istio-gateway-lb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb-https" {
  security_group_id = aws_security_group.istio-gateway-lb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4" {
  security_group_id = aws_security_group.istio-gateway-lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv6" {
  security_group_id = aws_security_group.istio-gateway-lb.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" 
}