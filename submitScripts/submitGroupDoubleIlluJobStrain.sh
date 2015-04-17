rootDir="/projects/wormspim2/"
wormDir=$rootDir$1
fijiMacroCall="/sw/bin/xvfb-run -a /sw/users/janosch/Fiji.app/ImageJ-linux64  --console -batch /home/janosch/macro/FixGroupDoubleIlluMax.ijm"
queue="medium"


# #echo $wormDir
# strain=$1
# for dir in `ls $wormDir`; do
# 
# 	subDir=$wormDir"/"$dir
# 	if [ -d $subDir ]; then
# 		
# 		#go into one worm
# 		for subWormDir in `ls $subDir`; do
# 			
# 			completeSubWormDir=$subDir"/"$subWormDir
# 			if [ -d $completeSubWormDir ]; then
# 				echo $1" "$dir" "$subWormDir"  "$completeSubWormDir
# 				
# 				outFile=$subDir"/out_"$strain"_"$subWormDir".txt"
# 				errFile=$subDir"/err_"$strain"_"$subWormDir".txt"
# 
# 				#run fiji here
# 				command="bsub -J $strain -q $queue -n 1 -R span[hosts=1] -o $outFile -e $errFile $fijiMacroCall $completeSubWormDir/" 
# 				echo `$command`
# 
# 			fi
# 
# 
# 		done
# 
# 
# 	fi
# done
echo $wormDir
for groupDir in `find $wormDir -name *DAPI*G?.czi`; 
do 
	jobDir=`dirname $groupDir`
	jobname=`basename $groupDir`
	jobname=${jobname/"_DAPI"/""}
	jobname=${jobname/".czi"/""}
	echo $jobname
	
	outFile=$jobDir"/out_"$jobname".txt"
	errFile=$jobDir"/err_"$jobname".txt"
	#run fiji here

	command="bsub -J $jobname -q $queue -n 1 -R span[hosts=1] -o $outFile -e $errFile $fijiMacroCall $jobDir/" 
 	$command
done
