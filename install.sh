#!/bin/bash

# export env vars
export $(egrep -v '^#' .env | xargs)

# clear destination
echo "Clear destination folder"
while true; do
    read -p "Do you wish to remove destination folder "$M2_DESTINATION_FOLDER"?" yn
    case $yn in
        [Yy]* ) echo "Removing "$M2_DESTINATION_FOLDER" ..."; sudo chmod -R 777 $M2_DESTINATION_FOLDER; rm -rf "$M2_DESTINATION_FOLDER"; break;;
        [Nn]* ) echo "Exit installation script"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# clear db
echo "Clear db"
while true; do
    read -p "Do you wish to clear database "$DB_NAME"?" yn
    case $yn in
        [Yy]* ) echo "Clearing "$DB_NAME" ..."; mysql -u $DB_USERNAME -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS "$DB_NAME"; CREATE DATABASE "$DB_NAME; break;;
        [Nn]* ) echo "Exit installation script"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#copy magento files to destination
echo "Copying magento files ..."
cp -R $M2_SOURCE_FOLDER $M2_DESTINATION_FOLDER

# install magento
echo "Install Magento via CLI"
cd $M2_DESTINATION_FOLDER
bin/magento setup:install \
--cleanup-database \
--use-secure=1 \
--use-secure-admin=1 \
--base-url-secure=$BASE_URL \
--db-host=localhost \
--db-name=$DB_NAME \
--db-user=$DB_USERNAME \
--db-password=$DB_PASSWORD \
--backend-frontname=admin \
--admin-firstname=Admin \
--admin-lastname=Admin \
--admin-email=$M2_ADMIN_EMAIL \
--admin-user=$M2_ADMIN_EMAIL \
--admin-password=$M2_ADMIN_PASSWORD \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1

# disable static content versioning
echo "Disable static content versioning"
bin/magento config:set dev/static/sign 0

# fix permissions
echo "Fix permissions"
sudo chmod -R 777 pub var generated

# clear cache
echo "Clear cache"
bin/magento cache:clean
bin/magento cache:flush

# upgrade
echo "Upgrade"
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f

# load fixtures
echo "Load fixtures"
bin/magento setup:performance:generate-fixtures setup/performance-toolkit/profiles/ce/small.xml
bin/magento config:set catalog/frontend/flat_catalog_category 1
bin/magento config:set catalog/frontend/flat_catalog_product 1

# clear cache
echo "Clear cache"
bin/magento cache:clean
bin/magento cache:flush

# set developer mode
echo "Set developer mode"
bin/magento deploy:mode:set developer

# fix permissions
echo "Fix permissions"
sudo chmod -R 777 pub var generated

echo "Installation finished!"