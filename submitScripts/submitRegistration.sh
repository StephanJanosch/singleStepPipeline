#!/bin/bash

fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji_deconv.app/ImageJ-linux64"
beanShellScript="/home/janosch/beanshell/register.bsh"
queue="short"
threads=1

function register
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
		errFile="$xmlDir/detect_err_$jobName.txt"
		outFile="$xmlDir/detect_out_$jobName.txt"
		touch jobFile
		echo "#!/bin/bash" > jobFile
		echo "#BSUB -J $jobName" >> jobFile
		echo "#BSUB -q $queue" >> jobFile
		echo "#BSUB -n $threads" >> jobFile
		echo "#BSUB -R span[hosts=1]" >> jobFile
		echo "#BSUB -o $outFile" >> jobFile
		echo "#BSUB -e $errFile" >> jobFile
		echo "$fijiApp -Dxml=$xml -- --console $beanShellScript > $xmlDir/fiji_register_$jobName.txt" >> jobFile
		
 		bsub < jobFile
 		rm jobFile
	
	done
}



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
 		register $dir
	fi
	
done