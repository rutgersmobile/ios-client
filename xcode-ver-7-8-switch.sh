cd /Applications

if [[ $1 = "7" ]]
then 
	if [ -e Xcode_7.app ]
	then
		mv  Xcode.app Xcode_8.app
		mv  Xcode_7.app Xcode.app
		echo " switched to xcode 7"
	else
		echo " already using xcode 7"
	fi
elif	[[ $1 = "8" ]]
then 
	if [ -e Xcode_8.app ]
	then
		mv Xcode.app Xcode_7.app
		mv Xcode_8.app Xcode.app
		echo " switched to xcode 8 "
	else
		echo " already using xcode 8"
	fi
else
	echo "usage : xcode-ver-7-8-switch 7/8 "
fi


