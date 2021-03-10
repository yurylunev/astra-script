#!/bin/bash
echo "Введите название папки:"
read folder
echo "Введите имя пользователя администратора:"
read admin
echo "Введите пароль, который будет установлен ВСЕМ пользователям:"
read password
echo "Сменить пароль пользователю при входе в систему? [y/n]"
read chage
share_group=share_users
share_folder=share
LEVELS_NAME=(НС ДСП С СС)

groupadd $share_group

groups_by_default=audio,cdrom,plugdev,scanner,video,share_users

cp profile /etc/profile
cp -R config/* /usr/share/fly-wm/config
sed -i 's/$folder/file:\/\/\/${folder}/' /usr/share/fly-wm/config/libreoffice/4/user/registrymodifications.xcu

USERS=($(awk 'BEGIN{FS=", "} {print $1}' users))
USERS_LEVEL=($(awk 'BEGIN{FS=", "} {print $2}' users))

for user_id in ${!USERS[*]}
do
	username=${USERS[user_id]}
	user_level=${USERS_LEVEL[user_id]}
	useradd --groups $groups_by_default --shell /bin/bash -m $username
	if ["$chage" = "y"]; then
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

for level in ${!LEVELS_NAME[*]}
do
	path=$folder/${LEVELS_NAME[$level]}
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
