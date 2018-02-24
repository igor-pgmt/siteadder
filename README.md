# Apache website adder
The script creates the needed amount of website folders and config files for them, then it enables sites and restarts Apache. The script allows configuring several websites in Apache very fast. You must run it as root or be using sudo.

## What the script does
0. Checks existence of root privileges and needed arguments, then the creating of sites occures.<br />In each iteration the script does:
1. Checks existence of a configuration in the directory /etc/apache2/sites-available/ (you can change this dir at the beginning of the script file) and if the current website directory is empty or not. If the directory of an iteration doesn't exist it will be created; If the directory is not empty or Apache config file exists, current website creation will be missed.
2. Creates the site's direcotry using  the name of the site. It the directory the script creates index.php with phpinfo() function. You can change the output for the index.php files at the beginning of the script.
3. Adds relevant config into Apache.

The script creates apache configuration files like this:
```apache
<VirtualHost testsite1:80>

ServerName testsite1
DocumentRoot "/var/www/html/testsite1"

ErrorLog ${APACHE_LOG_DIR}/testsite1/error.log
CustomLog ${APACHE_LOG_DIR}/testsite1/access.log combined

<Directory "/var/www/html/testsite1">

    # use mod_rewrite for pretty URL support
    RewriteEngine on
    # If a directory or a file exists, use the request directly
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    # Otherwise forward the request to index.php
    RewriteRule . index.php
	# allow access to the directory
	Require all granted
   
    # ...other settings...
</Directory>

</VirtualHost>
```
You can change this template in the script file as you wish.

3. After generation of all configs, the script restarts Apache.

## Installation
1. Download the script from Github or clone it:
```bash
git clone https://github.com/igor-pgmt/siteadder.git
```

2. You can start use it from a folder but it would be useful to move it somewhere:
```bash
mv siteadder/siteadder.sh ~/myscripts/siteadder.sh
```
Make sure that You can execute the sript:
```bash
chmod +x ~/myscripts/siteadder.sh
```

3. Create an alias for the script. For example "wadd" :
```bash
echo 'alias wadd="~/myscripts/siteadder.sh"' >> ~/.bashrc
```

OR create a symlink to your file:
```bash
sudo ln -s /home/user/myscripts/siteadder.sh /usr/bin/wadd
```

## Usage
**Required arguments:**<br />
**-a** amount of websites to be created.<br />
**-p** name prefix of websites to be created.<br />
<br />
**Not required arguments:**<br />
**-d** root directory for websites. By default will de used /var/www/html/<br />
<br />
**Examples:**
```bash
./siteadder -a 3 -p testsite 
```
↑This command will configure three sites:<br />
/var/www/html/testsite1/<br />
/var/www/html/testsite2/<br />
/var/www/html/testsite3/<br />

```bash
./siteadder -a 2 -p testsite -d myDir
```
↑This command will create directory ./mydir and create two sites in current directory:<br />
./myDir/testsite1<br />
./myDir/testsite2<br />
