#!/bin/bash
#echo "Введите название папки:"
#read folder

folder=/docs
admin=user209
share_group=allusers
share_folder=share

LEVELS_NAME=(НС ДСП С СС)

#USERS=$(cut -d: -f1 users)
USERS=($(awk 'BEGIN{FS=", "} {print $1}' users))
USERS_LEVEL=($(awk 'BEGIN{FS=", "} {print $2}' users))
#users=(user209 user210 user211 user212 user200 user00)

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
#	 	mkdir /home/.pdp/$user    
#                chown $user:$user /home/.pdp/$user  
#                chmod u+rwx,g-rwx,o-rwx /home/.pdp/$user
#                pdpl-file -v 3:0:0:-1 /home/.pdp/$user
		if [[ $level -le $user_level ]]
		then
			mkdir $path/$user
			chown $admin:$user $path/$user
			chmod u+rwx,g+rwx,o-rwx $path/$user
 			pdpl-file -v $level:0:0 $path/$user
#			pdp_path=/home/.pdp/$user/l${level}i0c0x0t0x0
#			mkdir $pdp_path
#			chown $user:$user $pdp_path
#			chmod u+rwx,g-rwx,o-rwx $pdp_path
#			pdpl-file -v $level:0:0 $pdp_path
#			cp -r skel/* $pdp_path
#			chown -R $user:$user $pdp_path
#                       chmod u+rwx,g-rwx,o-rwx $pdp_path
#			pdpl-file --recursive -v $level:0:0 $pdp_path/*
		fi
	done

	path=$path/$share_folder
	mkdir $path
        chown -v $admin:$share_group $path
        chmod u+rwx,g+rwxs,o-rwx $path
        pdpl-file -v $level:0:0 $path

done
