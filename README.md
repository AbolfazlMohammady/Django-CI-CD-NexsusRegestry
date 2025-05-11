# Django-CI-CD-NexsusRegestry
Genreate Trafik pass

####
برای گرفتن Publik kye سرور باید این دستو رو بزنیم 
ssh-keygen -t rsa -b 4096 -C "abolfazlking22@gmail.com"
بعد ساخته شدن این باید بریم تو دایرکتوریش 
sudo ls -l /root/.ssh/
اینو میزنیم دایرکتوریش رو میبینیم
بعد دستور رو میزنیم که پابلیک کی رو ببینیم 
sudo cat /root/.ssh/id_rsa.pub
تو این قسمت کی اس اس اچ رو میده که باید وارد گیت هابمون کنیم
بعد وارد کردن کی تو قسمت اس اس اچ گیتهاب میایم کلون میگیریم از گیتمون
git clone git@github.com:AbolfazlMohammady/Django-CI-CD-NexsusRegestry.git
بعد از این باید از تو ریپازیتوری اصلی پروژه یک اسکریپت بش بنویسیم
hardening.sh
برای گرفتن هربار تغییرات از گیت
git pull origin
git pull origin main

برای اجرای بش ابتدا به دایرکتوری اون میریم و اینو میزنیم که اجازه اجرای دستورات بهش بدیم
chmod +x hardening.sh
 و بعد بش رو اجرا میکنیم 
nohup ./hardening.sh &
برای نمایش زنده لاگ ها
tail -f nohup.out

برای بررسی خروجی اسکریپت و مطمئن شدن از اینکه درست اجرا می‌شه، می‌تونی فایل nohup.out رو چک کنی
cat nohup.out
اگر با خطا مواجه شدید این دستور رو بزنید که ببیندید ایا لاگ پکیج دیگیری در حال اجرا هست یا نه
ps aux | grep apt
مثال:
root        4444  0.2  4.8 109276 95332 pts/0    T    17:52   0:00 apt upgrade -y
root       10359  0.0  1.8 109276 35816 pts/0    T    17:52   0:00 apt upgrade -y
root       10368  0.0  0.0   2800  1664 pts/0    T    17:52   0:00 sh -c -- test -x /usr/lib/needrestart/apt-pinvoke && /usr/lib/needrestart/apt-pinvoke -m u || true
root       10677  0.0  0.1   6544  2304 pts/0    S+   17:56   0:00 grep --color=auto apt

به نظر می‌رسد که در حال حاضر پروسه‌ای با شناسه‌ی 4444 در حال اجرای دستور apt upgrade است. این باعث شده که قفل مربوط به dpkg در /var/lib/dpkg/lock-frontend فعال شود و در نتیجه شما نمی‌توانید آن را باز کنید.

برای حل این مشکل، ابتدا باید این پروسه را متوقف کنید. می‌توانید با استفاده از دستور زیر این کار را انجام دهید:


sudo kill -9 4444
بعد از نصب اینارو میزنیم برای تست
docker-compose --version
docker --version

تست تغییر پورت 
sudo ss -tuln | grep 2226
sudo ss -tuln | grep 2226



