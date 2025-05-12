#!/bin/bash

# ---------- رنگ‌ها ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------- تنظیمات قابل تغییر ----------
NEW_USER="root"                         # 👤 نام کاربر جدید
SSH_KEY="MUYIpbJHLGbpe+OlKqZsoUgUXHYFP5kqBgp/dE2TCnw"          # 🔐 کلید عمومی SSH
TIMEZONE="Asia/Tehran"                     # 🌍 تایم‌زون
# SSH_PORT="2263"                             # 🔁 پورت جدید SSH

LOG_FILE="hardening.log"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# ---------- توابع ----------
log() { echo -e "${GREEN}[✔] $1${NC}" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!] $1${NC}" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[✖] $1${NC}" | tee -a "$LOG_FILE"; exit 1; }

# ---------- شروع ----------
log "🚀 شروع سخت‌سازی سرور..."

# بروزرسانی سیستم
log "🔄 بروزرسانی سیستم..."
apt update && apt upgrade -y || error "❌ خطا در بروزرسانی"

# ایجاد کاربر جدید
log "👤 ایجاد کاربر جدید: $NEW_USER"
useradd -m -s /bin/bash $NEW_USER || warn "ممکن است کاربر وجود داشته باشد"
usermod -aG sudo $NEW_USER

# کلید SSH برای کاربر
log "🔐 اضافه کردن کلید SSH"
mkdir -p /home/$NEW_USER/.ssh
echo "$SSH_KEY" > /home/$NEW_USER/.ssh/authorized_keys
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
chmod 700 /home/$NEW_USER/.ssh
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

# تنظیم SSH
log "🛡 تنظیم SSH: غیرفعال کردن ورود روت و پسورد"
sed -i "s/^#*Port.*/Port $SSH_PORT/" $SSH_CONFIG_FILE
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG_FILE
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG_FILE
systemctl reload sshd
log "🔁 SSH روی پورت $SSH_PORT فعال شد"

# فعال‌سازی فایروال
log "🧱 فعال‌سازی UFW و اجازه به پورت جدید SSH"
apt install -y ufw
ufw allow $SSH_PORT/tcp
ufw --force enable

# نصب ابزارهای امنیتی
log "🔒 نصب ابزارهای امنیتی Fail2Ban و پایه"
apt install -y fail2ban curl git unzip htop

# تنظیم تایم‌زون
log "🌐 تنظیم تایم‌زون به $TIMEZONE"
timedatectl set-timezone $TIMEZONE

# نصب Docker
log "🐳 نصب Docker"
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker $NEW_USER
log "✅ Docker نصب شد و کاربر $NEW_USER به گروه آن اضافه شد"

# نصب Docker Compose (نسخه دستی)
log "⚙️ نصب Docker Compose"
DOCKER_COMPOSE_VERSION="2.24.2"
curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

log "✅ نصب کامل شد. لطفاً پس از تست، ارتباط از پورت جدید SSH را بررسی کن."

