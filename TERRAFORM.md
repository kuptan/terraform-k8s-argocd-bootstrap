## Requirements

| Name | Version |
|------|---------|
| kubernetes | >= 1.13.3 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | >= 1.13.3 |
| template | n/a |
| tls | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) |
| [aws_eks_cluster_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) |
| [kubernetes_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |
| [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) |
| [tls_self_signed_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd\_git\_repo\_url | The ArgoCD git config | `string` | n/a | yes |
| target\_cluster\_name | The cluster name where the ArgoCD will be installed | `string` | n/a | yes |
| argocd\_additional\_applications | Additional applications to be added to ArgoCD | `list(any)` | `[]` | no |
| argocd\_additional\_projects | Additional projeccts to be added to ArgoCD | `list(any)` | `[]` | no |
| argocd\_chart\_version | The ArgoCD chart version | `string` | `"3.7.1"` | no |
| argocd\_image\_tag | The image tag for the ArgoCD image | `string` | `"v2.0.4"` | no |
| managed\_clusters\_names | A list of clusters that will be managed by ArgoCD | `list(string)` | `[]` | no |
| namespace | The namespace name that will be created for argo and sealed secret | `string` | `"argo-system"` | no |
| namespace\_labels | labels to be added to the namespace | `map(string)` | `{}` | no |
| sealed\_secrets\_chart | The chart version and docker image version. | <pre>object({<br>    repository : string<br>    chart_version : string<br>    docker_image_tag : string<br>  })</pre> | <pre>{<br>  "chart_version": "1.16.1",<br>  "docker_image_tag": "v0.16.0",<br>  "repository": "https://bitnami-labs.github.io/sealed-secrets"<br>}</pre> | no |
| sealed\_secrets\_chart\_values | A list of values.yaml files to be added to the chart installation. | `list(string)` | `[]` | no |
| sealed\_secrets\_chart\_values\_overrides | A map of key/value to override the chart values. The key must be the path/name of the chart value, e.g: `path.to.chart.key` | `map(string)` | `{}` | no |
| sealed\_secrets\_key\_cert | The key/cert config for sealed secrets. If `auto_generate_key_cert` is false and no custom key/cert is provided, no custom key/cert will be generated | <pre>object({<br>    auto_generate_key_cert : bool,<br>    private_key : string<br>    private_cert : string<br>  })</pre> | <pre>{<br>  "auto_generate_key_cert": true,<br>  "private_cert": "",<br>  "private_key": ""<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| argocd\_git\_private\_key | n/a |
| argocd\_git\_public\_key | n/a |
| sealed\_secrets\_generated\_cert | n/a |
| sealed\_secrets\_generated\_private\_key | n/a |
