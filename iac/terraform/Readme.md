# Terraform
## ¿Cómo desplegar la infraestructura en AWS usando Terraform?

### Desplegar la infraestructura de red

- Ir a la carpeta networking usando 
    ```console
    cd terraform/networking
    ```
- Reemplazar los valores del archivo **backend.conf**:  
    **bucket** es el nombre del bucket donde guardarán el archivo de estado.  
    **key** es la ubicación dentro del bucket donde se guardará el archivo de estado. (No es necesario cambiarla)
    **region** es la región donde está el bucket  
    **profile** es el nombre del perfil del CLI de AWS. Se puede eliminar este parámetro en caso de solo tener una cuenta de AWS configurada.
- Inicializar la configuración de terraform usando el comando
    ```console
    terraform init -backend-config=backend.conf
    ```
- Visualizar los cambios que se van a aplicar usando el comando
    ```console
    terraform plan -var "owner=nombre"
    ```
    donde *nombre* puede ser tu nombre o un seudónimo. Esto se usará para identificar los recursos desplegados.
    En caso de usar varios perfiles de AWS CLI usar el mismo comando pero especificando el perfil como una variable de entorno
    ```console
    AWS_PROFILE=nombre-perfil terraform plan -var "owner=nombre"
    ```
    donde *nombre-perfil* es el nombre del perfil de AWS
- Aplicar los cambios usando el comando
    ```console
    terraform apply -var "owner=nombre"
    ```
    Al igual que en el caso anterior, si estás usando varios perfiles de AWS, indica el perfil como variable de entorno.
     ```console
    AWS_PROFILE=nombre-perfil terraform apply -var "owner=nombre"
    ```

### Desplegar la infraestructura de la aplicación

- Ir a la carpeta app usando 
    ```console
    cd terraform/app
    ```
- Reemplazar los valores del archivo **backend.conf**:  
    **bucket** es el nombre del bucket donde guardarán el archivo de estado.  
    **key** es la ubicación dentro del bucket donde se guardará el archivo de estado. (No es necesario cambiarla)
    **region** es la región donde está el bucket  
    **profile** es el nombre del perfil del CLI de AWS. Se puede eliminar este parámetro en caso de solo tener una cuenta de AWS configurada.
- Agregar un archivo que se llame **secrets.tfvars** donde se van a especificar las variables con valores sensibles.
    ```
    database_password           = "password123"
    public_key                  = "ssh-rsa..."
    tf_state_bucket_networking  = "nombre-bucket-tf-state-networking"
    ```
    **database_password** es la contraseña que escogerán para la base de datos  
    **public_key** es el contenido de la llave pública que se usará para contectarse a las instancias. Dicho contenido se puede conseguir abriendo el archivo con extensión *.pem* o *.pub*  
    **tf_state_bucket_networking** es el bucket donde guardan el estado del módulo de networking  
- Inicializar la configuración de terraform usando el comando
    ```console
    terraform init -backend-config=backend.conf
    ```
- Visualizar los cambios que se van a aplicar usando el comando
    ```console
    terraform plan -var "owner=nombre" -var-file=secrets.tfvars
    ```
    donde *nombre* puede ser tu nombre o un seudónimo. Esto se usará para identificar los recursos desplegados.  
    En caso de usar varios perfiles de AWS CLI usar el mismo comando pero especificando el perfil como una variable de entorno
    ```console
    AWS_PROFILE=nombre-perfil terraform plan -var "owner=nombre" -var-file=secrets.tfvars
    ```
    donde *nombre-perfil* es el nombre del perfil de AWS
- Aplicar los cambios usando el comando
    ```console
    terraform apply -var "owner=nombre" -var-file=secrets.tfvars
    ```
    Al igual que en el caso anterior, si estás usando varios perfiles de AWS, indica el perfil como variable de entorno.
     ```console
    AWS_PROFILE=nombre-perfil terraform apply -var "owner=nombre" -var-file=secrets.tfvars
    ```