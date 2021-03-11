#!/bin/bash
echo "Введите название папки (будет помещена в /):"
read folder
folder='/'$folder
echo "Введите имя пользователя администратора:"
read admin
echo "Введите пароль, который будет установлен ВСЕМ пользователям:"
read password
echo "Сменить пароль пользователю при входе в систему? [y/n]"
read chage
share_group=share_users
share_folder=share

groupadd $share_group

groups_by_default=audio,cdrom,plugdev,scanner,video,share_users

cp conf/profile /etc/profile
cp conf/mac_levels /etc/parsec/mac_levels
cp -R conf/Desktops /usr/share/fly-wm/
sed -i 's/$folder/\'${folder}'/' /usr/share/fly-wm/Desktops/Desktop1/docs.desktop
cp -R conf/libreoffice /usr/share/fly-wm/config
sed -i 's/$folder/file:\/\/\'${folder}'/' /usr/share/fly-wm/config/libreoffice/4/user/registrymodifications.xcu

LEVELS_NAME=($(awk 'BEGIN{FS=":"} {print $1}' conf/mac_levels))
MAC_LEVELS=($(awk 'BEGIN{FS=":"} {print $2}' conf/mac_levels))

USERS=($(awk 'BEGIN{FS=", "} {print $1}' $1))
USERS_LEVEL=($(awk 'BEGIN{FS=", "} {print $2}' $1))

for user_id in ${!USERS[*]}
do
	username=${USERS[user_id]}
	user_level=${USERS_LEVEL[user_id]}
	useradd --groups $groups_by_default --shell /bin/bash -m $username
	if [[ $chage = 'y' ]]; then
		echo 'change password'$username
		chage --lastday 0 $username
	fi
	echo $username:$password | sudo chpasswd
	pdpl-user $username --level 0:$user_level
done

rm -rf $folder
mkdir $folder
chown $admin:$share_group $folder
chmod u+rwx,g+rx,o-rwx $folder
pdpl-file 3:0:0:ccnr $folder

for i in ${MAC_LEVELS[*]}
do
	level=${MAC_LEVELS[$i]}
	path=$folder/${LEVELS_NAME[$i]}
	mkdir $path
	chown $admin:$share_group $path
	chmod u+rwx,g+rx,o-rwx $path
	pdpl-file -v $level:0:0 $path

	for user_id in ${!USERS[*]}
	do
		user=${USERS[user_id]}
		user_level=${USERS_LEVEL[user_id]}

		if [[ $level -le $user_level ]]
		then
			mkdir $path/$user
			chown $admin:$user $path/$user
			chmod u+rwx,g+rwx,o-rwx $path/$user
 			pdpl-file -v $level:0:0 $path/$user
		fi
	done

	path=$path/$share_folder
	mkdir $path
	chown -v $admin:$share_group $path
	chmod u+rwx,g+rwxs,o-rwx $path
	pdpl-file -v $level:0:0 $path

done
