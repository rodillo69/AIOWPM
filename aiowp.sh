#!/usr/bin/env bash
# --------------------------------------------------
# Script: AIOWP (All In One Wordpress Manager)
# Descripción: Script con whiptail para gestionar
#              múltiples instalaciones de WordPress con
#              NGINX en Ubuntu (usando MariaDB y PHP 8.1),
#              además de realizar backups/restauraciones, 
#              eliminar programaciones de backups y soportar
#              inglés y español.
#
#              Desarrollado por Rodillo Systems
#              Todos los derechos reservados © 2025
# --------------------------------------------------

# ======================================================
# Selección del idioma
# ======================================================
seleccionar_idioma() {
    LANG=$(whiptail --title "Select Language / Seleccione Idioma" --menu "Choose your language:" 15 60 2 \
             "en" "English" \
             "es" "Español" 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ] || [ -z "$LANG" ]; then
        LANG="es"
    fi
}

# ======================================================
# Diccionarios de textos
# ======================================================

# Diccionario para inglés
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
  ["option_back"]="Return"
  
  ["site_stopped_msg"]="The site %s has been stopped."
  ["site_started_msg"]="The site %s has been started."
  ["site_restarted_msg"]="The site %s has been restarted."
  ["ssl_configured_msg"]="SSL has been configured for %s."
  ["site_deleted_msg"]="The site %s has been deleted."
  
  ["backup_manual_prompt"]="Enter the destination path for the backup:"
  ["backup_done_msg"]="Backup completed: %s"
  ["schedule_backup_prompt_dest"]="Enter the destination path for backups:"
  ["choose_frequency"]="Choose the frequency:"
  ["frequency_daily"]="Daily"
  ["frequency_weekly"]="Weekly"
  ["frequency_monthly"]="Monthly"
  ["frequency_custom"]="Custom (cron expression)"
  ["schedule_backup_msg"]="Automatic backup scheduled for %s.\nCron: %s\nDestination: %s"
  ["restore_backup_prompt"]="Enter the full path of the backup file (.tar.gz):"
  ["restore_confirmation"]="Restore backup for %s? This will overwrite current data."
  ["restore_done_msg"]="Restoration completed for %s."
  ["delete_backup_schedule_confirm"]="Are you sure you want to delete the backup schedule for %s?"
  ["delete_backup_schedule_msg"]="The backup schedule for %s has been deleted."

  ["dependencies_title"]="Dependencies"
  ["dependencies_msg"]="All dependencies are installed and services are active."
  
  ["credits_message"]="AIOWP (All In One Wordpress Manager)\n\nDeveloped by Rodillo Systems\n© 2025 Rodillo Systems. All rights reserved."
  
  ["permissions_error"]="This script must be run as root or with sudo."
)

# Diccionario para español
declare -A UI_ES=(
  ["menu_main_title"]="AIOWP - All In One Wordpress Manager"
  ["menu_main_prompt"]="Elige una opción:"
  ["menu_main_option1"]="Agregar nuevo WordPress"
  ["menu_main_option2"]="Administrar sitios existentes"
  ["menu_main_option3"]="Instalar/Verificar dependencias"
  ["menu_main_option4"]="Mostrar créditos"
  ["menu_main_option5"]="Salir"
  
  ["new_site_title"]="Nuevo Sitio WordPress"
  ["new_site_prompt"]="Introduce el dominio (por ejemplo: ejemplo.com):"
  ["site_already_exists"]="Ya existe una configuración para este dominio."
  ["directory_create_error"]="No se pudo crear el directorio %s."
  ["download_wp_error"]="No se pudo descargar WordPress. Revisa tu conexión."
  ["unzip_error"]="No se pudo descomprimir el paquete de WordPress."
  ["move_files_error"]="No se pudo mover los archivos de WordPress a %s."
  ["db_title"]="Base de Datos"
  ["db_prompt"]="Introduce una contraseña para la base de datos o déjala en blanco para generar una aleatoria:"
  ["site_created_msg"]="El sitio para %s se ha creado.\n\nBase de Datos: %s\nUsuario BD: %s\nContraseña BD: %s"
  
  ["list_sites_empty"]="No hay sitios configurados."
  ["choose_site_prompt"]="Selecciona un sitio para administrar:"
  
  ["site_menu_title"]="Administrar sitio: %s"
  ["option_stop"]="Parar sitio"
  ["option_start"]="Iniciar sitio"
  ["option_restart"]="Reiniciar sitio"
  ["option_ssl"]="Configurar SSL (Let's Encrypt)"
  ["option_delete"]="Eliminar sitio"
  ["option_backup"]="Backup/Restauración"
  ["option_back"]="Volver"
  
  ["site_stopped_msg"]="El sitio %s ha sido detenido."
  ["site_started_msg"]="El sitio %s ha sido iniciado."
  ["site_restarted_msg"]="El sitio %s se ha reiniciado."
  ["ssl_configured_msg"]="SSL configurado satisfactoriamente para %s."
  ["site_deleted_msg"]="El sitio %s se ha eliminado correctamente."
  
  ["backup_manual_prompt"]="Introduce la ruta de destino para el backup:"
  ["backup_done_msg"]="Backup realizado: %s"
  ["schedule_backup_prompt_dest"]="Introduce la ruta de destino para los backups:"
  ["choose_frequency"]="Elige la frecuencia:"
  ["frequency_daily"]="Diario"
  ["frequency_weekly"]="Semanal"
  ["frequency_monthly"]="Mensual"
  ["frequency_custom"]="Personalizado (expresión cron)"
  ["schedule_backup_msg"]="Backup automático programado para %s.\nCron: %s\nDestino: %s"
  ["restore_backup_prompt"]="Introduce la ruta completa del archivo de backup (.tar.gz):"
  ["restore_confirmation"]="¿Restaurar backup de %s? Esto sobrescribirá los datos actuales."
  ["restore_done_msg"]="Restauración completada para %s."
  ["delete_backup_schedule_confirm"]="¿Estás seguro de eliminar la programación de backups para %s?"
  ["delete_backup_schedule_msg"]="La programación de backups para %s ha sido eliminada."

  ["dependencies_title"]="Dependencias"
  ["dependencies_msg"]="Todas las dependencias están instaladas y los servicios están activos."
  
  ["credits_message"]="AIOWP (All In One Wordpress Manager)\n\nDesarrollado por Rodillo Systems\n© 2025 Rodillo Systems. Todos los derechos reservados."
  
  ["permissions_error"]="Este script debe ejecutarse como root o con sudo."
)

# Función de traducción con formato (usa printf para insertar parámetros si es necesario)
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
# Funciones del Programa
# ======================================================

# Si se invoca con --backup-auto se ejecuta el backup automático (usado en cron)
if [ "$1" == "--backup-auto" ]; then
    if [ $# -lt 3 ]; then
        echo "Usage: $0 --backup-auto <domain> <destination>"
        exit 1
    fi
    domain="$2"
    dest="$3"
    do_backup() {
        local domain="$1"
        local dest="$2"
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
        echo "Backup completed: ${backup_file}"
    }
    do_backup "$domain" "$dest"
    exit 0
fi

# Configuración de colores para whiptail
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
    # Aumentamos el ancho (100 columnas en lugar de 60)
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
    if ! whiptail --title "$(t "option_delete")" --yesno "Are you sure you want to delete the site ${domain}? This will remove the directory, database, and NGINX configuration." 10 60; then
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
    whiptail --title "$(t "backup_manual_prompt")" --msgbox "$(t "backup_done_msg" "$backup_file")" 10 60
}

backup_site_manual() {
    local domain="$1"
    local dest
    dest=$(whiptail --title "$(t "backup_manual_prompt")" --inputbox "$(t "backup_manual_prompt")" 10 60 3>&1 1>&2 2>&3)
    [ -z "$dest" ] && return
    mkdir -p "$dest"
    do_backup "$domain" "$dest"
}

configurar_backup_site() {
    local domain="$1"
    local dest
    dest=$(whiptail --title "$(t "schedule_backup_prompt_dest")" --inputbox "$(t "schedule_backup_prompt_dest")" 10 60 3>&1 1>&2 2>&3)
    [ -z "$dest" ] && return
    mkdir -p "$dest"
    local frecuencia
    frecuencia=$(whiptail --title "$(t "choose_frequency")" --menu "$(t "choose_frequency")" 15 60 4 \
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
         4) cron_expr=$(whiptail --title "$(t "frequency_custom")" --inputbox "Enter the cron expression:" 10 60 3>&1 1>&2 2>&3) ;;
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
    local backup_file
    backup_file=$(whiptail --title "$(t "restore_backup_prompt")" --inputbox "$(t "restore_backup_prompt")" 10 60 3>&1 1>&2 2>&3)
    if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
         whiptail --title "$(t "restore_backup_prompt")" --msgbox "Invalid backup file." 8 60
         return
    fi
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

menu_backup_site() {
    local domain="$1"
    while true; do
        local opcion
        opcion=$(whiptail --title "$(t "option_backup") - ${domain}" --menu "Choose an option:" 17 60 5 \
            "1" "$(t "backup_manual_prompt")" \
            "2" "Schedule Automatic Backup" \
            "3" "Restore Backup" \
            "4" "Delete Backup Schedule" \
            "5" "$(t "option_back")" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break
        case "$opcion" in
            1) backup_site_manual "$domain" ;;
            2) configurar_backup_site "$domain" ;;
            3) restore_site "$domain" ;;
            4) eliminar_backup_programacion "$domain" ;;
            5) break ;;
        esac
    done
}

submenu_sitio() {
    local domain="$1"
    while true; do
        local opcion
        # Aumentamos el ancho de la ventana a 100 columnas
        opcion=$(whiptail --title "$(t "site_menu_title" "$domain")" --menu "Choose an option:" 17 100 7 \
            "1" "$(t "option_stop")" \
            "2" "$(t "option_start")" \
            "3" "$(t "option_restart")" \
            "4" "$(t "option_ssl")" \
            "5" "$(t "option_delete")" \
            "6" "$(t "option_backup")" \
            "7" "$(t "option_back")" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break
        case "$opcion" in
            1) parar_sitio "$domain" ;;
            2) iniciar_sitio "$domain" ;;
            3) reiniciar_sitio "$domain" ;;
            4) configurar_ssl "$domain" ;;
            5) eliminar_sitio "$domain"; break ;;
            6) menu_backup_site "$domain" ;;
            7) break ;;
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
