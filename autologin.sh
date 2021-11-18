#!/bin/zsh

username=""
password=""

auth() {
  curl -s --connect-timeout 10 --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --compressed --header "Accept-Language: en-US,en;q=0.9" --header "Cache-Control: max-age=0" --header "Connection: keep-alive" --header "Origin: http://172.20.20.1:801" --header "Referer: http://172.20.20.1:801/srun_portal_pc.php?ac_id=3&" --header "Upgrade-Insecure-Requests: 1" --user-agent "Mozilla/5.0 (Windows; U; Windows NT 4.0) AppleWebKit/533.43.4 (KHTML, like Gecko) Version/4.0.5 Safari/533.43.4" --data-binary "action=login&ac_id=3&user_ip=&nas_ip=&user_mac=&url=&username=${username}&password=${password}" "http://172.20.20.1:801/srun_portal_pc.php?ac_id=3&" > /dev/null
  stat_code=$(curl -s -w %{http_code} --connect-timeout 5 "https://www.google.cn/generate_204")
  if [ "${stat_code}" = "204" ]; then
    echo "Logged in"
  else
    echo "Login failed"
  fi
}

unauth() {
  stat_code=$(curl -s --connect-timeout 5 --compressed --header "Accept-Language: en-US,en;q=0.9" --header "Connection: keep-alive" --header "Origin: http://172.20.20.1:801" --header "Referer: http://172.20.20.1:801/srun_portal_pc.php?ac_id=3&" --user-agent "Mozilla/5.0 (Windows; U; Windows NT 4.0) AppleWebKit/533.43.4 (KHTML, like Gecko) Version/4.0.5 Safari/533.43.4" --header "X-Requested-With: XMLHttpRequest" --data-binary "action=logout&username=${username}&password=${password}&ajax=1" "http://172.20.20.1:801/include/auth_action.php")
  if [ "${stat_code}" = "网络已断开" ]; then
    echo "Logged out"
  elif [ "${stat_code}" = "您似乎未曾连接到网络..." ]; then
    echo "Not login"
  else
    echo "Logout failed"
  fi
}

while getopts "io" opt; do
  case $opt in
    i)
      auth
      ;;
    o)
      unauth
      ;;
    ?)
      echo "Usage: -i for login, -o for logout" 
      ;;
  esac
done
