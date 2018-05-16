#!/bin/bash

################################################################################################################################
#
# Deduplicate BAM using Picard MarkDuplicates. Part of the MayomicsVC Workflow.
# 
# Usage:
# dedup.sh <aligned.sorted.bam> <temp_directory> <output_directory> </path/to/java> </path/to/picard> <threads> </path/to/error_log>
#
################################################################################################################################

## Input and Output parameters
INPUTBAM=$1
TMPDIR=$2
OUTDIR=$3
JAVA=$4
PICARD=$5
thr=$6
ERRLOG=$7

#set -x

## Check if input files, directories, and variables are non-zero
if [ ! -s $INPUTBAM ]
then 
        echo -e "$0 stopped at line $LINENO. \nREASON=Input sorted BAM file $INPUTBAM is empty." >> ${ERRLOG}
	exit 1;
fi
if [ ! -d $TMPDIR ]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Temporary directory $TMPDIR does not exist." >> ${ERRLOG}
        exit 1;
fi
if [ ! -d $OUTDIR ]
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Output directory $OUTDIR does not exist." >> ${ERRLOG}
	exit 1;
fi
if [ ! -d $JAVA ]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Java directory $JAVA does not exist." >> ${ERRLOG}
        exit 1;
fi
if [ ! -d $PICARD ]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Picard directory $PICARD does not exist." >> ${ERRLOG}
	exit 1;
fi
if (( $thr % 2 != 0 ))
then
	thr=$((thr-1))
fi
if [ ! -s $ERRLOG ]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Error log file $ERRLOG does not exist." >> ${ERRLOG}
        exit 1;
fi

## Parse filename without full path
name=$(echo "$INPUTBAM" | sed "s/.*\///")
full=$INPUTBAM
sample=${full##*/}
samplename=${sample%.*}
OUT=${OUTDIR}/${samplename}.deduped.bam

## Record start time
StartTime=`date "+%m-%d-%Y %H:%M:%S"`
echo "[PICARD] Deduplicating BAM with MarkDuplicates. ${StartTime}"

## Picard MarkDuplicates command.
$JAVA/java -Djava.io.tmpdir=$TMPDIR -jar $PICARD/picard.jar MarkDuplicates INPUT=$INPUTBAM OUTPUT=$OUT TMP_DIR=$TMPDIR METRICS_FILE=${samplename}.picard.metrics ASSUME_SORTED=true MAX_RECORDS_IN_RAM=null CREATE_INDEX=true &
wait
echo "[PICARD] Deduplicated BAM found at ${OUT}."

## Record end of the program execution
EndTime=`date "+%m-%d-%Y %H:%M:%S"`

## Open read permissions to the user group
chmod g+r $OUT

echo "[PICARD] Finished. ${EndTime}"