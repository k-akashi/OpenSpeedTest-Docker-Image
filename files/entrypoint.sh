#!/bin/sh

has_config=false
[ -f "$CONFIG" ] && has_config=true

ip a | egrep -q 'inet6 '
if [ "$has_config" = true ] && [[ $? -ne 0 ]]; then
  # IPv6 not enabled
  sed -i '/listen \[::\]:300/d' ${CONFIG}
fi

ip a | egrep -q 'inet '
if [ "$has_config" = true ] && [[ $? -ne 0 ]]; then
  # IPv4 not enabled
  sed -i '/listen 300/d' ${CONFIG}
fi


if [ "$has_config" = true ] && [ "$CHANGE_CONTAINER_PORTS" = True ]; then
    if [ "$HTTP_PORT" ]; then
        sed -i "s/3000/${HTTP_PORT}/g" ${CONFIG}
    fi

    if [ "$HTTPS_PORT" ]; then
        sed -i "s/3001/${HTTPS_PORT}/g" ${CONFIG}
    fi
fi


Verify_TXT_path="/usr/share/nginx/html/Verify.txt"

if [ "$VERIFY_OWNERSHIP" ]; then
      if [ ! -f "$Verify_TXT_path" ]; then
      echo ${VERIFY_OWNERSHIP} > /usr/share/nginx/html/Verify.txt
      fi
fi

if [ "$SET_SERVER_NAME" ]; then
      SERVER_NAME='<h1 style="display: inline;color: #7c888d; font-size: 22px;font-family: Roboto-Medium, Roboto;font-weight: 500;">'${SET_SERVER_NAME}'</h1>'
      if ! grep -q "$SERVER_NAME" "$INDEX_HTML"; then
      sed -i -e '/<body>/a\'$'\n'"$SERVER_NAME" ${INDEX_HTML}
      fi
fi

PLATFORM_LOGO_LIGHT_PATH="/usr/share/nginx/html/assets/images/platform-logo-light.svg"
PLATFORM_LOGO_DARK_PATH="/usr/share/nginx/html/assets/images/platform-logo-dark.svg"
PLATFORM_LOGO2_LIGHT_PATH="/usr/share/nginx/html/assets/images/platform-logo2-light.svg"
PLATFORM_LOGO2_DARK_PATH="/usr/share/nginx/html/assets/images/platform-logo2-dark.svg"
platform_logo_src_light="assets/images/platform-logo.svg"
platform_logo_src_dark="assets/images/platform-logo.svg"
platform_logo2_src_light="$platform_logo_src_light"
platform_logo2_src_dark="$platform_logo_src_dark"

platform_name="${PLATFORM_NAME:-}"
platform_text_block=""
if [ -n "$platform_name" ]; then
  platform_text_block="<span class=\"platform-badge__text\"><strong>${platform_name}</strong></span>"
fi
escaped_platform_text_block=$(printf '%s' "$platform_text_block" | sed 's/[\/&]/\\&/g')
sed -i "s/__PLATFORM_TEXT_BLOCK__/${escaped_platform_text_block}/g" "${INDEX_HTML}"

resolve_platform_logo_src() {
  logo_file="$1"
  logo_svg="$2"
  logo_web_path="$3"
  logo_copy_target="$4"
  logo_fallback="$5"
  logo_src="$logo_fallback"

  if [ -n "$logo_file" ] && [ -f "$logo_file" ]; then
    case "$logo_file" in
      /usr/share/nginx/html/*)
        logo_src="${logo_file#/usr/share/nginx/html/}"
        ;;
      *)
        if cp "$logo_file" "$logo_copy_target"; then
          logo_src="${logo_copy_target#/usr/share/nginx/html/}"
        fi
        ;;
    esac
  elif [ -n "$logo_svg" ]; then
    printf '%s\n' "$logo_svg" > "$logo_copy_target"
    logo_src="${logo_copy_target#/usr/share/nginx/html/}"
  fi

  if [ -n "$logo_web_path" ]; then
    logo_src="${logo_web_path#/}"
  fi

  printf '%s' "$logo_src"
}

platform_logo_src_light=$(resolve_platform_logo_src "${PLATFORM_LOGO_FILE_LIGHT:-$PLATFORM_LOGO_FILE}" "${PLATFORM_LOGO_SVG_LIGHT:-$PLATFORM_LOGO_SVG}" "${PLATFORM_LOGO_WEB_PATH_LIGHT:-$PLATFORM_LOGO_WEB_PATH}" "$PLATFORM_LOGO_LIGHT_PATH" "assets/images/platform-logo.svg")
platform_logo_src_dark=$(resolve_platform_logo_src "${PLATFORM_LOGO_FILE_DARK:-$PLATFORM_LOGO_FILE}" "${PLATFORM_LOGO_SVG_DARK:-$PLATFORM_LOGO_SVG}" "${PLATFORM_LOGO_WEB_PATH_DARK:-$PLATFORM_LOGO_WEB_PATH}" "$PLATFORM_LOGO_DARK_PATH" "$platform_logo_src_light")
platform_logo2_src_light=$(resolve_platform_logo_src "${PLATFORM_LOGO2_FILE_LIGHT:-$PLATFORM_LOGO2_FILE}" "${PLATFORM_LOGO2_SVG_LIGHT:-$PLATFORM_LOGO2_SVG}" "${PLATFORM_LOGO2_WEB_PATH_LIGHT:-$PLATFORM_LOGO2_WEB_PATH}" "$PLATFORM_LOGO2_LIGHT_PATH" "$platform_logo_src_light")
platform_logo2_src_dark=$(resolve_platform_logo_src "${PLATFORM_LOGO2_FILE_DARK:-$PLATFORM_LOGO2_FILE}" "${PLATFORM_LOGO2_SVG_DARK:-$PLATFORM_LOGO2_SVG}" "${PLATFORM_LOGO2_WEB_PATH_DARK:-$PLATFORM_LOGO2_WEB_PATH}" "$PLATFORM_LOGO2_DARK_PATH" "$platform_logo2_src_light")

escaped_platform_logo_src_light=$(printf '%s' "$platform_logo_src_light" | sed 's/[\/&]/\\&/g')
escaped_platform_logo_src_dark=$(printf '%s' "$platform_logo_src_dark" | sed 's/[\/&]/\\&/g')
escaped_platform_logo2_src_light=$(printf '%s' "$platform_logo2_src_light" | sed 's/[\/&]/\\&/g')
escaped_platform_logo2_src_dark=$(printf '%s' "$platform_logo2_src_dark" | sed 's/[\/&]/\\&/g')
sed -i "s/__PLATFORM_LOGO_SRC_LIGHT__/${escaped_platform_logo_src_light}/g" "${INDEX_HTML}"
sed -i "s/__PLATFORM_LOGO_SRC_DARK__/${escaped_platform_logo_src_dark}/g" "${INDEX_HTML}"
sed -i "s/__PLATFORM_LOGO2_SRC_LIGHT__/${escaped_platform_logo2_src_light}/g" "${INDEX_HTML}"
sed -i "s/__PLATFORM_LOGO2_SRC_DARK__/${escaped_platform_logo2_src_dark}/g" "${INDEX_HTML}"

case "$ENABLE_SPEEDTEST_RESULT_LOG" in
  true|True|TRUE|1|yes|Yes|YES)
  sed -i "s/__ENABLE_SPEEDTEST_RESULT_LOG__/true/g" "${INDEX_HTML}"
  ;;
  *)
  sed -i "s/__ENABLE_SPEEDTEST_RESULT_LOG__/false/g" "${INDEX_HTML}"
  ;;
esac

if [ "$has_config" = true ] && [ "$ALLOW_ONLY" ]; then

allow_only=${ALLOW_ONLY}

IFS=';' domains=$(echo "$allow_only" | tr ';' '\n')

map_config="map \$http_origin \$allowed_origin {
    default 0;
"
while IFS= read -r line; do
    escaped_domain=$(echo "$line" | sed 's/\./\\./g')
    map_config="$map_config    \"~^https?://(www\.)?($escaped_domain)\$\" 1;
"
done < <(printf '%s\n' "$domains")

map_config="$map_config}"

nginx_conf_path="/etc/nginx/nginx.conf"
pattern="map \$http_origin \$allowed_origin {"
nginx_block="if (\$allowed_origin = 0) { return 444; }"

if grep -q "$pattern" "$nginx_conf_path"; then
    :
else
    while IFS= read -r line; do
sed -i '/^\s*http\s*{/ {
    :a;
    N;
    /\s*}\s*$/!ba;
    s|\(}\)|'"$line"'\n\1|
}' "$nginx_conf_path"
    done < <(printf '%s\n' "$map_config")
        if [ $? -eq 0 ]; then
            if grep -q "$nginx_block" "$CONFIG"; then
            :
            else
                    sed -i '/location \/ {/ {
                        a\
                '"$nginx_block"'
                    }' "$CONFIG"

                    sed -i '/location ~\* \^.+\\.(?:css|cur|js|jpe?g|gif|htc|ico|png|html|xml|otf|ttf|eot|woff|woff2|svg)\$ {/ {
                        a\
                '"$nginx_block"'
                    }' "$CONFIG"
            fi
        fi
fi

fi


if [ "$has_config" = true ] && [ "$DOMAIN_NAME" ]; then
sed -i "/\bYOURDOMAIN\b/c\ server_name _ localhost ${DOMAIN_NAME};" "${CONFIG}"
fi

nginx -g 'daemon off;' & sleep 5

if [ "$ENABLE_LETSENCRYPT" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then

fullchain_path="/var/log/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"

certbot certonly -n --webroot --webroot-path /usr/share/nginx/html --no-redirect --agree-tos --email "$USER_EMAIL" -d "$DOMAIN_NAME" --config-dir /var/log/letsencrypt/ --work-dir /var/log/letsencrypt/work --logs-dir /var/log/letsencrypt/log 

  if [ $? -eq 0 ]; then

      if [ -f "$fullchain_path" ]; then
      sed -i "/\bssl_certificate\b/c\ssl_certificate \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/fullchain.pem;" "${CONFIG}"
      sed -i "/\bssl_certificate_key\b/c\ssl_certificate_key \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/privkey.pem;" "${CONFIG}"
      nginx -s reload
      random_minute=$(shuf -i 0-59 -n 1)
      random_hour=$(shuf -i 0-23 -n 1)
      echo "$random_minute $random_hour * * * /renew.sh > /proc/1/fd/1 2>&1" > /etc/crontabs/nginx
      fi
  fi
fi

crond -b -l 5

tail -f /dev/null
