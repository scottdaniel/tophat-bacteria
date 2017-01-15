#
# to map the mouse
#
unset module
source ./config.sh

CWD=$(pwd)
PROG=`basename $0 ".sh"`
STDOUT_DIR="$CWD/out/$PROG"

init_dir "$STDOUT_DIR" "$MOUSE_OUT"

cd "$FASTQ_DIR"

for i in $SAMPLE_NAMES; do
    
    export SAMPLE=$i
    export LEFT_FASTQ="$TEMP_DIR/$i-left-fastq"
    export RIGHT_FASTQ="$TEMP_DIR/$i-right-fastq"
    export UNPAIRED="$TEMP_DIR/$i-unpaired-fastq"

    #have to do the weird translate and sed stuff
    #because tophat likes everything comma delimited

    find . -type f -regextype 'sed' -iregex "\.\/$i.*\.1.fastq" \
        | sort | tr '\n' ',' | sed "s/,$//g" > $LEFT_FASTQ
    
    find . -type f -regextype 'sed' -iregex "\.\/$i.*\.2.fastq"  \
        | sort | tr '\n' ',' | sed "s/,$//g" > $RIGHT_FASTQ
    
    find . -type f -regextype 'sed' -iregex "\.\/$i.*nomatch.*" \
        | tr '\n' ',' | sed "s/,$//g" > $UNPAIRED

    echo "Mapping $i FASTQs to $MOUSEBT2"

    JOB=$(qsub -V -N tophatm -j oe -o "$STDOUT_DIR" $WORKER_DIR/run-tophat-alt.sh)

    if [ $? -eq 0 ]; then
        echo Submitted job \"$JOB\" for you. Weeeeeeeeeeeee!
    else
        echo -e "\nError submitting job\n$JOB\n"
    fi

done

