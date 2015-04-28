#!/bin/bash 

fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji2015.app/ImageJ-linux64"
beanShellScript="/home/janosch/beanshell/removeByDistance.bsh"
queue="short"
threadCount=1

function removeByDistance
{
	singleDir=$1

	if [[ ! $singleDir == /projects*   ]] ;
	then
		echo "No absolute directory given. Exiting!"
		exit 2
	fi

	command="find $singleDir -name *xml"

	for xml in `$command`;
	do
	
# 	we need jobName,errFile, outFile
		jobName=`basename $xml`
		jobName=${jobName/".xml"/""}
		xmlDir=`dirname $xml`
# 		echo $jobName
		errFile="$xmlDir/remove_err_$jobName$labels$channels.txt"
		outFile="$xmlDir/remove_out_$jobName$labels$channels.txt"
		touch jobFile
		echo "#!/bin/bash" > jobFile
		echo "#BSUB -J $jobName" >> jobFile
		echo "#BSUB -q $queue" >> jobFile
		echo "#BSUB -n $threadCount" >> jobFile
		echo "#BSUB -R span[hosts=1]" >> jobFile
		echo "#BSUB -o $outFile" >> jobFile
		echo "#BSUB -e $errFile" >> jobFile
		echo "$fijiApp -Dxml=$xml  -Dchannels=$channels -Dlabel=$labels -DnewLabel=$newLabel -Dmode=$mode -DlowerT=$lowerT -DupperT=$upperT -DthreadCount=$threadCount -- --console $beanShellScript > $xmlDir/fiji_remove$jobName$labels$channels.txt" >> jobFile
		
 		bsub < jobFile
 		rm jobFile
		
	done
}

if [ $# -lt 7 ];
then 
	echo "Error, not enough parameters!"
	echo "usage `basename $0` <channel_1[,channel_2,channel_n]> <label> <newLabel> keep|remove <lower threshold> <upper threshold> <dir[s]>" 
	exit 1
fi


channels=$1
echo "channels: $channels"
shift

labels=$1
echo "label: $labels"
shift

newLabel=$1
echo "new label: $newLabel"
shift

mode=$1
echo "mode: $mode"
shift

lowerT=$1
echo "lowerT: $lowerT"
shift

upperT=$1
echo "upperT: $upperT"
shift


echo "[Enter] to continue"
read

#main loop here, handles all arguments
for dir in "$@";
do
	if [[ ! $dir == /projects*   ]] ;
	then
		echo "Error: No absolute directory given: $dir"
		exit 2
	fi

	if [  -d $dir ]; 
	then
		echo $dir
 		removeByDistance $dir
	fi
	
done