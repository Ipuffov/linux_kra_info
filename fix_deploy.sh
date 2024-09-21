tr -d '\r' < linux_kra_info.sh > linux_kra_info_fixed.sh
mv linux_kra_info_fixed.sh linux_kra_info.sh

tr -d '\r' < linux_kra_info_item.sh > linux_kra_info_item_fixed.sh
mv linux_kra_info_item_fixed.sh linux_kra_info_item.sh

tr -d '\r' < linux_kra_info_item.sql > linux_kra_info_item_fixed.sql
mv linux_kra_info_item_fixed.sql linux_kra_info_item.sql


chmod +x linux_kra_info.sh
chmod +x linux_kra_info_item.sh
chmod +x fix_deploy.sh




