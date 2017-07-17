#!/bin/sh

BOOKS=/mnt/us/documents/BooksByMail
BBM=/mnt/us/extensions/BooksByMail
CONFIG_FILE=$BBM/etc/offlineimap.conf
ATTACHMENTS=$BBM/tmp/attachments
EXTENSIONS=$BBM/etc/ebooksFormats

. $BBM/bin/libkh5

mkdir -p $BOOKS
mkdir -p $ATTACHMENTS

kh_msg "  * Fetching emails. This may take a while." I v

#download ALL mails that are recent than 'maxage' option in the config file $BBM/etc/offlineimap.conf
python $BBM/bin/offlineimap.py -c $CONFIG_FILE

#unpack message and attachments in MIME
kh_msg "  * Unpacking attachments." I v
$BBM/bin/munpack -t -C $ATTACHMENTS -f $BBM/tmp/*/*/*

kh_msg "  * Copying new books." I v

COUNTER=0

for F in $ATTACHMENTS/*
do
	if [ -z "$F" ] ; then
		break
	fi

	if [ "$F" = "$ATTACHMENTS/*" ] ; then
		break
	fi

	echo "Attachment: $F"

	#lowercase the filename, needs an aux filename as this is a fat32 filesystem
	mv $F $ATTACHMENTS/aux
	FL=$(basename `echo "$F" | tr '[A-Z]' '[a-z]'`)
	mv $ATTACHMENTS/aux $ATTACHMENTS/$FL

	#checks if the file has an ebook extension. In that case it moves the file to $BOOKS folder
	while IFS='' read -r EXT || [[ -n "$EXT" ]]; do
		if [[ ${FL##*.} == "$EXT" ]]; then
			if [ ! -f $BOOKS/$FL ] ; then
				mv $ATTACHMENTS/$FL $BOOKS
				COUNTER=$((COUNTER+1))
			fi
		fi
	done < $EXTENSIONS
done

if [ $COUNTER -eq 1 ] ; then
	kh_msg "  * $COUNTER new book." I v
else
	kh_msg "  * $COUNTER new books." I v
fi

#remove tmp folder
rm -r $BBM/tmp/*
