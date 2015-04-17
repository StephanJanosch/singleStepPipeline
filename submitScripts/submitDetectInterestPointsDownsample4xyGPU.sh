#!/bin/bash 
export LD_LIBRARY_PATH=/lustre/sw/apps/cuda/6.5.14/lib64:$LD_LIBRARY_PATH

fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji2015.app/ImageJ-linux64"
beanShellScript="/home/janosch/beanshell/detectInterestPointsDS4xyGPU.bsh"
queue="gpu"
threadCount=1

function detect
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
		errFile="$xmlDir/detect_err_$jobName$labels$channels.txt"
		outFile="$xmlDir/detect_out_$jobName$labels$channels.txt"
		touch jobFile
		echo "#!/bin/bash" > jobFile
		echo "#BSUB -J $jobName" >> jobFile
		echo "#BSUB -q $queue" >> jobFile
		echo "#BSUB -n $threadCount" >> jobFile
		echo "#BSUB -R span[hosts=1]" >> jobFile
		echo "#BSUB -o $outFile" >> jobFile
		echo "#BSUB -e $errFile" >> jobFile
		echo "$fijiApp -Dxml=$xml -Dsigma=$sigma -Dthreshold=$threshold -Dchannels=$channels -Dlabel=$labels -DthreadCount=$threadCount -- --console $beanShellScript > $xmlDir/fiji_detect$jobName$labels$channels.txt" >> jobFile
		
		
#  		detectionCommand="bsub -J $jobName -q $queue -n 4 -R span[hosts=1] -o $outFile -e $errFile $fijiApp -Dxml=$xml -Dsigma=$sigma -Dthreshold=$threshold -- --console $beanShellScript" 
# 		echo `$detectionCommand`

 		bsub < jobFile
 		rm jobFile
		
	done
}

if [ $# -lt 5 ];
then 
	echo "Error, not enough parameters!"
	echo "usage $0 <sigma> <threshold> <channel_1[,channel_2,channel_n]> <label> <dir[s]>" 
	exit 1
fi

sigma=$1
echo "sigma: $sigma"
shift

threshold=$1
echo "threshold: $threshold"
shift

channels=$1
echo "channels: $channels"
shift

labels=$1
echo "label: $labels"
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
 		detect $dir
	fi
	
done