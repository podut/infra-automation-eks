locals {
  aws_k8s_role_mapping = [{
      rolearn = aws_iam_role.external-admin.arn
      username = "admin"
      groups = ["none"]
    },
    {
      rolearn = aws_iam_role.external-developer.arn
      username = "developer"
      groups = ["none"]
    }
  ]
}

resource "aws_iam_role" "external-admin" {
  name = "external-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.user_for_admin_role
        }
      }
    ]
  })

  inline_policy {
    name = "external-admin-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {       
          Action   = ["eks:DescribeCluster"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "external-developer" {
  name = "external-developer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.user_for_dev_role
        }
      }
    ]
  })

  inline_policy {
    name = "external-developer-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:DescribeCluster"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

# role to access AWS secrets manager
resource "aws_iam_role" "externalsecrets-role" {
  name = "externalsecrets_sa_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Sid    = ""
        // all services within EKS can assume this role
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
      },
    ]
  })

  inline_policy {
    name = "externalsecrets_sa_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
	        // Read access to all secrets in the secrets manager
          Effect   = "Allow"
          Resource = "*"
          Action   = [
	          "secretsmanager:GetRandomPassword",
						"secretsmanager:GetResourcePolicy",
					  "secretsmanager:GetSecretValue",
					  "secretsmanager:DescribeSecret",
					  "secretsmanager:ListSecretVersionIds",
					  "secretsmanager:ListSecrets",
					  "secretsmanager:BatchGetSecretValue"
	        ]
        },
      ]
    })
  }
}