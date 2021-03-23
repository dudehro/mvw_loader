#!/bin/bash

SCRIPT_PATH=$(realpath $0)
SCRIPT_PATH=$(dirname "$SCRIPT_PATH")
echo "$SCRIPT_PATH"

while read feed
do
	cd "$SCRIPT_PATH"

	FEED_URL=$(echo "$feed" | cut -d ';' -f 1)
	FEED_FOLDER=$(echo "$feed" | cut -d ';' -f 2)

	if [ ! -d "$FEED_FOLDER" ]; then
		mkdir -p "$FEED_FOLDER"
	fi
	cd "$FEED_FOLDER"

	FEED_CONTENT=$(curl ${FEED_URL})
	FEED_LENGTH=$(echo ${FEED_CONTENT} | xpath -q -e 'count(rss/channel/item)')
	i=0
	while [ "$i" -lt "$FEED_LENGTH" ];
	do
		i=$((i+1))
		ITEM_URL=$(echo ${FEED_CONTENT} | xpath -q -e 'rss/channel/item['$i']/link/text()')
		ITEM_TITLE=$(echo ${FEED_CONTENT} | xpath -q -e 'rss/channel/item['$i']/title/text()')
		FILE_NAME="$ITEM_TITLE.mp4"
		echo "Lade Item $i von $FEED_LENGTH"
		echo ${ITEM_TITLE}
		if [ ! -f "$FILE_NAME" ]; then
			wget -O "$FILE_NAME" "$ITEM_URL"
			if [ ! $? -eq 0 ]; then
				echo "wget endet mit Fehler, Datei wird gelöscht"
				rm "$FILE_NAME"
			fi
		fi
	done
done<feeds.txt


exit 0
