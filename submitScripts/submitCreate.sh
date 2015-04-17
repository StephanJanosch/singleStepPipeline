#!/bin/bash
fijiApp="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji_deconv.app/ImageJ-linux64"
createScript="/home/janosch/beanshell/createDataset.bsh"
queue="short"
threadCount=1

function handleWormDir 
{
 	wormDir=$1
# 	echo "handleWormDir: $wormDir"

 	pushd $wormDir > /dev/null
# 
	for dataset in `ls *DAPI*\(0*zip` ;
	do
		echo "    $dataset"
		
		#get xml file
		patternLen=${#dataset}
		let patternLen=$patternLen-11
		xmlFile=${dataset:0:patternLen}

#		get angles
		zipFileCount=`ls $xmlFile*zip | wc -l`
		let zipFileCount=$zipFileCount-1
		angles="0-$zipFileCount"
# 		got angles

#		get xml file name
		xmlFile=${xmlFile/"_DAPI"/""}
		xmlFile=${xmlFile/"/DAPI"/""}

		jobName=$xmlFile

		xmlFile="$xmlFile.xml"
		
#		echo "    $xmlFile"
#		got xml file		
		
#		get pattern
		pattern=${dataset/"(0).czi.zip"/"({a}).czi.zip"}
		pattern=${pattern/"DAPI"/"{c}"}

 		echo "      $wormDir $pattern $angles $xmlFile"
		errFile="$wormDir/define_err_$jobName.txt"
		outFile="$wormDir/define_out_$jobName.txt"

 		defineCommand="bsub -J $jobName -q $queue -n 1 -R span[hosts=1] -o $outFile -e $errFile $fijiApp -Ddir=$wormDir -Dpattern=$pattern -Dchannels="DAPI,GFP" -Dangles=$angles -Dxml=$xmlFile -DthreadCount=$threadCount -- --console $createScript" 
 		echo "         "`$defineCommand`
# 		echo "$defineCommand"

	done

	popd > /dev/null
}

function handleDoubleIlluWormDir
{
 	wormDir=$1
 	pushd $wormDir > /dev/null
 	for dataset in `ls *_1_DAPI*\(0*zip` ;
 	do
 		echo "    $dataset"
		patternLen=${#dataset}
		let patternLen=$patternLen-11
		xmlFile=${dataset:0:patternLen}
		zipFileCount=`ls $xmlFile*zip | wc -l`
		let zipFileCount=$zipFileCount-1
		angles="0-$zipFileCount"
		#xml file
		xmlFile=${xmlFile/"_1_DAPI"/""}
		xmlFile=${xmlFile/"/DAPI"/""}
		jobName=$xmlFile
		xmlFile="$xmlFile.xml"
		#pattern
		pattern=${dataset/"(0).czi.zip"/"({a}).czi.zip"}
		pattern=${pattern/"1_DAPI"/"{i}_{c}"}
		illuDirs="1,2"
		echo "      $wormDir $pattern $angles $illuDirs $xmlFile"
	
		errFile="$wormDir/define_err_$jobName.txt"
		outFile="$wormDir/define_out_$jobName.txt"
 		defineCommand="bsub -J $jobName -q $queue -n 1 -R span[hosts=1] -o $outFile -e $errFile $fijiApp -Ddir=$wormDir -Dpattern=$pattern -Dchannels="DAPI,GFP" -Dangles=$angles -DilluDirs=$illuDirs -Dxml=$xmlFile -DthreadCount=$threadCount -- --console $createScript" 
 		echo "         "`$defineCommand`
		
 	done
 	popd > /dev/null
}


function handleRecordingDayDir
{
	recordingDayDir=$1
	for subDir in `ls $recordingDayDir`;
	do
		if [ -d "$recordingDayDir/$subDir" ];
		then
		
			if [ $mode == "single" ];
			then
				echo "  $subDir [SINGLE]"
				handleWormDir "$recordingDayDir/$subDir"
			else
				echo "  $subDir [DOUBLE]"
				handleDoubleIlluWormDir "$recordingDayDir/$subDir"
			
			fi
		fi
	done

}


if [ $# -lt 2 ];
then 
	echo "usage: $0 <single|double> directory(ies)"
	exit 2
fi

mode=$1
shift

#main loop here, handles all arguments
for dir in "$@";
do

	if [[ ! $dir == /projects*   ]] ;
	then
		echo "No absolute directory given. Exiting!"
		exit 2
	fi

	if [  -d $dir ]; 
	then
		echo $dir
		handleRecordingDayDir $dir
	fi
	
done