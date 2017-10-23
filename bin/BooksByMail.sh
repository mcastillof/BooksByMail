#!/bin/sh

BOOKS=/mnt/us/documents/BooksByMail
BBM=/mnt/us/extensions/BooksByMail
CONFIG_FILE=$BBM/etc/offlineimap.conf
ATTACHMENTS=$BBM/tmp/attachments
EXTENSIONS=$BBM/etc/ebooksFormats
PASSPHRASE=`cat $BBM/etc/passphrase`

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
sync

COUNTER=0

for FILE in $ATTACHMENTS/*
do
	if [ -z "$FILE" ] ; then
		break
	fi

	if [ "$FILE" = "$ATTACHMENTS/*" ] ; then
		break
	fi

	echo "Attachment: $FILE"

	FILENAME_LOWERCASE=$(basename `echo "$FILE" | tr '[A-Z]' '[a-z]'`)
	FILE_EXTENSION=${FILENAME_LOWERCASE##*.}
	FILENAME=$(basename `echo "$FILE"`)
	
	if [ $FILE_EXTENSION == "gpg" ]
	then
	    LD_LIBRARY_PATH=$BBM/lib/ $BBM/bin/gpg --passphrase "$PASSPHRASE" --batch --yes --output ${FILE%.*} --decrypt ${FILE}
	    if [ $? -ne 0 ]; then
	        echo "Error trying to decrypt file $FILE"
	        continue
	    fi
	    FILENAME="${FILE%.*}" #remove .gpg extension
	    FILE_EXTENSION="${FILENAME%.*}"
	fi
	
	#checks if the file has an ebook extension. In that case it moves the file to $BOOKS folder
	while IFS='' read -r EXT || [[ -n "$EXT" ]]; do
		if [[ $FILE_EXTENSION == "$EXT" ]]; then
			if [ ! -f $BOOKS/$FILENAME ] ; then
				mv $FILE $BOOKS
				if [ ! -f $BOOKS/$FILENAME ] ; then
					break
				fi
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
