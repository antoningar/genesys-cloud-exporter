# Genesys Cloud Custom Exporter
Ceci est un exemple d'implémentation d'un export planifié entierement customisable.  
À l'image des exports planifiés disponible nativement, cet exemple n'utilise aucune autre ressource que celles disponible sur Genesys Cloud.  
Les [Genesys function](https://developer.genesys.cloud/blog/2025-01-14-genesys-functions/) permettent de récupérer n'importe quelles données et de les formatter librement.  
Ici ce sont les datas actions en erreur, les déconnexions dues aux erreures de flow et les interactions de courte durées qui sont récupérées.  

![](docs/schedule-exporter.png)

## Function
1. install dependencies  
```npm install```
2. zip everything  
```zip a -r exporter.zip ./*```

## Terraform
Le dossier terraform contient la déclaration de tous les éléments necessaire pour le déploiement d'une telle solution.  
Seul l'oauth que va utiliser terraform et son rôle associé sont a créer manuellement.  

### OAUTH
Pour les déploiement terraform, l'oauth doit avoir un role avec à minima les permissions suivantes:  
`authorization:role:*`  
`oauth:client:*`  


L'id et le secret de cet oauth doivent être renseignés dans un fichier local suivant cette structure:  
`oauthclient_id = ""`  
`oauthclient_secret = ""`  
`aws_region = "eu-west-1"`  

Les commandes `plan` et `apply` devront être lancées avec l'option `var-file=local.tfvars`

### Process
1. Creer dans Genesys le role et l'oauth pour terraform
2. Dans le projet terraform, creer un fichier local.tfvars avec id et secret de l'oauth
3. Lancer le terraform apply, le traitement va etre interrompu par l'erreur `API Error: 400 - The user does not have access to some of the specified roles.`
4. Dans Genesys, assigner le role creer par terraform `Custom Exporter Function Role` d'abord a son propre compte, puis a l'oauth terraform
5. Relancer le terraform apply