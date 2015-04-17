#!/bin/bash 
fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji2015.app/ImageJ-linux64"
beanShellScript="/home/janosch/beanshell/fuse.bsh"
queue="medium"
threadCount=6


function fuse
{
	singleDir=$1
	command="find $singleDir -name *xml"
	for xml in `$command`;
	do

		jobName=`basename $xml`
		jobName=${jobName/".xml"/""}
		xmlDir=`dirname $xml`

		errFile="$xmlDir/fuse_err_$jobName$channels$boundingBoxReg$illuDirs.txt"
		outFile="$xmlDir/fuse_out_$jobName$channels$boundingBoxReg$illuDirs.txt"
		touch jobFile
		echo "#!/bin/bash" > jobFile
		echo "#BSUB -J $jobName" >> jobFile
		echo "#BSUB -q $queue" >> jobFile
		echo "#BSUB -n $threadCount" >> jobFile
		echo "#BSUB -R span[hosts=1]" >> jobFile
		echo "#BSUB -o $outFile" >> jobFile
		echo "#BSUB -e $errFile" >> jobFile

		echo "$fijiApp -Dxml=$xml -Dchannels=$channels -DoutDir=$xmlDir -DilluDirs=$illuDirs -DboundingBoxReg=$boundingBoxReg -DthreadCount=$threadCount -- --console $beanShellScript > $xmlDir/fiji_fuse_$jobName$channels$illuDirs.txt" >> jobFile
		bsub < jobFile
 		rm jobFile
	done
}


if [ $# -lt 4 ];
then 
	echo "Error, not enough parameters!"
	echo "usage $0 <channel_1[,channel_2,channel_n]> <boundingBoxReg> <illu_1[,illu_2]> <dir[s]>" 
	exit 1
fi

channels=$1
echo "channel: $channels"
shift

boundingBoxReg=$1
echo "Bounding Box Registration: $boundingBoxReg"
shift

illuDirs=$1
echo "illumination direction: $illuDirs"
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
 		fuse $dir
	fi
	
done