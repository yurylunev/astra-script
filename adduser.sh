#!/bin/bash
groupadd share_users
username=user312
password=2222
groups_by_default=audio,cdrom,plugdev,scanner,video,share_users

cp skel/profile /etc/profile
cp -R skel/.config/* /usr/share/fly-wm/config
useradd --groups $groups_by_default --shell /bin/bash -m $username
echo $username:$password | sudo chpasswd
pdpl-user $username --level 0:3
