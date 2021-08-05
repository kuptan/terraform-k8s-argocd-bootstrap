## Requirements

| Name | Version |
|------|---------|
| kubernetes | >= 1.18.0 |

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| kubernetes | >= 1.18.0 |
| random | n/a |
| tls | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) |
| [kubernetes_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) |
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) |
| [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_applications | Additional applications to be added to ArgoCD | `list(any)` | `[]` | no |
| additional\_chart\_value\_files | A list of values.yaml files to be added to the argo installation. | `list(string)` | `[]` | no |
| additional\_projects | Additional projeccts to be added to ArgoCD | `list(any)` | `[]` | no |
| chart\_values\_overrides | A map of key/value to override the argocdc chart values. The key must be the path/name of the chart value, e.g: `path.to.chart.key` | `map(string)` | `{}` | no |
| chart\_version | The ArgoCD chart version | `string` | `"3.7.1"` | no |
| create\_namespace | Indicates whether to create a Kubernetes namespace or not | `bool` | `true` | no |
| git\_repo\_url | The ArgoCD git config | `string` | `""` | no |
| git\_ssh\_auto\_generate\_keys | A flag to auto generate keys for git SSH | `bool` | `true` | no |
| git\_ssh\_private\_key | The keys config for argocd git repo | `string` | `""` | no |
| namespace | The namespace name that will be created for argo and sealed secret | `string` | `"argo-system"` | no |
| namespace\_labels | labels to be added to the namespace | `map(string)` | `{}` | no |
| private\_helm\_repositories | Private helm repositories to be added. The secret needs to have 'username' and 'password' | <pre>list(object({<br>    name : string<br>    url : string<br>    secret_name : string<br>  }))</pre> | `[]` | no |
| remote\_clusters | A list of remote clusters that will be managed by ArgoCD | <pre>list(object({<br>    name : string<br>    namespaces : list(string)<br>    host : string<br>    caData : string<br>    token : string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin\_password | n/a |
| git\_private\_key | n/a |
| git\_public\_key | n/a |
| namespace | n/a |
