#!/bin/bash

# Make sure only root can run this script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#set default root directory for your websites
SITEDIR="/var/www/html/"
#apache folder with configs
apacheConfigs='/etc/apache2/sites-available/'
#output for your index.php
indexPHP='<?php phpinfo(); ?>';

#getting arguments
while getopts p:a:d: option
do
	case "${option}"
		in
		p) SITEPREFIX=${OPTARG};;
		a) SITEAMOUNT=$OPTARG;;
		d) SITEDIR=$OPTARG;;
	esac
done

# checking argumetns
if [ -z ${SITEPREFIX+x} ] || [ -z ${SITEAMOUNT+x} ]
	then
	echo "Prefix name and amount are required.
Usage:
-p	prefix name for your websites (use only string chars).
Example:
-p testsite

-a	amount of your websites (use only integers).
Example:
-a 3

So, Your command must look like this:
./addsite -p testsite -a 3

You'll get three websites:
testsite1/
testsite2/
testsite3/

The default website installation folder is:
/var/www/html/
If You want to change it, use -d option.
Example:
./addsite -p testsite -a 3 -d /var/www/mydir/"
fi

#checking the first character for "/"
firstchar=${SITEDIR:0:1}
if [ $firstchar != "/" ]
	then
	SITEDIR=$(readlink -f $SITEDIR)
fi

#checking the last character for "/"
lastchar=${SITEDIR:(-1)}
if [ $lastchar != "/" ]
	then
	SITEDIR=$SITEDIR/
fi

#A variable "site" is a counter for a cycle and website name
site=1
while [ $site -ne $[SITEAMOUNT+1] ]; do

	echo adding website $SITEPREFIX$site;
	apacheConfig=$apacheConfigs$SITEPREFIX$site.conf
	websiteDir=$SITEDIR$SITEPREFIX$site

	#Checks existence of config file
	if [ -f $apacheConfig ]; then
		echo "apache config file $apacheConfig exist! Website $SITEPREFIX$site; hasn't been created!"
		let site=site+1
		continue
	fi

	#Checks if the folder is empty or not
	if [ -d $websiteDir ]; then
		if [ "$(ls -A $websiteDir)" ]; then
		echo "website directory file $websiteDir is not empty! Website $SITEPREFIX$site; hasn't been created!"
		let site=site+1
		continue
		fi

	fi

	echo "<VirtualHost $SITEPREFIX$site:80>

ServerName $SITEPREFIX$site
DocumentRoot \"$SITEDIR$SITEPREFIX$site\"

ErrorLog "'${APACHE_LOG_DIR}'"/$SITEPREFIX$site/error.log
CustomLog "'${APACHE_LOG_DIR}'"/$SITEPREFIX$site/access.log combined

<Directory \"$SITEDIR$SITEPREFIX$site\">

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
	" > $apacheConfig

	echo "127.0.0.1	$SITEPREFIX$site" >> /etc/hosts

	mkdir /var/log/apache2/$SITEPREFIX$site/
	echo $SITEDIR$SITEPREFIX$site
	mkdir -p $SITEDIR$SITEPREFIX$site
	echo $indexPHP > $SITEDIR$SITEPREFIX$site/index.php

	# enabling website with suppressing output
	a2ensite $SITEPREFIX$site.conf > /dev/null

	let site=site+1
done

service apache2 restart
