#!/usr/bin/env bash
# --------------------------------------------------
# Script: AIOWP (All In One Wordpress Manager)
# Descripcion: Script con whiptail para gestionar
#              multiples instalaciones de Wordpress con
#              NGINX en Ubuntu (usando MariaDB y PHP 8.1),
#              realizando backups/restauraciones, 
#              programando backups, aplicando politicas de
#              retencion configurables y soportando ingles y espanol.
#
#              Desarrollado por Miguel Canadas Chico
#              Web: miguelcanadas.com
#              GitHub: https://github.com/rodillo69
#              Linkedin: https://www.linkedin.com/in/miguel-canadas-chico/
#              Todos los derechos reservados © 2025
# --------------------------------------------------

# ======================================================
# Seleccion del idioma
# ======================================================
seleccionar_idioma() {
    LANG=$(whiptail --title "Select Language / Seleccione Idioma" --menu "Choose your language:" 15 60 2 \
             "en" "English" \
             "es" "Espanol" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$LANG" ]; then
        LANG="es"
    fi
}

# ======================================================
# Diccionarios de textos
# ======================================================

# Diccionario para ingles
declare -A UI_EN=(
  ["menu_main_title"]="AIOWP - All In One Wordpress Manager"
  ["menu_main_prompt"]="Choose an option:"
  ["menu_main_option1"]="Add new WordPress"
  ["menu_main_option2"]="Manage existing sites"
  ["menu_main_option3"]="Install/Verify dependencies"
  ["menu_main_option4"]="Show credits"
  ["menu_main_option5"]="Exit"

  ["new_site_title"]="New WordPress Site"
  ["new_site_prompt"]="Enter the domain (e.g. example.com):"
  ["site_already_exists"]="A configuration for this domain already exists."
  ["directory_create_error"]="Could not create directory %s."
  ["download_wp_error"]="Could not download WordPress. Check your connection."
  ["unzip_error"]="Could not unzip the WordPress package."
  ["move_files_error"]="Could not move WordPress files to %s."
  ["db_title"]="Database"
  ["db_prompt"]="Enter a database password or leave blank to generate a random one:"
  ["site_created_msg"]="The site for %s has been created.\n\nDatabase: %s\nDB user: %s\nDB password: %s"
  
  ["list_sites_empty"]="No sites configured."
  ["choose_site_prompt"]="Select a site to manage:"
  
  ["site_menu_title"]="Manage site: %s"
  ["option_stop"]="Stop site"
  ["option_start"]="Start site"
  ["option_restart"]="Restart site"
  ["option_ssl"]="Configure SSL (Let's Encrypt)"
  ["option_delete"]="Delete site"
  ["option_backup"]="Backup/Restore"
  ["set_retention_policy"]="Set Retention Policy"
  ["option_users"]="Users"
  ["option_back"]="Return"
  
  ["site_stopped_msg"]="The site %s has been stopped."
  ["site_started_msg"]="The site %s has been started."
  ["site_restarted_msg"]="The site %s has been restarted."
  ["ssl_configured_msg"]="SSL has been configured for %s."
  ["site_deleted_msg"]="The site %s has been deleted."
  
  ["backup_manual_prompt"]="Backup"
  ["backup_done_msg"]="Backup completed: %s"
  ["schedule_backup_prompt_dest"]="(Automatic backup) Destination path is set to the default AIOWPM/backups folder."
  ["choose_frequency"]="Choose the frequency:"
  ["frequency_daily"]="Daily"
  ["frequency_weekly"]="Weekly"
  ["frequency_monthly"]="Monthly"
  ["frequency_custom"]="Custom (cron expression)"
  ["schedule_backup_msg"]="Automatic backup scheduled for %s.\nCron: %s\nDestination: %s"
  ["restore_backup_prompt"]="Restore Backup"
  ["restore_confirmation"]="Restore backup for %s? This will overwrite current data."
  ["restore_done_msg"]="Restoration completed for %s."
  ["delete_backup_schedule_confirm"]="Are you sure you want to delete the backup schedule for %s?"
  ["delete_backup_schedule_msg"]="The backup schedule for %s has been deleted."

  ["dependencies_title"]="Dependencies"
  ["dependencies_msg"]="All dependencies are installed and services are active."
  
  ["credits_message"]="AIOWP (All In One Wordpress Manager)\n\nDeveloped by Miguel Canadas Chico\nWeb: miguelcanadas.com\nGitHub: https://github.com/rodillo69\nLinkedin: https://www.linkedin.com/in/miguel-canadas-chico/\n© 2025 Miguel Canadas Chico. All rights reserved."
  
  ["permissions_error"]="This script must be run as root or with sudo."

  # Keys for user management
  ["add_user_title"]="Add User"
  ["add_user_prompt_username"]="Enter username:"
  ["add_user_prompt_email"]="Enter email:"
  ["add_user_prompt_password"]="Enter password (leave blank to auto generate):"
  ["add_user_prompt_role"]="Select role:"
  ["user_add_success"]="User '%s' added successfully."
  ["user_add_error"]="Error adding user '%s'."
  
  ["manage_users_title"]="Manage Users"
  ["manage_users_prompt"]="Select a user to manage:"
  ["change_password"]="Change Password"
  ["delete_user"]="Delete User"
  ["update_password_prompt"]="Enter new password:"
  ["password_update_success"]="Password updated successfully."
  ["password_update_error"]="Error updating password."
  ["user_delete_confirm"]="Are you sure you want to delete user with ID: %s?"
  ["user_delete_success"]="User deleted successfully."
  ["user_delete_error"]="Error deleting user."
  
  ["enter_cron_expression"]="Enter the cron expression:"
  ["delete_site_confirmation"]="Are you sure you want to delete the site %s? This will remove the directory, database, and NGINX configuration."
  ["schedule_automatic_backup"]="Schedule Automatic Backup"
  ["delete_backup_schedule"]="Delete Backup Schedule"
)

# Diccionario para espanol (sin acentos)
declare -A UI_ES=(
  ["menu_main_title"]="AIOWP - All In One Wordpress Manager"
  ["menu_main_prompt"]="Elige una opcion:"
  ["menu_main_option1"]="Agregar nuevo Wordpress"
  ["menu_main_option2"]="Administrar sitios existentes"
  ["menu_main_option3"]="Instalar/Verificar dependencias"
  ["menu_main_option4"]="Mostrar creditos"
  ["menu_main_option5"]="Salir"
  
  ["new_site_title"]="Nuevo Sitio Wordpress"
  ["new_site_prompt"]="Introduce el dominio (por ejemplo: ejemplo.com):"
  ["site_already_exists"]="Ya existe una configuracion para este dominio."
  ["directory_create_error"]="No se pudo crear el directorio %s."
  ["download_wp_error"]="No se pudo descargar Wordpress. Revisa tu conexion."
  ["unzip_error"]="No se pudo descomprimir el paquete de Wordpress."
  ["move_files_error"]="No se pudo mover los archivos de Wordpress a %s."
  ["db_title"]="Base de Datos"
  ["db_prompt"]="Introduce una contrasena para la base de datos o dejala en blanco para generar una aleatoria:"
  ["site_created_msg"]="El sitio para %s se ha creado.\n\nBase de Datos: %s\nUsuario BD: %s\nContrasena BD: %s"
  
  ["list_sites_empty"]="No hay sitios configurados."
  ["choose_site_prompt"]="Selecciona un sitio para administrar:"
  
  ["site_menu_title"]="Administrar sitio: %s"
  ["option_stop"]="Parar sitio"
  ["option_start"]="Iniciar sitio"
  ["option_restart"]="Reiniciar sitio"
  ["option_ssl"]="Configurar SSL (Let's Encrypt)"
  ["option_delete"]="Eliminar sitio"
  ["option_backup"]="Backup/Restauracion"
  ["set_retention_policy"]="Configurar Politica de Retencion"
  ["option_users"]="Usuarios"
  ["option_back"]="Volver"
  
  ["site_stopped_msg"]="El sitio %s ha sido detenido."
  ["site_started_msg"]="El sitio %s ha sido iniciado."
  ["site_restarted_msg"]="El sitio %s se ha reiniciado."
  ["ssl_configured_msg"]="SSL configurado satisfactoriamente para %s."
  ["site_deleted_msg"]="El sitio %s se ha eliminado correctamente."
  
  ["backup_manual_prompt"]="Backup"
  ["backup_done_msg"]="Backup realizado: %s"
  ["schedule_backup_prompt_dest"]="(Backup automatico) La ruta de destino se establece en la carpeta por defecto AIOWPM/backups."
  ["choose_frequency"]="Elige la frecuencia:"
  ["frequency_daily"]="Diario"
  ["frequency_weekly"]="Semanal"
  ["frequency_monthly"]="Mensual"
  ["frequency_custom"]="Personalizado (expresion cron)"
  ["schedule_backup_msg"]="Backup automatico programado para %s.\nCron: %s\nDestino: %s"
  ["restore_backup_prompt"]="Restaurar Backup"
  ["restore_confirmation"]="¿Restaurar backup de %s? Esto sobrescribira los datos actuales."
  ["restore_done_msg"]="Restauracion completada para %s."
  ["delete_backup_schedule_confirm"]="¿Estas seguro de eliminar la programacion de backups para %s?"
  ["delete_backup_schedule_msg"]="La programacion de backups para %s ha sido eliminada."
  
  ["dependencies_title"]="Dependencias"
  ["dependencies_msg"]="Todas las dependencias estan instaladas y los servicios estan activos."
  
  ["credits_message"]="AIOWP (All In One Wordpress Manager)\n\nDesarrollado por Miguel Canadas Chico\nWeb: miguelcanadas.com\nGitHub: https://github.com/rodillo69\nLinkedin: https://www.linkedin.com/in/miguel-canadas-chico/\n© 2025 Miguel Canadas Chico. Todos los derechos reservados."
  
  ["permissions_error"]="Este script debe ejecutarse como root o con sudo."
  
  # Claves para manejo de usuarios
  ["add_user_title"]="Agregar Usuario"
  ["add_user_prompt_username"]="Introduce el nombre de usuario:"
  ["add_user_prompt_email"]="Introduce el email:"
  ["add_user_prompt_password"]="Introduce la contrasena (deja en blanco para generar una aleatoria):"
  ["add_user_prompt_role"]="Selecciona el rol:"
  ["user_add_success"]="Usuario '%s' agregado correctamente."
  ["user_add_error"]="Error al agregar el usuario '%s'."
  
  ["manage_users_title"]="Administrar Usuarios"
  ["manage_users_prompt"]="Selecciona un usuario para administrar:"
  ["change_password"]="Cambiar Contrasena"
  ["delete_user"]="Eliminar Usuario"
  ["update_password_prompt"]="Introduce la nueva contrasena:"
  ["password_update_success"]="Contrasena actualizada correctamente."
  ["password_update_error"]="Error al actualizar la contrasena."
  ["user_delete_confirm"]="Estas seguro de eliminar el usuario con ID: %s?"
  ["user_delete_success"]="Usuario eliminado correctamente."
  ["user_delete_error"]="Error al eliminar el usuario."
  
  ["enter_cron_expression"]="Introduce la expresion cron:"
  ["delete_site_confirmation"]="¿Estas seguro de eliminar el sitio %s? Esto eliminara el directorio, la base de datos y la configuracion de NGINX."
  ["schedule_automatic_backup"]="Programar Backup Automatico"
  ["delete_backup_schedule"]="Eliminar Programacion de Backup"
)

# Funcion de traduccion con formato (usa printf para insertar parametros si es necesario)
t() {
  local key="$1"
  shift
  if [ "$LANG" = "en" ]; then
      printf "${UI_EN[$key]}" "$@"
  else
      printf "${UI_ES[$key]}" "$@"
  fi
}

# ======================================================
# Variables y funciones para la estructura de carpetas
# ======================================================

# Valor por defecto de retencion (si no se configura de forma especifica)
RETENTION_COUNT=5

# Funcion para obtener (y crear si no existen) la carpeta raiz AIOWPM
get_root_dir() {
    local script_dir
    script_dir=$(dirname "$(realpath "$0")")
    local root_dir="${script_dir}/AIOWPM"
    if [ ! -d "$root_dir" ]; then
        mkdir -p "$root_dir"
    fi
    echo "$root_dir"
}

# Funcion para obtener (y crear) la carpeta de backups para un sitio
get_backup_dest() {
    local domain="$1"
    local root_dir
    root_dir=$(get_root_dir)
    local backup_root="${root_dir}/backups"
    if [ ! -d "$backup_root" ]; then
        mkdir -p "$backup_root"
    fi
    local domain_backup_dir="${backup_root}/${domain}"
    if [ ! -d "$domain_backup_dir" ]; then
        mkdir -p "$domain_backup_dir"
    fi
    echo "$domain_backup_dir"
}

# Funcion para obtener (y crear) la carpeta de configuracion para un sitio
get_config_dest() {
    local domain="$1"
    local root_dir
    root_dir=$(get_root_dir)
    local config_root="${root_dir}/config"
    if [ ! -d "$config_root" ]; then
        mkdir -p "$config_root"
    fi
    local domain_config_dir="${config_root}/${domain}"
    if [ ! -d "$domain_config_dir" ]; then
        mkdir -p "$domain_config_dir"
    fi
    echo "$domain_config_dir"
}

# Funcion para obtener la politica de retencion configurada para un sitio;
# si no se ha configurado, se usa el valor por defecto.
get_retention_policy() {
    local domain="$1"
    local config_dir
    config_dir=$(get_config_dest "$domain")
    local retention_file="${config_dir}/backup.conf"
    if [ -f "$retention_file" ]; then
         cat "$retention_file"
    else
         echo "$RETENTION_COUNT"
    fi
}

# Funcion para aplicar la politica de retencion: elimina los backups mas antiguos
aplicar_politica_retencion() {
    local domain="$1"
    local retention_count
    retention_count=$(get_retention_policy "$domain")
    local backup_dir
    backup_dir=$(get_backup_dest "$domain")
    if ls "$backup_dir"/*.tar.gz 1> /dev/null 2>&1; then
         # Obtenemos la lista de backups ordenados por fecha (los mas antiguos primero)
         local backups=( $(ls -1tr "$backup_dir"/*.tar.gz) )
         local num_backups="${#backups[@]}"
         if (( num_backups > retention_count )); then
              local num_to_delete=$(( num_backups - retention_count ))
              for (( i=0; i<num_to_delete; i++ )); do
                    rm -f "${backups[$i]}"
              done
         fi
    fi
}

# Funcion para que el usuario configure la politica de retencion para un sitio
configurar_retencion_backup() {
    local domain="$1"
    local config_dir
    config_dir=$(get_config_dest "$domain")
    local retention_file="${config_dir}/backup.conf"
    local current_retention
    if [ -f "$retention_file" ]; then
         current_retention=$(cat "$retention_file")
    else
         current_retention=$RETENTION_COUNT
    fi
    local new_retention
    new_retention=$(whiptail --title "$(t "retention_policy_title")" \
        --inputbox "$(t "retention_policy_prompt" "$domain" "$current_retention")" 10 60 "$current_retention" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && return
    if ! [[ "$new_retention" =~ ^[1-9][0-9]*$ ]]; then
         whiptail --title "$(t "retention_policy_title")" --msgbox "$(t "retention_invalid")" 10 60
         return
    fi
    echo "$new_retention" > "$retention_file"
    whiptail --title "$(t "retention_policy_title")" --msgbox "$(t "retention_policy_updated" "$new_retention" "$domain")" 10 60
}

# ======================================================
# Funciones para manejo de usuarios (WP-CLI)
# ======================================================

agregar_usuario() {
    local domain="$1"
    cd /var/www/"$domain" || { whiptail --title "$(t "add_user_title")" --msgbox "Cannot change directory to /var/www/$domain" 10 60; return; }
    local username
    username=$(whiptail --title "$(t "add_user_title")" --inputbox "$(t "add_user_prompt_username")" 10 60 3>&1 1>&2 2>&3)
    [ -z "$username" ] && return
    local email
    email=$(whiptail --title "$(t "add_user_title")" --inputbox "$(t "add_user_prompt_email")" 10 60 3>&1 1>&2 2>&3)
    [ -z "$email" ] && return
    local password
    password=$(whiptail --title "$(t "add_user_title")" --passwordbox "$(t "add_user_prompt_password")" 10 60 3>&1 1>&2 2>&3)
    if [ -z "$password" ]; then password=$(openssl rand -base64 12); fi
    local role
    role=$(whiptail --title "$(t "add_user_title")" --menu "$(t "add_user_prompt_role")" 15 60 5 \
        "administrator" "Administrator" \
        "editor" "Editor" \
        "author" "Author" \
        "contributor" "Contributor" \
        "subscriber" "Subscriber" 3>&1 1>&2 2>&3)
    [ -z "$role" ] && return
    wp user create "$username" "$email" --user_pass="$password" --role="$role" --allow-root
    if [ $? -eq 0 ]; then
        whiptail --title "$(t "add_user_title")" --msgbox "$(t "user_add_success" "$username")" 10 60
    else
        whiptail --title "$(t "add_user_title")" --msgbox "$(t "user_add_error" "$username")" 10 60
    fi
}

administrar_usuarios() {
    local domain="$1"
    cd /var/www/"$domain" || { whiptail --title "$(t "manage_users_title")" --msgbox "Cannot change directory to /var/www/$domain" 10 60; return; }
    # Se obtienen solo los campos login y roles, omitiendo la cabecera
    local user_list
    user_list=$(wp user list --fields=login,roles --skip-headers --format=csv --allow-root)
    if [ $? -ne 0 ] || [ -z "$user_list" ]; then
        whiptail --title "$(t "manage_users_title")" --msgbox "Error al obtener la lista de usuarios o no hay usuarios." 10 60
        return
    fi
    local options=()
    local IFS=$'\n'
    for line in $user_list; do
         # Limpiar posibles retornos de carro
         line=$(echo "$line" | tr -d '\r')
         local login=$(echo "$line" | cut -d',' -f1)
         local roles=$(echo "$line" | cut -d',' -f2)
         if [ -n "$login" ]; then
             options+=("$login" "$login ($roles)" "")
         fi
    done
    if [ ${#options[@]} -eq 0 ]; then
        whiptail --title "$(t "manage_users_title")" --msgbox "No se encontraron usuarios." 10 60
        return
    fi
    # Se aumenta el ancho de la ventana a 100 columnas para mostrar la informacion completa
    local selected_user
    selected_user=$(whiptail --title "$(t "manage_users_title")" --menu "$(t "manage_users_prompt")" 20 100 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [ -z "$selected_user" ] && return
    while true; do
        local user_option
        user_option=$(whiptail --title "$(t "manage_users_title")" --menu "Usuario: $selected_user" 15 60 3 \
            "1" "$(t "change_password")" \
            "2" "$(t "delete_user")" \
            "3" "Volver" 3>&1 1>&2 2>&3)
        case "$user_option" in
            1)
                local new_password
                new_password=$(whiptail --title "$(t "change_password")" --passwordbox "$(t "update_password_prompt")" 10 60 3>&1 1>&2 2>&3)
                if [ -z "$new_password" ]; then
                    whiptail --title "$(t "change_password")" --msgbox "Contrasena no cambiada." 10 60
                else
                    wp user update "$selected_user" --user_pass="$new_password" --allow-root
                    if [ $? -eq 0 ]; then
                        whiptail --title "$(t "change_password")" --msgbox "$(t "password_update_success")" 10 60
                    else
                        whiptail --title "$(t "change_password")" --msgbox "$(t "password_update_error")" 10 60
                    fi
                fi
                ;;
            2)
                if whiptail --title "$(t "delete_user")" --yesno "$(t "user_delete_confirm" "$selected_user")" 10 60; then
                    wp user delete "$selected_user" --yes --allow-root
                    if [ $? -eq 0 ]; then
                        whiptail --title "$(t "delete_user")" --msgbox "$(t "user_delete_success")" 10 60
                    else
                        whiptail --title "$(t "delete_user")" --msgbox "$(t "user_delete_error")" 10 60
                    fi
                    break
                fi
                ;;
            3)
                break
                ;;
            *)
                break
                ;;
        esac
    done
}

menu_usuarios() {
    local domain="$1"
    while true; do
        local opcion
        opcion=$(whiptail --title "$(t "option_users") - $domain" --menu "$(t "menu_main_prompt")" 15 60 3 \
            "1" "$(t "add_user_title")" \
            "2" "$(t "manage_users_title")" \
            "3" "Volver" 3>&1 1>&2 2>&3)
        case "$opcion" in
            1) agregar_usuario "$domain" ;;
            2) administrar_usuarios "$domain" ;;
            3) break ;;
            *) break ;;
        esac
    done
}

# ======================================================
# Funciones del Programa
# ======================================================

# --- Backup automatico (usado en cron) ---
if [ "$1" == "--backup-auto" ]; then
    if [ $# -lt 3 ]; then
        echo "Usage: $0 --backup-auto <domain> <destination>"
        exit 1
    fi
    domain="$2"
    dest="$3"
    mkdir -p "$dest"
    do_backup() {
        local domain="$1"
        local dest="$2"
        mkdir -p "$dest"
        local timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        local dbname="wp_${domain//./_}"
        local tmpdir="/tmp/aiowp_backup_${domain}_${timestamp}"
        mkdir -p "$tmpdir"
        cp -r "/var/www/${domain}" "$tmpdir/"
        mariadb-dump -u root "${dbname}" > "$tmpdir/db.sql"
        local backup_file="${dest}/${domain}_backup_${timestamp}.tar.gz"
        tar -czf "$backup_file" -C "$tmpdir" .
        rm -rf "$tmpdir"
        # Aplicar politica de retencion (se leera la configuracion especifica del sitio)
        aplicar_politica_retencion "$domain"
        echo "Backup completed: ${backup_file}"
    }
    do_backup "$domain" "$dest"
    exit 0
fi

# Configuracion de colores para whiptail
export NEWT_COLORS='window=black,lightgray;
                    border=black,lightblue;
                    button=black,lightcyan;
                    actbutton=white,lightblue;
                    title=white,navy'

mostrar_error() {
    whiptail --title "Error - AIOWP" --msgbox "$1" 10 60
}

mostrar_creditos() {
    whiptail --title "$(t "menu_main_title")" --msgbox "$(t "credits_message")" 12 60
}

instalar_dependencias() {
    local PKGS=( "nginx" "mariadb-server" "mariadb-client" \
                 "php8.1-fpm" "php8.1-mysql" "php8.1-curl" "php8.1-gd" "php8.1-xml" "php8.1-mbstring" "php8.1-zip" "php8.1-imagick" \
                 "certbot" "python3-certbot-nginx" "curl" "wget" "zip" "unzip" )
    apt-get update -y
    for pkg in "${PKGS[@]}"; do
        if ! dpkg -l | grep -q "^ii\s\+${pkg} "; then
            if ! apt-get -y install "${pkg}"; then
                mostrar_error "$(t "error_dependency" "$pkg" 2>/dev/null || printf "Could not install dependency: %s" "$pkg")"
                return 1
            fi
        fi
    done

    # Instalar WP-CLI si no existe
    if ! command -v wp >/dev/null 2>&1; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi

    systemctl enable php8.1-fpm nginx mariadb
    systemctl start php8.1-fpm nginx mariadb
    whiptail --title "$(t "dependencies_title")" --msgbox "$(t "dependencies_msg")" 10 60
}

crear_sitio() {
    local domain
    domain=$(whiptail --title "$(t "new_site_title")" --inputbox "$(t "new_site_prompt")" 10 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$domain" ]; then return 1; fi
    if [ -f "/etc/nginx/sites-available/${domain}.conf" ]; then
        whiptail --title "$(t "new_site_title")" --msgbox "$(t "site_already_exists")" 8 60
        return 1
    fi
    local wp_path="/var/www/${domain}"
    if ! mkdir -p "${wp_path}"; then
        whiptail --title "$(t "new_site_title")" --msgbox "$(t "directory_create_error" "${wp_path}")" 8 60
        return 1
    fi
    cd /tmp || exit
    if ! wget -q https://wordpress.org/latest.zip; then
        whiptail --title "$(t "new_site_title")" --msgbox "$(t "download_wp_error")" 8 60
        return 1
    fi
    if ! unzip -q latest.zip; then
        whiptail --title "$(t "new_site_title")" --msgbox "$(t "unzip_error")" 8 60
        return 1
    fi
    if ! mv wordpress/* "${wp_path}/"; then
        whiptail --title "$(t "new_site_title")" --msgbox "$(t "move_files_error" "${wp_path}")" 8 60
        return 1
    fi
    chown -R www-data:www-data "${wp_path}"
    chmod -R 755 "${wp_path}"
    local dbname="wp_${domain//./_}"
    local dbpass
    dbpass=$(whiptail --title "$(t "db_title")" --inputbox "$(t "db_prompt")" 10 60 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then return 1; fi
    if [ -z "$dbpass" ]; then dbpass=$(openssl rand -base64 12); fi
    if ! mariadb -u root -e "CREATE DATABASE ${dbname};"; then
        whiptail --title "$(t "new_site_title")" --msgbox "Could not create database ${dbname}." 8 60
        return 1
    fi
    if ! mariadb -u root -e "CREATE USER '${dbname}'@'localhost' IDENTIFIED BY '${dbpass}';"; then
        whiptail --title "$(t "new_site_title")" --msgbox "Could not create database user." 8 60
        mariadb -u root -e "DROP DATABASE IF EXISTS ${dbname};"
        return 1
    fi
    if ! mariadb -u root -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'localhost'; FLUSH PRIVILEGES;"; then
        whiptail --title "$(t "new_site_title")" --msgbox "Could not grant privileges to the database user." 8 60
        mariadb -u root -e "DROP USER IF EXISTS '${dbname}'@'localhost';"
        mariadb -u root -e "DROP DATABASE IF EXISTS ${dbname};"
        return 1
    fi
    local nginx_conf="/etc/nginx/sites-available/${domain}.conf"
    cat > "${nginx_conf}" <<EOF
server {
    listen 80;
    server_name ${domain} www.${domain};

    root ${wp_path};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -s "${nginx_conf}" /etc/nginx/sites-enabled/
    if ! nginx -t; then
        whiptail --title "$(t "new_site_title")" --msgbox "NGINX configuration is not valid. Check ${nginx_conf}." 8 60
        rm -f "/etc/nginx/sites-enabled/${domain}.conf"
        rm -f "${nginx_conf}"
        mariadb -u root -e "DROP USER IF EXISTS '${dbname}'@'localhost';"
        mariadb -u root -e "DROP DATABASE IF EXISTS ${dbname};"
        return 1
    fi
    systemctl reload nginx
    cp "${wp_path}/wp-config-sample.php" "${wp_path}/wp-config.php"
    sed -i "s/database_name_here/${dbname}/" "${wp_path}/wp-config.php"
    sed -i "s/username_here/${dbname}/" "${wp_path}/wp-config.php"
    sed -i "s/password_here/${dbpass}/" "${wp_path}/wp-config.php"
    local salt
    salt=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    if [ -n "$salt" ]; then
        sed -i "/AUTH_KEY/d" "${wp_path}/wp-config.php"
        sed -i "/SECURE_AUTH_KEY/d" "${wp_path}/wp-config.php"
        sed -i "/LOGGED_IN_KEY/d" "${wp_path}/wp-config.php"
        sed -i "/NONCE_KEY/d" "${wp_path}/wp-config.php"
        sed -i "/AUTH_SALT/d" "${wp_path}/wp-config.php"
        sed -i "/SECURE_AUTH_SALT/d" "${wp_path}/wp-config.php"
        sed -i "/LOGGED_IN_SALT/d" "${wp_path}/wp-config.php"
        sed -i "/NONCE_SALT/d" "${wp_path}/wp-config.php"
        sed -i "/^define('DB_COLLATE', '');/r /dev/stdin" "${wp_path}/wp-config.php" <<< "$salt"
    fi
    whiptail --title "$(t "new_site_title")" --msgbox "$(t "site_created_msg" "$domain" "$dbname" "$dbname" "$dbpass")" 12 70
}

listar_sitios() {
    local sitios
    sitios=$(ls /etc/nginx/sites-available/*.conf 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.conf//')
    if [ -z "$sitios" ]; then
        whiptail --title "$(t "menu_main_title")" --msgbox "$(t "list_sites_empty")" 8 60
        return
    fi
    local opciones=()
    for s in $sitios; do
        opciones+=("$s" "$(t "choose_site_prompt") $s" "OFF")
    done
    local sitio_seleccionado
    sitio_seleccionado=$(whiptail --title "$(t "menu_main_title")" --radiolist "$(t "choose_site_prompt")" 20 100 10 "${opciones[@]}" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$sitio_seleccionado" ]; then
        return
    fi
    submenu_sitio "$sitio_seleccionado"
}

parar_sitio() {
    local domain="$1"
    if [ -L "/etc/nginx/sites-enabled/${domain}.conf" ]; then
        rm "/etc/nginx/sites-enabled/${domain}.conf"
        systemctl reload nginx
        whiptail --title "$(t "option_stop")" --msgbox "$(t "site_stopped_msg" "$domain")" 8 60
    else
        whiptail --title "$(t "option_stop")" --msgbox "$(t "site_stopped_msg" "$domain")" 8 60
    fi
}

iniciar_sitio() {
    local domain="$1"
    if [ ! -L "/etc/nginx/sites-enabled/${domain}.conf" ]; then
        ln -s "/etc/nginx/sites-available/${domain}.conf" "/etc/nginx/sites-enabled/${domain}.conf"
        systemctl reload nginx
        whiptail --title "$(t "option_start")" --msgbox "$(t "site_started_msg" "$domain")" 8 60
    else
        whiptail --title "$(t "option_start")" --msgbox "$(t "site_started_msg" "$domain")" 8 60
    fi
}

reiniciar_sitio() {
    local domain="$1"
    systemctl reload nginx
    whiptail --title "$(t "option_restart")" --msgbox "$(t "site_restarted_msg" "$domain")" 8 60
}

configurar_ssl() {
    local domain="$1"
    if ! certbot --nginx -d "$domain" -d "www.${domain}"; then
        whiptail --title "Error" --msgbox "Could not configure SSL for ${domain}. Check that the domain points to this server." 8 60
        return
    fi
    whiptail --title "$(t "option_ssl")" --msgbox "$(t "ssl_configured_msg" "$domain")" 8 60
}

eliminar_sitio() {
    local domain="$1"
    if ! whiptail --title "$(t "option_delete")" --yesno "$(t "delete_site_confirmation" "$domain")" 10 60; then
        return
    fi
    if [ -L "/etc/nginx/sites-enabled/${domain}.conf" ]; then
        rm "/etc/nginx/sites-enabled/${domain}.conf"
    fi
    if [ -f "/etc/nginx/sites-available/${domain}.conf" ]; then
        rm "/etc/nginx/sites-available/${domain}.conf"
    fi
    local wp_path="/var/www/${domain}"
    if [ -d "${wp_path}" ]; then
        rm -rf "${wp_path}"
    fi
    local dbname="wp_${domain//./_}"
    mariadb -u root -e "DROP DATABASE IF EXISTS ${dbname};"
    mariadb -u root -e "DROP USER IF EXISTS '${dbname}'@'localhost';"
    mariadb -u root -e "FLUSH PRIVILEGES;"
    systemctl reload nginx
    whiptail --title "$(t "option_delete")" --msgbox "$(t "site_deleted_msg" "$domain")" 8 60
}

do_backup() {
    local domain="$1"
    local dest="$2"
    mkdir -p "$dest"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local dbname="wp_${domain//./_}"
    local tmpdir="/tmp/aiowp_backup_${domain}_${timestamp}"
    mkdir -p "$tmpdir"
    cp -r "/var/www/${domain}" "$tmpdir/"
    mariadb-dump -u root "${dbname}" > "$tmpdir/db.sql"
    local backup_file="${dest}/${domain}_backup_${timestamp}.tar.gz"
    tar -czf "$backup_file" -C "$tmpdir" .
    rm -rf "$tmpdir"
    # Aplicar politica de retencion (se leera la configuracion especifica del sitio)
    aplicar_politica_retencion "$domain"
    whiptail --title "$(t "backup_manual_prompt")" --msgbox "$(t "backup_done_msg" "$backup_file")" 10 60
}

backup_site_manual() {
    local domain="$1"
    # Se usa la funcion auxiliar para obtener la ruta de backup por defecto (nueva estructura)
    local dest
    dest=$(get_backup_dest "$domain")
    do_backup "$domain" "$dest"
}

configurar_backup_site() {
    local domain="$1"
    # Se usa la ruta por defecto de backups (AIOWPM/backups/<dominio>)
    local dest
    dest=$(get_backup_dest "$domain")
    local frecuencia
    frecuencia=$(whiptail --title "$(t "menu_main_prompt")" --menu "$(t "choose_frequency")" 17 60 4 \
         "1" "$(t "frequency_daily")" \
         "2" "$(t "frequency_weekly")" \
         "3" "$(t "frequency_monthly")" \
         "4" "$(t "frequency_custom")" 3>&1 1>&2 2>&3)
    [ -z "$frecuencia" ] && return
    local cron_expr=""
    case "$frecuencia" in
         1) cron_expr="0 2 * * *" ;;
         2) cron_expr="0 3 * * 0" ;;
         3) cron_expr="0 4 1 * *" ;;
         4) cron_expr=$(whiptail --title "$(t "frequency_custom")" --inputbox "$(t "enter_cron_expression")" 10 60 3>&1 1>&2 2>&3) ;;
    esac
    [ -z "$cron_expr" ] && return
    local script_path
    script_path=$(realpath "$0")
    local cron_file="/etc/cron.d/aiowp_backup_${domain}"
    echo "${cron_expr} root ${script_path} --backup-auto ${domain} ${dest}" > "$cron_file"
    whiptail --title "$(t "schedule_backup_prompt_dest")" --msgbox "$(t "schedule_backup_msg" "$domain" "$cron_expr" "$dest")" 10 60
}

restore_site() {
    local domain="$1"
    local backup_dir
    backup_dir=$(get_backup_dest "$domain")
    local backups=()
    for file in "$backup_dir"/*.tar.gz; do
        if [ -f "$file" ]; then
            backups+=("$(basename "$file")" "")
        fi
    done
    if [ ${#backups[@]} -eq 0 ]; then
        whiptail --title "$(t "restore_backup_select_title")" --msgbox "$(printf "$(t "no_backups_found")" "$domain")" 8 60
        return
    fi
    local backup_file_name
    backup_file_name=$(whiptail --title "$(t "restore_backup_select_title")" --menu "$(t "restore_backup_select_prompt")" 20 60 10 "${backups[@]}" 3>&1 1>&2 2>&3)
    [ -z "$backup_file_name" ] && return
    local backup_file="${backup_dir}/${backup_file_name}"
    if ! whiptail --title "$(t "restore_backup_prompt")" --yesno "$(t "restore_confirmation" "$domain")" 10 60; then
         return
    fi
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local tmpdir="/tmp/aiowp_restore_${domain}_${timestamp}"
    mkdir -p "$tmpdir"
    tar -xzf "$backup_file" -C "$tmpdir"
    rm -rf "/var/www/${domain}"
    mkdir -p "/var/www/${domain}"
    cp -r "$tmpdir/${domain}" "/var/www/"
    local dbname="wp_${domain//./_}"
    mariadb -u root -e "DROP DATABASE IF EXISTS ${dbname}; CREATE DATABASE ${dbname};"
    mariadb -u root "${dbname}" < "$tmpdir/db.sql"
    rm -rf "$tmpdir"
    whiptail --title "$(t "restore_backup_prompt")" --msgbox "$(t "restore_done_msg" "$domain")" 10 60
}

eliminar_backup_programacion() {
    local domain="$1"
    local cron_file="/etc/cron.d/aiowp_backup_${domain}"
    if [ ! -f "$cron_file" ]; then
        whiptail --title "$(t "delete_backup_schedule_confirm" "$domain")" --msgbox "No backup schedule exists for ${domain}." 8 60
        return
    fi
    if whiptail --title "$(t "delete_backup_schedule_confirm" "$domain")" --yesno "$(t "delete_backup_schedule_confirm" "$domain")" 10 60; then
        rm -f "$cron_file"
        whiptail --title "$(t "delete_backup_schedule_msg" "$domain")" --msgbox "$(t "delete_backup_schedule_msg" "$domain")" 8 60
    fi
}

# Nuevo submenu para usuarios
menu_usuarios() {
    local domain="$1"
    while true; do
        local opcion
        opcion=$(whiptail --title "$(t "option_users") - $domain" --menu "$(t "menu_main_prompt")" 15 60 3 \
            "1" "$(t "add_user_title")" \
            "2" "$(t "manage_users_title")" \
            "3" "Volver" 3>&1 1>&2 2>&3)
        case "$opcion" in
            1) agregar_usuario "$domain" ;;
            2) administrar_usuarios "$domain" ;;
            3) break ;;
            *) break ;;
        esac
    done
}

# Submenu de administracion del sitio (ahora con la opcion Usuarios)
submenu_sitio() {
    local domain="$1"
    while true; do
        local opcion
        opcion=$(whiptail --title "$(t "site_menu_title" "$domain")" --menu "$(t "menu_main_prompt")" 20 100 9 \
            "1" "$(t "option_stop")" \
            "2" "$(t "option_start")" \
            "3" "$(t "option_restart")" \
            "4" "$(t "option_ssl")" \
            "5" "$(t "option_delete")" \
            "6" "$(t "option_backup")" \
            "7" "$(t "set_retention_policy")" \
            "8" "$(t "option_users")" \
            "9" "$(t "option_back")" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break
        case "$opcion" in
            1) parar_sitio "$domain" ;;
            2) iniciar_sitio "$domain" ;;
            3) reiniciar_sitio "$domain" ;;
            4) configurar_ssl "$domain" ;;
            5) eliminar_sitio "$domain"; break ;;
            6) menu_backup_site "$domain" ;;
            7) configurar_retencion_backup "$domain" ;;
            8) menu_usuarios "$domain" ;;
            9) break ;;
        esac
    done
}

menu_principal() {
    while true; do
        local opcion
        opcion=$(whiptail --title "$(t "menu_main_title")" --menu "$(t "menu_main_prompt")" 17 60 6 \
            "1" "$(t "menu_main_option1")" \
            "2" "$(t "menu_main_option2")" \
            "3" "$(t "menu_main_option3")" \
            "4" "$(t "menu_main_option4")" \
            "5" "$(t "menu_main_option5")" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && exit 0
        case "$opcion" in
            1) crear_sitio ;;
            2) listar_sitios ;; 
            3) instalar_dependencias ;;
            4) mostrar_creditos ;;
            5) exit 0 ;;
        esac
    done
}

# ======================================================
# Verificar permisos de root
# ======================================================
if [ "$(id -u)" -ne 0 ]; then
    whiptail --title "Error" --msgbox "$(t "permissions_error")" 8 60
    exit 1
fi

# ======================================================
# Iniciar el programa
# ======================================================
seleccionar_idioma
menu_principal
