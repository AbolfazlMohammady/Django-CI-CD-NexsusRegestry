# Django-CI-CD-NexusRegistry Guide

---

# قبل هر کاری بعد وارد شدن

```
sudo apt update && sudo apt upgrade -y

```

#### 1. مراحل دریافت Public SSH Key

### 1.1 ایجاد کلید SSH

برای دریافت Public Key سرور، ابتدا SSH Key جدید ایجاد می‌کنیم. دستور زیر را وارد کنید:

```
ssh-keygen -t rsa -b 4096 -C "abolfazlking22@gmail.com"
```

### 1.2 مشاهده کلید‌ها

پس از اجرای دستور بالا، کلید SSH شما در مسیر `/root/.ssh/` ذخیره می‌شود. برای مشاهده فایل‌ها و کلید خود، از دستور زیر استفاده کنید:

```bash
sudo ls -l /root/.ssh/
```

### 1.3 مشاهده Public Key

برای مشاهده Public Key، دستور زیر را وارد کنید:

```bash
sudo cat /root/.ssh/id_rsa.pub
```

کلید SSH که به دست آوردید باید در تنظیمات GitHub خود وارد کنید.

---

## 2. اضافه کردن SSH Key به GitHub

1. به حساب GitHub خود وارد شوید.
2. به بخش **Settings** بروید و **SSH and GPG Keys** را انتخاب کنید.
3. روی **New SSH Key** کلیک کنید و Public Key که در مرحله قبلی دریافت کرده‌اید را وارد کنید.

---

## 3. کلون کردن ریپازیتوری از GitHub

پس از اضافه کردن کلید SSH به GitHub، می‌توانید پروژه را از گیت‌هاب کلون کنید:

```bash
git clone git@github.com:AbolfazlMohammady/Django-CI-CD-NexsusRegestry.git
```

---

## 4. اسکریپت `hardening.sh`

برای دریافت تغییرات از گیت و اعمال آن‌ها در سرور، یک اسکریپت بنام `hardening.sh` ایجاد می‌کنیم. اسکریپت شامل دستوراتی برای انجام بروزرسانی‌های امنیتی و پیکربندی است.

---

### 4.1 گرفتن آخرین تغییرات از گیت

در داخل دایرکتوری پروژه، اسکریپت را اجرا می‌کنیم تا آخرین تغییرات را از گیت دریافت کنیم:

```bash
git stash
git pull origin main
```

```
git add .
git commit -m "Save local changes before pull"
git pull origin main
```

```
git fetch origin
git reset --hard origin/main
```

### 4.2 دادن اجازه به اسکریپت برای اجرا

قبل از اجرای اسکریپت، باید به آن اجازه اجرا بدهیم:

```bash
chmod +x hardening.sh
```

### 4.3 اجرای اسکریپت

برای اجرای اسکریپت به صورت پس‌زمینه، از دستور زیر استفاده کنید:

```bash
nohup ./hardening.sh &
```

### 4.4 نمایش زنده لاگ‌ها

برای مشاهده لاگ‌های زنده اسکریپت، از دستور زیر استفاده کنید:

```bash
tail -f nohup.out
```

### 4.5 بررسی خروجی اسکریپت

برای بررسی نتایج و خروجی اسکریپت، فایل `nohup.out` را می‌توانید بررسی کنید:

```bash
cat nohup.out
```

### 4.6 بررسی پکیج در حال اجرا

اگر در هنگام اجرای اسکریپت با خطا مواجه شدید، ممکن است که پروسه‌ای در حال اجرای دستور `apt upgrade` باشد. برای بررسی این موضوع، از دستور زیر استفاده کنید:

```bash
ps aux | grep apt
```

### 4.7 توقف پروسه در حال اجرا

اگر یک پروسه با شناسه خاص در حال اجرای دستور `apt upgrade` است، باید آن را متوقف کنید. دستور زیر برای این کار استفاده می‌شود:

```bash
sudo kill -9 4444
```

---

## 5. نصب و تست Docker

برای نصب Docker و Docker Compose، از دستورات زیر استفاده کنید:

```bash
docker-compose --version
docker --version
```

---

## 6. تست تغییر پورت SSH

برای تغییر پورت SSH به پورت دلخواه (مثلاً 2226)، ابتدا باید پورت را تست کنید تا مطمئن شوید در حال استفاده است:

```bash
sudo ss -tuln | grep 2226
```

---

## 7. تغییر پورت SSH

بعد از تغییر پورت در فایل پیکربندی SSH (`/etc/ssh/sshd_config`)، برای اعمال تغییرات باید سرویس SSH را دوباره راه‌اندازی کنید:

```bash
sudo systemctl restart ssh
```

### 🎯 مراحل راه‌اندازی Proxsi روی VPS (ساده و کاربردی):

#### 1. نصب کانفیگ شکن

```
shecan.ir
```

وارد سایت شکن میشیم و یکی از دی ان اس هاشو کپی میکنیم

#### 1.2 اجرای دستور

```
vim /etc/resolv.conf

```

بعد ار وارد شدن نام سرور رو عوض میکینم

##### nameserver DNS

DNS که از شکن اوردیم

#### 1.3 اجرای دستور داکر

```
docker pull nginx
```

### اجرای دستورات  داکر

```
docker-compose down
```

```
docker-compose up -d --build
```

### ✅ قدم‌به‌قدم راه‌اندازی پروژه Django در کانتینر

#### 1. کلون کردن پروژه از گیت:

```bash
git clone git@github.com:Mortezakoohjani/TorbatKar-Back.git
cd TorbatKar-Back
```

#### 2. ساخت و اجرای کانتینر:

```bash
docker-compose up --build -d
```

#### 3. ورود به کانتینر:

```bash
docker exec -it torbatkar-back-web-1 sh
```

تو ترمینال می‌بینی چیزی شبیه این:

```
/app #
```

#### 4. اعمال مایگریشن‌ها:

حالا داخل کانتینر هستی، پس می‌زنی:

```bash
python manage.py migrate
```

#### 5. ساخت یوزر ادمین (اگه نیاز باشه):

```bash
python manage.py createsuperuser
```

---

### 📌 نکات اضافه:

* اگه می‌خوای پروژه رو از بیرون ببینی:

  * توی مرورگر بزن:
    ```
    http://SERVER_IP:8000
    ```

  یا اگه لوکال هستی:

  ```
  http://localhost:8000
  ```
* اگه پورتو عوض کرده باشی مثلاً ۸۰۰۱، اون پورتو بزن:

  ```
  http://SERVER_IP:8001
  ```

---

اگه بخوای پروژه رو آپدیت کنی:

#### 6. برای pull کردن تغییرات:

```bash
git pull origin main
docker-compose down
docker-compose up --build -d
```

### اگه بخوای پروژه رو آپدیت کنی:

#### 6. برای pull کردن تغییرات:

```bash
git pull origin main
docker-compose down
docker-compose up --build -d
```

---

## برای ویرایش فایل کانفیگ

```
sudo nano /etc/ssh/sshd_config

```

## وقتی که پورت را عوض کردید و کار نکرد

```
sudo apt update
sudo apt install ufw -y

```

```
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status verbose

```

## 🧹 اگه بخوای پاک کنی:

برای پاک کردن یکی از قوانین `ufw`:

### 1. نمایش لیست با شماره‌ها:

```bash
sudo ufw status numbered
```

خروجی مثلاً می‌شه:

```
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
```

### 2. حذف قانون با شماره:

مثلاً حذف قانون دوم (IPv6):

```bash
sudo ufw delete 2
```
