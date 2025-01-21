# AIOWP (All In One WordPress Manager)

**AIOWP** es un script en Bash diseñado para gestionar múltiples instalaciones de WordPress en servidores Ubuntu utilizando NGINX, MariaDB y PHP 8.1. Proporciona una interfaz basada en `whiptail` para facilitar tareas como la creación de nuevos sitios, gestión de backups, configuraciones SSL, y más.

**AIOWP** is a Bash script designed to manage multiple WordPress installations on Ubuntu servers using NGINX, MariaDB, and PHP 8.1. It provides a `whiptail`-based interface to simplify tasks like creating new sites, managing backups, SSL configurations, and more.

---

## Características principales / Key Features

- **Creación de sitios WordPress**: Configuración automática de un nuevo sitio con base de datos, archivos y configuración NGINX.
- **Gestión de sitios existentes**: Permite habilitar, deshabilitar, reiniciar, eliminar sitios y configurar SSL con Let's Encrypt.
- **Backups y restauraciones**: Realiza backups manuales o automáticos, con opciones para restaurarlos fácilmente.
- **Instalación de dependencias**: Verifica e instala automáticamente los paquetes necesarios para WordPress.
- **Interfaz sencilla**: Utiliza `whiptail` para una experiencia amigable en terminal.

- **Create WordPress Sites**: Automatically sets up a new site with database, files, and NGINX configuration.
- **Manage Existing Sites**: Allows enabling, disabling, restarting, deleting sites, and setting up SSL with Let's Encrypt.
- **Backups and Restorations**: Perform manual or automatic backups with easy restoration options.
- **Dependency Installation**: Automatically verifies and installs the required packages for WordPress.
- **User-Friendly Interface**: Uses `whiptail` for a terminal-friendly experience.

---

## Requisitos / Requirements

### Software necesario / Required Software

- Ubuntu 20.04 o superior / Ubuntu 20.04 or later
- NGINX
- MariaDB
- PHP 8.1 y sus extensiones para WordPress / PHP 8.1 and its extensions for WordPress
- Certbot para SSL / Certbot for SSL

### Permisos / Permissions

El script debe ejecutarse como **root** o con `sudo`.  
The script must be run as **root** or with `sudo`.

---

## Instalación / Installation

1. Clona este repositorio en tu servidor:  
   Clone this repository on your server:
   ```bash
   git clone https://github.com/rodillo69/AIOWPM.git
   cd AIOWPM
   ```

2. Asegúrate de dar permisos de ejecución al script:  
   Make sure to grant execution permissions to the script:
   ```bash
   chmod +x aiowp.sh
   ```

3. Instala el script globalmente para llamarlo desde cualquier lugar sin usar `./`:  
   Install the script globally to call it from anywhere without using `./`:
   ```bash
   sudo cp aiowp.sh /usr/local/bin/aiowp
   ```

4. Ahora puedes ejecutar el script simplemente escribiendo:  
   You can now run the script simply by typing:
   ```bash
   sudo aiowp
   ```

---

## Uso / Usage

### Menú principal / Main Menu

Cuando ejecutas el script, se muestra un menú principal con las siguientes opciones:  
When you run the script, the main menu displays the following options:

1. **Agregar nuevo WordPress**: Crea un nuevo sitio WordPress configurando dominio, base de datos y configuración de NGINX.  
   **Add New WordPress**: Creates a new WordPress site by setting up the domain, database, and NGINX configuration.

2. **Administrar sitios existentes**: Lista los sitios configurados para habilitar, deshabilitar, reiniciar, configurar SSL o eliminar.  
   **Manage Existing Sites**: Lists configured sites for enabling, disabling, restarting, setting up SSL, or deleting.

3. **Instalar/Verificar dependencias**: Verifica e instala todos los paquetes necesarios.  
   **Install/Check Dependencies**: Verifies and installs all required packages.

4. **Mostrar créditos**: Muestra información sobre el desarrollador del script.  
   **Show Credits**: Displays information about the script developer.

5. **Salir**: Cierra el script.  
   **Exit**: Closes the script.
   

### Ejecución automática de backups / Automatic Backup Execution

Puedes programar backups automáticos utilizando la opción "Programar Backup Automático" en el menú de administración de sitios.  
You can schedule automatic backups using the "Schedule Automatic Backup" option in the site management menu.

También puedes ejecutar backups directamente desde la línea de comandos:  
You can also perform backups directly from the command line:

```bash
sudo aiowp --backup-auto <dominio> <ruta_de_destino>
```
```bash
sudo aiowp --backup-auto <domain> <destination_path>
```

---

## Funciones principales / Main Features

### Creación de un nuevo sitio / Creating a New Site

El script realiza las siguientes acciones:  
The script performs the following actions:

1. Configura el dominio ingresado.  
   Sets up the provided domain.
   
3. Descarga y descomprime WordPress.  
   Downloads and extracts WordPress.
   
4. Configura la base de datos con un nombre y contraseña generados o personalizados.  
   Configures the database with a generated or custom name and password.
   
5. Crea el archivo de configuración NGINX y lo habilita.  
   Creates and enables the NGINX configuration file.
   
6. Configura las claves de seguridad de WordPress automáticamente.  
   Automatically configures WordPress security keys.


### Gestión de sitios / Site Management

Dentro del menú de administración de un sitio específico, puedes:  
Within the management menu of a specific site, you can:

- Parar o habilitar un sitio.  
  Stop or enable a site.
  
- Reiniciar su configuración en NGINX.  
  Restart its configuration in NGINX.
  
- Configurar un certificado SSL con Let's Encrypt.  
  Set up an SSL certificate with Let's Encrypt.
  
- Eliminar el sitio completamente, incluyendo la base de datos y archivos.  
  Delete the site completely, including the database and files.


### Backups y restauraciones / Backups and Restorations

- **Backup manual**: Realiza un backup completo de los archivos y la base de datos.  
  **Manual Backup**: Performs a full backup of files and the database.
  
- **Programar backups automáticos**: Utiliza `cron` para programar backups diarios, semanales, mensuales o personalizados.  
  **Schedule Automatic Backups**: Uses `cron` to schedule daily, weekly, monthly, or custom backups.
  
- **Restauración**: Permite restaurar desde un archivo `.tar.gz` especificado.  
  **Restore**: Allows restoration from a specified `.tar.gz` file.
  
- **Eliminar programación de backups**: Borra la configuración de `cron` de un sitio específico.  
  **Delete Backup Schedule**: Removes the `cron` configuration for a specific site.

---

## Personalización / Customization

Puedes modificar el script para adaptarlo a tus necesidades específicas, como cambiar rutas o incluir nuevas funciones. Asegúrate de tener conocimientos básicos de Bash y administración de servidores para realizar cambios.  
You can modify the script to suit your specific needs, such as changing paths or adding new features. Make sure you have basic Bash and server administration knowledge to make changes.

---

## Créditos / Credits

**Desarrollado por/Developed by:** Rodillo Systems  

**Año / Year:** 2025  

**Todos los derechos reservados.** / **All rights reserved.**

---

## Licencia / License

Este proyecto es de código abierto y está bajo la licencia MIT. Puedes usarlo, modificarlo y redistribuirlo libremente. Revisa el archivo `LICENSE` para más detalles.  
This project is open-source and licensed under the MIT License. You can freely use, modify, and redistribute it. Check the `LICENSE` file for more details.

