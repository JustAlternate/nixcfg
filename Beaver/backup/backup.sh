# Bash script to auto backup my services data to AWS s3 glacier.
# --------------------------------------------------------------
aws s3 ls s3://my-beaver-backup

OBJECTS_PATH=("/var/www/justalternate.fr/" "/var/lib/docker/volumes/owncloud_mysql/" "/var/lib/docker/volumes/owncloud_files/" "/var/lib/docker/volumes/open-webui_open-webui/" "/var/lib/docker/volumes/openwebui-monitor_postgres_data")
OBJECTS_NAME=("justalternate.fr.zip" "owncloud_mysql.zip" "owncloud_files.zip" "open-webui_open-webui.zip" "openwebui-monitor_postgres_data.zip")

for i in "${!OBJECTS_PATH[@]}"; do
	echo "Backup ${OBJECTS_PATH[$i]}"
	zip "${OBJECTS_NAME[$i]}" "${OBJECTS_PATH[$i]}"	-r
	if [ ! -f ./"${OBJECTS_NAME[$i]}" ]; then
		echo "Error ${OBJECTS_NAME[$i]} backup is not here !!"
		touch /root/ERROR_WHEN_EXECUTING_BACKUP #TODO:IMPLEMENT proper alerting system
		exit 1
	fi
	aws s3 rm s3://my-beaver-backup/"${OBJECTS_NAME[$i]}"
	aws s3 cp "${OBJECTS_NAME[$i]}" s3://my-beaver-backup/"${OBJECTS_NAME[$i]}" --storage-class GLACIER
	rm "${OBJECTS_NAME[$i]}"
	echo "Done"
done

echo "Backup planka ..."
/root/nixcfg/Beaver/services/planka/backup/./backup.sh
if [ ! -f ./planka-backup.tgz ]; then
	echo "Error planka file is not here !!"
	touch /root/ERROR_WHEN_EXECUTING_BACKUP #TODO:IMPLEMENT proper alerting system
	exit 1
fi
aws s3 rm s3://my-beaver-backup/planka-backup.tgz
aws s3 cp planka-backup.tgz s3://my-beaver-backup/planka-backup.tgz --storage-class GLACIER
rm planka-backup.tgz
echo "Done"

aws s3 ls s3://my-beaver-backup
