mkdir -p /storage/emulated/0/dovahtinvaak
exec 2>/storage/emulated/0/dovahtinvaak/dovahtinvaak-install-verbose.log

mkdir $TMPDIR/tools
mkdir -p $TMPDIR/system/etc
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH 2>&1
unzip -o "$ZIPFILE" 'tools/*' -d $TMPDIR 2>&1
unzip -o "$ZIPFILE" 'system/*' -d $TMPDIR 2>&1
mv $TMPDIR/tools/busybox-$ARCH32 $TMPDIR/tools/busybox 2>&1
chmod 0755 $TMPDIR/tools/busybox
SKIPUNZIP=1

REPLACE="
"

set_permissions() {
  : # Remove this if adding to this function

  # Note that all files/folders in magisk module directory have the $MODPATH prefix - keep this prefix on all of your files/folders
  # Some examples:

  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)

  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)

  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644
}

set_busybox() {
  if [ -x "$1" ]; then
    for i in $(${1} --list); do
      if [[ "$i" != 'zip' && "$i" != 'sleep' ]]; then
        alias "$i"="${1} $i" >/dev/null 2>&1
      fi
    done
    _busybox=true
    _bb=$1
  fi
}
_busybox=false

if $_busybox; then
  true
elif [ -d /sbin/.magisk/modules/busybox-ndk ]; then
  BUSY=$(find /sbin/.magisk/modules/busybox-ndk/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BUSY; do
    PATH=/sbin/.magisk/modules/busybox-ndk/system/$i:$PATH
    _bb=/sbin/.magisk/modules/busybox-ndk/system/$i/busybox
  done
elif [ -f /sbin/.magisk/modules/ccbins/system/bin/busybox ]; then
  PATH=/sbin/.magisk/modules/ccbins/system/bin:$PATH
  _bb=/sbin/.magisk/modules/ccbins/system/bin/busybox
elif [ -f /sbin/.magisk/modules/ccbins/system/xbin/busybox ]; then
  PATH=/sbin/.magisk/modules/ccbins/system/xbin:$PATH
  _bb=/sbin/.magisk/modules/ccbins/system/xbin/busybox
elif [ -f $TMPDIR/tools/busybox ]; then
  PATH=$TMPDIR/tools:$PATH
  _bb=$TMPDIR/tools/busybox
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
fi

set_busybox $_bb
[ $? -ne 0 ] && exxit $?

ui_print "Adding"

cp -rf $TMPDIR/system/fonts/Dragon.ttf $TMPDIR/system/fonts/Dragon-Regular.ttf
cp -rf $TMPDIR/system/fonts/Dragon.ttf $TMPDIR/system/fonts/Dragon-Bold.ttf

cp -rf /system/etc/fonts.xml $TMPDIR/system/etc/fonts.xml

for i in $(find $TMPDIR/system/fonts/Dragon-* | sed 's|.*-||'); do
  sed -i "s|Roboto-$i|Dragon-$i|" $TMPDIR/system/etc/fonts.xml
done