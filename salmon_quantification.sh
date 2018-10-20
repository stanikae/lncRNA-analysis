#!/bin/bash

#variables to define
#declare -x salmonIndex=					#salmon index output directory
declare -x inFasta= $1 #$finalOut/LncRNA_finalSeq_final.fa	#input file with transcript fasta files
#declare -x readsDir=					#path to the clean reads directory
##declare -x read1_suffix="_read1_val_1.fq.gz"		#read1 suffix after preferred sample name/ID
#declare -x read2_suffix="_read2_val_2.fq.gz"		#read2 suffix
#declare -x salmonOut=					#salmon output directory

#create index files
salmon index -t $inFasta -i $salmonIndex --type quasi -k 31

#quantify transcripts using salmon quant
for i in $(find $readsDir/ -name "*$read1_suffix")
 do
        #name=$(basename $i | cut -d_ -f1,2,3)
        fq_dir=$(dirname $i)
        name=$(basename $i | cut -d_ -f1)
        name2=$(basename -s $read1_suffix $i)
        if [[ "$i" == *$stranded* ]];
         then
                salmon quant -i $salmonIndex \
                        -l ISR \
                        -g $gtf \
                        -1 <(gunzip -c $fq_dir/${name2}${read1_suffix}) -2 <(gunzip -c $fq_dir/${name2}${read1_suffix}) \
                        --gcBias \
                        -p 10 \
                        -o $salmonOut/$name

         else
                salmon quant -i $salmonIndex \
                        -l A \
                        -g $gtf \
                        -1 <(gunzip -c $fq_dir/${name2}${read1_suffix}) -2 <(gunzip -c $fq_dir/${name2}${read1_suffix}) \
                        --gcBias \
                        -p 10 \
                        -o $salmonOut/$name
        fi
done
#create salmon quantification reports for visualization
multiqc -d $salmonOut -o $salmonOut
