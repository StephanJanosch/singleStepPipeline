#!/bin/bash
echo "submitDeconvolution.sh - Version 0.1 - 24.02.2015 - janosch@mpi-cbg.de"
 
fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji2015.app/ImageJ-linux64"
beanShellScript="/home/janosch/beanshell/deconvolveGPU.bsh"
queue="gpu"
threadCount=7


function deconvolve
{
	singleDir=$1
	command="find $singleDir -name *xml"
	for xml in `$command`;
	do

# 		xml="/projects/wormspim2/141009_Cel_OP43/Worm4//OP43_Worm4.xml"

		jobName=`basename $xml`
		jobName=${jobName/".xml"/""}
		xmlDir=`dirname $xml`

		errFile="$xmlDir/deconvolve_err_$jobName$channels$illuDirs$iterations.txt"
		outFile="$xmlDir/deconvolve_out_$jobName$channels$illuDirs$iterations.txt"
		touch jobFile
		echo "#!/bin/bash" > jobFile
		echo "#BSUB -J $jobName" >> jobFile
		echo "#BSUB -q $queue" >> jobFile
		echo "#BSUB -n $threadCount=6" >> jobFile
		echo "#BSUB -R span[hosts=1]" >> jobFile
		echo "#BSUB -o $outFile" >> jobFile
		echo "#BSUB -e $errFile" >> jobFile

		echo "$fijiApp -Dxml=$xml -Dchannels=$channels -DoutDir=$xmlDir -DboundingBoxReg=$boundingBoxReg -DilluDirs=$illuDirs -Diterations=$iterations -DthreadCount=$threadCount -Dpsf=$psfDetection -DpsfX=$psfX -DpsfY=$psfY -DpsfZ=$psfZ -- --console $beanShellScript > $xmlDir/fiji_deconvolve_$jobName$channels$illuDirs$iterations.txt" >> jobFile
#		cat jobFile
 		bsub < jobFile
 		rm jobFile
	done
}


if [ $# -lt 9 ];
then 
	echo "Error, not enough parameters!"
	echo "usage $0 <channel_1[,channel_2,channel_n]> <boundingBoxReg> <illu_1[,illu_2]> <iterations> <psf detection> <psf_x> <psf_y> <psf_z> <dir[s]>" 
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

iterations=$1
echo "iterations: $iterations"
shift

psfDetection=$1
echo "psf detection: $psfDetection"
shift

psfX=$1
shift

psfY=$1
shift

psfZ=$1
shift

echo "psf (px): X $psfX, Y $psfY, Z $psfZ"

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
 		deconvolve $dir
	fi
	
done
