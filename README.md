# BooksByMail
A KUAL extension for Kindle PW1 to receive books over email without the need of an Amazon account.

V0.03 beta.

## Requirements
* You need a jailbroken Kindle Paperwhite 1 with v5.3.9 fw (may work with other models and firmwares, but not tested).
* NiLuJe's Python update installed in the device.
* KUAL installed.


## Installation
* Copy using a USB cable the folder 'bookbymail' into the folder 'extensions/'. If you want to do it over the network, copy the folder to '/mnt/us/extensions/'


## Configuration
* Edit the file BookByMail/etc/offlineimap.conf. Set your email provider, your account and password. Also change the parameter 'maxage' if you want to download books from mails that are older than two days. Keep in mind that you need enough space to download all those mails (they are removed after the operation is complete).
* Edit the file BookByMail/etc/ebooksFormats to set the file extensions of the books that you want to download from your email to the device.
* Store your passphrase to decrypt files in BookByMail/etc/passphrase.

## How to send books to your device?
* Use Calibre feature to send books over mail or just send you an email using your email client. There is no need for a subject or a body. Just attach your ebook. The filename of the ebook must be a valid FAT32 filename, so avoid strange symbols.
* In your Kindle, open KUAL, and tap on BooksByMail.
* It will take a little time to fetch the emails and unpack the attachments. Afterwards books will end up in documents/BooksByMail folder.

## How to encrypt a book?
You may use GnuPG to encrypt the file. Just be sure to set the passhphrase in BookByMail/etc/passphrase to decrypt in your kindle.

To encrypt a book:

`gpg --cipher-algo AES256 --output a.txt.gpg --symmetric a.txt`

From there, just send filename.mobi.gpg to your mail.
The extension '.gpg' is needed to know that the file is encrypted, and the extension '.mobi' (or another extension of supported books) is needed to know that the file is a supported book.

## Restrictions
* Only IMAP servers are supported, so, don't try POP servers.
* Keep in mind that the max size of the book will be limited by the size of an attachment in your email account.
* As the storage is in a FAT32 filesystem, don't use strange symbols in the filename of the ebook.


## Contribute
* Report if it works in other Kindle model/firmware
* Report bugs
* Send patches
