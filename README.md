# Genesys Cloud Custom Exporter

This is a sample of how to create a custom scheduled export.
As native scheduled export from workspace views, this sample is only using Genesys Cloud resources.
Using [Genesys function](https://developer.genesys.cloud/blog/2025-01-14-genesys-functions/) allow us to customize which datas we will extract and how.
On this sample data actions errors, flow errors and interactions with small durations are exported.

![](docs/schedule-exporter.png)

## Terraform

Terraform folder include almost all Genesys Cloud objects needed to run the sample.

### OAuth

Terraform Oauth has to be to be created manually.  
Associated role need at least this permissions :  
`authorization:role:*`  
`oauth:client:*`  
`integration:integration:*`  
`architect:flow:*`  
`architect:job:*`  
`architect:ui:view`  
`authorization:division:*`  
`authorization:grant:*`  
`outbound:contactList:*`  
`outbound:contact:*`  
`outbound:campaign:*`  
`outbound:responseSet:*`
`scripter:script:view`  
`scripter:publishedScript:view`  
`integrations:action:*`  
`outbound:ruleSet:add`  
`routing:wrapupCode:add:*` 
`telephony:plugin:all`  

L'id et le secret de cet oauth doivent être renseignés dans un fichier local suivant cette structure:  
`oauthclient_id = ""`  
`oauthclient_secret = ""`  
`aws_region = "eu-west-1"`  
`function_name = "exporter_function"`  
`mails = "wrong@mail.com,wrong2@mail.com"`  
`mailsedge_group_name = "Genesys Cloud Hybrid Media Group"`  

Les commandes `plan` et `apply` devront être lancées avec l'option `var-file=local.tfvars`

### Process

1. Creer dans Genesys le role et l'oauth pour terraform
2. Dans le projet terraform, creer un fichier local.tfvars avec id et secret de l'oauth
3. Lancer le terraform apply, le traitement va etre interrompu par l'erreur `API Error: 400 - The user does not have access to some of the specified roles.`
4. Dans Genesys, assigner le role creer par terraform `Custom Exporter Function Role` d'abord a son propre compte, puis a l'oauth terraform
5. Relancer le terraform apply
6. Recuperer le client id et secret du nouvel oauth, les ajouter dans les credentials de l'integration `exporter function integration` en y ajoutant les cles `gc_client_id` `gc_client_secret` et `gc_aws_region`
7. [Creer la function action](#function-action) (la creation n'est pas encore possible via Cx as Code).
8. [Create the campaign schedule](#campaign-schedule)

### Function action

<a name="function-action"></a>
Pour l'instant il n'est pas possible de creer une data actions via Cx as Code ni de l'importer, il faut donc tout faire a la main.  
Choisir l'integration `exporter function integration` et nommer l'action `exporter_function`.  
remplir les contracts:  

```json
{
  "input": {
    "inputSchema": {
      "type": "object",
      "properties": {
        "interval": {
          "type": "string"
        }
      }
    },
    "output": {
      "successSchema": {
        "type": "object",
        "properties": {
          "shortConversations": {
            "type": "object",
            "properties": {
              "conversations": {
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "total": {
                "type": "integer"
              }
            }
          },
          "flowErrors": {
            "type": "object",
            "properties": {
              "conversations": {
                "type": "array",
                "items": {
                  "type": "string"
                }
              },
              "total": {
                "type": "integer"
              }
            }
          },
          "dataActionErrors": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "actionId": {
                  "type": "string"
                },
                "responseStatus": {
                  "type": "string"
                },
                "errorType": {
                  "type": "string"
                },
                "count": {
                  "type": "integer"
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Campaign Schedule

<a name="campaign-schedule"></a>
As Genesys function, outbound campaign can't be scheduled thanks to terraform. To do it manually, go to the schedule tab of campaign management.  
Select Resource Type: voice campaign, Voice Campaign: Exporter Campaign, then set start date and reccurence pattern as you want to.  
For example:  
![](docs/campaign-schedule.PNG)

#### Configuration
Headers :  
`gc_aws_region = $!{credentials.gc_aws_region}`  
`gc_client_id = $!{credentials.gc_client_id}`  
`gc_client_secret = $!{credentials.gc_client_secret}`  
   
#### Genesys Function
Handler : main.handler  
Runtime : nodejs22.x  
import [zip](./function/function_exporter.zip)


## Build Genesys Function

1. install dependencies  
   `npm install`
2. zip everything  
   windows: `zip a -r function_exporter.zip ./*`  
   linux: `zip -r function_exporter.zip *`