#!/bin/bash -eu

echo "*** Recalibrating base quality ***"
echo "   " >> $LOGFILE
echo "*** Recalibrating base quality ***" >> $LOGFILE

if [ $# -lt 2 ]
then 
	echo "Usage: $0 <capture|False> <bam> <out>"
	exit 1
fi

capture=$1
shift
echo $capture

CAPTURE=""
if [[ "$capture" != "False" ]]
then
	#CAPTURE="-L $capture"
	captures=$(echo $capture | tr "[" "\n")
	captures=$(echo $captures | tr "]" "\n")
	captures=$(echo $captures | tr "," "\n")
	#echo "here" $captures
	
	for capt in $captures
	do
		echo "HELLO CAPTURE" $capt
		if [[ "$CAPTURE" != "" ]]
		then 
			CAPTURE="$CAPTURE -L $capt"
		else
			CAPTURE="-L $capt"
		fi
	done
fi


f=`cd \`dirname $1\`; pwd`/`basename $1`
o=`cd \`dirname $2\`; pwd`/`basename $2`

command="java -Xms5g -Xmx5g -jar $GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-I $f \
   	-R $REF \
	-o ${o/.bam/.grp} \
   	-knownSites $MILLS_1K_GOLD_INDELS \
   	-knownSites $GOLD_1K_INDELS \
   	-knownSites $DBSNP \
        $CAPTURE \
        -K /srv/gs1/software/gatk/GATKkey/stanford.edu.key"

#	-cov ReadGroupCovariate \
#	-cov QualityScoreCovariate \
#	-cov CycleCovariate \
echo ">>> Counting covariates"
echo ">>> Counting covariates" >> $LOGFILE
echo ">>> $command"
echo ">>> $command" >> $LOGFILE
$command

# This is added to create BQSR plots: 
# http://gatkforums.broadinstitute.org/discussion/2801/howto-recalibrate-base-quality-scores-run-bqsr

command="java -Xms5g -Xmx5g -jar $GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-I $f \
   	-R $REF \
	-o ${o/.bam/.grp.post} \
   	-knownSites $MILLS_1K_GOLD_INDELS \
   	-knownSites $GOLD_1K_INDELS \
   	-knownSites $DBSNP \
        $CAPTURE \
	-BQSR ${o/.bam/.grp} \
        -K /srv/gs1/software/gatk/GATKkey/stanford.edu.key"

#	-cov ReadGroupCovariate \
#	-cov QualityScoreCovariate \
#	-cov CycleCovariate \
echo ">>> Recounting covariates"
echo ">>> Recounting covariates" >> $LOGFILE
echo ">>> $command"
echo ">>> $command" >> $LOGFILE
$command

command="java -Xms5g -Xmx5g -jar $GATK/GenomeAnalysisTK.jar \
    -T AnalyzeCovariates \
    -R $REF \
    -before ${o/.bam/.grp} \
    -after ${o/.bam/.grp.post} \
    -plots ${o/.bam/recalibration_plots.pdf}"

echo ">>> Creating BQSR plots"	
echo ">>> Creating BQSR plots" >> $LOGFILE	
echo ">>> $command"
echo ">>> $command" >> $LOGFILE
#$command

command="java -Xms5g -Xmx5g -jar $GATK/GenomeAnalysisTK.jar \
	-R $REF \
	-I $f \
	-o $o \
	-T PrintReads \
	-BQSR ${o/.bam/.grp} \
	-K /srv/gs1/software/gatk/GATKkey/stanford.edu.key"

echo ">>> Printing reads"	
echo ">>> Printing reads" >> $LOGFILE	
echo ">>> $command"
echo ">>> $command" >> $LOGFILE
$command

echo "*** Finished recalibrating base quality ***"
