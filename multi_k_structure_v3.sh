#!/bin/bash

# Made by the MBB plateform from the Labex CEMEB

usage="$0 infile mainparams extraparams k_min k_max iter [step]\n
--------\n
NB : \n
mainparams and extraparams are text files.\n
step is optional.\n
iter is the number of iterations.\n"
if [ "$#" -lt 5 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ];then
    echo -e $usage
    exit 1
else
    infile=$1
    mainparams=$2
    extraparams=$3
    
    k_min=$4
    k_max=$5
    max_runs=500
    
    if [[ $6 ]];then
        iter=$6
    else
        iter=1
    fi;
    
    if [[ $7 ]];then
        step=$7
    else
        step=1
    fi;
    
    nb_runs=`echo "(($k_max - $k_min)/$step)*$iter" |bc -l`
    compare_result=`echo "$nb_runs > $max_runs" | bc`
    if [ "$compare_result" == 1 ]; then
        echo "Error : max K delta for structure is limited to 100"
    else
        ## converting Windows/Mac files (wrapper did not work ?)
        /usr/bin/dos2unix -n $infile $infile.out
        cp $infile.out $infile
        /usr/bin/dos2unix -n $mainparams $mainparams.out
        cp $mainparams.out $mainparams
        /usr/bin/dos2unix -n $extraparams $extraparams.out
        cp $extraparams.out $extraparams
        for ((i=1;i<=$iter;i++))
        do
            j=$k_min
            while ((j<=$k_max))
            do
                echo "$i $j" >> process_structure
                j=$(($j+$step))
            done;
        done
        ## following was working for no iteration
        #tline=`echo "-t $k_min-$k_max:$step"`
        # here I will calculate the number of values, rounded up...
        nbk=$(( ((($k_max-($k_min-1))+($step-1))/$step)*$iter ))
        tline=`echo "-t 1-$nbk -tc 100"`
    fi;
fi;


if [[ $tline ]];then
    cat > array_structure.qsub << EOF
#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -q long.q
#$ $tline

## get values of k and iteration for line number
iter=\`awk "NR==\$SGE_TASK_ID" process_structure|cut -d' ' -f1\`
k=\`awk "NR==\$SGE_TASK_ID" process_structure|cut -d' ' -f2\`
## concatenate string to get myfile result file
myfile=iter_"\$iter"_results_K_"\$k"

structure -i $infile -K \$k -D \$RANDOM -m $mainparams -e $extraparams -o \$myfile > /dev/null
EOF
    #filename=struc_$k_min-$k_max.$RANDOM
    qsub -sync y array_structure.qsub
    grep "Estimated Ln Prob of Data" iter_*_results_K_*_f > estimated_results.out
    echo "'Iteration' 'K'  'Estimated Ln Prob of Data'" > final_results.out
    cat estimated_results.out |awk 'BEGIN{FS="[_,=]"} {print $2,$5,$7}' >> final_results.out
    rm -f array_structure.qsub* estimated_results.out process_structure
    /usr/bin/zip iters_K_results_f.zip iter_*_results_K_*_f
fi;
