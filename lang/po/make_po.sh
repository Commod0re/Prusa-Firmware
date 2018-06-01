#!/bin/sh
#
# make_po.sh - multi-language support script
#  for generating lang_xx.po
#
SRCDIR="../../Firmware"
#
LANG=$1
if [ -z "$LANG" ]; then LANG=cz; fi
#

if [ "$LANG" == "all" ]; then
 ./make_po.sh cz
 ./make_po.sh de
 ./make_po.sh es
 ./make_po.sh it
 ./make_po.sh pl
 exit 0
fi

echo "make_po.sh started" >&2
echo " selected language=$LANG" >&2

#remove output file if exists
if [ -e lang_$LANG.po ]; then rm lang_$LANG.po; fi

lang_name=$(\
 case "$LANG" in
  *en*) echo "English" ;;
  *cz*) echo "Czech" ;;
  *de*) echo "German" ;;
  *es*) echo "Spanish" ;;
  *it*) echo "Italian" ;;
  *pl*) echo "Polish" ;;
 esac)

lang_short=$(\
 case "$LANG" in
  *en*) echo "en" ;;
  *cz*) echo "cs" ;;
  *de*) echo "de" ;;
  *it*) echo "it" ;;
  *es*) echo "es" ;;
  *pl*) echo "pl" ;;
 esac)

po_date=$(date)

#write po header
echo "# Translation of Prusa-Firmware into $lang_name." > lang_$LANG.po
echo "#" >> lang_$LANG.po
echo 'msgid ""' >> lang_$LANG.po
echo 'msgstr ""' >> lang_$LANG.po
echo '"MIME-Version: 1.0\n"' >> lang_$LANG.po
echo '"Content-Type: text/plain; charset=UTF-8\n"' >> lang_$LANG.po
echo '"Content-Transfer-Encoding: 8bit\n"' >> lang_$LANG.po
echo '"Language: '$lang_short'\n"' >> lang_$LANG.po
echo '"Project-Id-Version: Prusa-Firmware\n"' >> lang_$LANG.po
echo '"POT-Creation-Date: '$po_date'\n"' >> lang_$LANG.po
echo '"PO-Revision-Date: '$po_date'\n"' >> lang_$LANG.po
echo '"Language-Team: \n"' >> lang_$LANG.po
echo '"X-Generator: Poedit 2.0.7\n"' >> lang_$LANG.po
echo '"X-Poedit-SourceCharset: UTF-8\n"' >> lang_$LANG.po
echo '"Last-Translator: \n"' >> lang_$LANG.po
echo '"Plural-Forms: nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;\n"' >> lang_$LANG.po
echo >> lang_$LANG.po

#list .cpp, .c and .h files
files=$(ls "$SRCDIR"/*.cpp "$SRCDIR"/*.c "$SRCDIR"/*.h)

num_texts=$(grep '^#' -c ../lang_en_$LANG.txt)
num_texts_nt=$(grep '^\"\\x00\"' -c ../lang_en_$LANG.txt)
echo " $num_texts texts, $num_texts_nt not translated" >&2

#loop over all messages
s0=''
s1=''
s2=''
num=1
cat ../lang_en_$LANG.txt | sed "s/\\\\/\\\\\\\\/g;s/^#/#: /" | while read -r s; do
 if [ "$s" == "" ]; then
  echo "  processing $num of $num_texts" >&2
  if [ "$s0" == "\"\\\\x00\"" ]; then
   search=$(/bin/echo -e "$s1")
   found=$(grep -m1 -n -F "$search" $files | head -n1 | cut -f1-2 -d':' | sed "s/^.*\///")
   echo "#: $found"
   echo "#, fuzzy"
   /bin/echo -e "msgid $s1"
   echo 'msgstr ""'
   echo
  else
   search=$(/bin/echo -e "$s1")
   found=$(grep -m1 -n -F "$search" $files | head -n1 | cut -f1-2 -d':' | sed "s/^.*\///")
   echo "#: $found"
   /bin/echo -e "msgid $s1"
   /bin/echo -e "msgstr $s0"
   echo
  fi
  num=$((num+1))
 fi
 s2=$s1
 s1=$s0
 s0=$s
done >> lang_$LANG.po

#replace LF with CRLF
sync
sed -i 's/$/\r/' lang_$LANG.po

echo "make_po.sh finished" >&2
#read
exit 0
