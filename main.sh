#!/bin/bash

# ------------------------- Variables -------------------------
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
DOMAIN_NAME="devopshobbieslearning.com"
SSH_PORT=1242
BAC_DIR="/opt/backup/files_$NOW"
DOCKER_DEST="/etc/systemd/system/docker.service.d/"
MIRROR_REGISTRY="https://docker.jamko.ir"

# ------------------------- Time Info -------------------------
echo "Info: ------------------------------------"
echo -e "DNS Address:\n$(cat /etc/resolv.conf)"
echo -e "Hostname: $(hostname)"
echo -e "OS Info:\n$(lsb_release -a 2>/dev/null)"
echo -e "SSH Port: $SSH_PORT"
echo "------------------------------------------"

# --------------------- Backup Directory ----------------------
mkdir -p "$BAC_DIR"

# --------------------- System Update & Tools -----------------
apt update && apt upgrade -y
apt remove -y snapd && apt purge -y snapd
apt install -y wget git vim nano bash-completion curl htop iftop jq ncdu unzip net-tools dnsutils \
               atop sudo ntp fail2ban software-properties-common apache2-utils tcpdump telnet axel

# --------------------- Host Configuration --------------------
hostnamectl set-hostname "$DOMAIN_NAME"

# --------------------- Timeout Settings ----------------------
cat <<EOF > /etc/profile.d/timout-settings.sh
#!/bin/bash
TMOUT=300
readonly TMOUT
export TMOUT
EOF

# --------------------- Sysctl Configuration ------------------
cp /etc/sysctl.conf "$BAC_DIR/sysctl.conf"
cat <<EOF >> /etc/sysctl.conf
# Custom Network and Security Settings
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.netfilter.nf_conntrack_tcp_timeout_established=3600
fs.file-max = 500000
vm.max_map_count=262144
net.ipv4.ip_nonlocal_bind = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
fs.suid_dumpable = 0
kernel.core_uses_pid = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.conf.all.log_martians = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.conf.all.rp_filter=1
kernel.yama.ptrace_scope=1
EOF
sysctl -p

# --------------------- Limits Configuration ------------------
echo -e "* soft nofile 2048\n* hard nofile 2048\n* soft nproc 2048\n* hard nproc 2048\nroot soft nofile 65535\nroot hard nofile 65535\nroot soft nproc 65535\nroot hard nproc 65535" > /etc/security/limits.conf
modprobe br_netfilter

# --------------------- Service Management --------------------
for svc in postfix firewalld ufw; do
  systemctl stop "$svc"
  systemctl disable "$svc"
  systemctl mask "$svc"
done

# --------------------- SSH Banner & Config -------------------
cat <<EOF > /etc/issue.net
------------------------------------------------------------------------------
* WARNING.....                                                               *
* You are accessing a secured system and your actions will be logged along   *
* with identifying information. Disconnect immediately if you are not an     *
* authorized user of this system.                                            *
------------------------------------------------------------------------------
EOF

cp /etc/ssh/sshd_config "$BAC_DIR/sshd_config"
cat <<EOF > /etc/ssh/sshd_config
Port $SSH_PORT
ListenAddress 0.0.0.0
LogLevel VERBOSE
PermitRootLogin yes
MaxAuthTries 3
MaxSessions 2
PasswordAuthentication yes
ChallengeResponseAuthentication no
GSSAPIAuthentication no
UsePAM yes
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
TCPKeepAlive no
Compression no
ClientAliveInterval 10
ClientAliveCountMax 10
UseDNS no
Banner /etc/issue.net
AcceptEnv LANG LC_*
AllowUsers root
AllowGroups root
EOF
sshd -t && systemctl enable sshd && systemctl restart sshd && echo "SSHD Running"

# --------------------- Fail2Ban Configuration ----------------
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i '/^\[sshd\]/a enabled = true' /etc/fail2ban/jail.local
sed -i "s/port\s*=\s*ssh/port = $SSH_PORT/g" /etc/fail2ban/jail.local
systemctl enable fail2ban && systemctl restart fail2ban && fail2ban-client status

# --------------------- IPTables Configuration ----------------
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
cp /etc/iptables/rules.v4 "$BAC_DIR"
cat <<EOF > /etc/iptables/rules.v4
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
-A PREROUTING -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
-A PREROUTING -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
-A PREROUTING -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
-A PREROUTING -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
-A PREROUTING -p tcp -m tcp --tcp-flags FIN,ACK FIN,ACK -j DROP
COMMIT
EOF
