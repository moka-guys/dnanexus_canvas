#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#### Functions ####
build_path () {
# Build string containing optional command line arguments for Canvas. 
# Takes a Canvas flag and input file. Returns empty string if file does not exist.
# $ build_path "--filter-bed" "bed_file.bed"
# >> " --filter-bed bed_file"
    fopt=$1
    fpath=$2
    if [ -e $fpath ]; then
        echo " $fopt $fpath"
    else
        echo ""
    fi
}

#### Main ####
# Install required libraries via apt-get
sudo apt-get install -y libunwind8

# Download input bam file and canvas refs to $HOME/in/
dx-download-all-inputs

# Extract Canvas binaries and set executeable permissions
tar -xzvf Canvas-1.39.0.1598.master_x64.tar.gz
sudo chmod 755 -R Canvas-1.39.0.1598+master_x64/

# Extract reference genome data to working directory ($HOME)
tar -xzvf $canvas_ref_path
# Assign reference genome directory to variable
genome_dir=reference/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta

# Move input bam index file to location expected by Canvas
mv $input_bam_index_path /home/dnanexus/in/input_bam/${input_bam_index_prefix}.bam.bai

# Create Canvas directories.
outdir=out/canvas/Results/canvas_out/$input_bam_index_prefix
mkdir -p $outdir tempdir

# Set additional options
extra_opts=""
extra_opts+=$(build_path "--ploidy-vcf" "$ploidy_vcf_path")
extra_opts+=$(build_path "--common-cnvs-bed" "$common_cnvs_bed_path")
if [ -e $filter_bed_path ]; then
    extra_opts+=$(build_path "--filter-bed" "$filter_bed_path")
else
    extra_opts+=$(build_path "--filter-bed" "reference/filter13.bed")
fi

# Run Canvas Germline-WGS for CNV calling
dotnet Canvas-1.39.0.1598+master_x64/Canvas.dll SmallPedigree-WGS \
    --bam=$input_bam_path \
    --population-b-allele-vcf=reference/dbsnp.vcf \
    --reference=reference/kmer.fa \
    --genome-folder=$genome_dir \
    --output=tempdir \
    $extra_opts # Note filter_13.bed packaged with app is used here.

# Move desired outputs to upload directory: CNV.CoverageAndVariantFrequency.txt and CNV.vcf.gz
mv tempdir/*.txt tempdir/*vcf.gz $outdir
# Change prefix of output files to input BAM name.
for outfile_path in $outdir/*; do
    new_name=$input_bam_prefix.$(basename $outfile_path)
    mv $outfile_path $outdir/$new_name
done

# Unzip Canvas output CNV using gunzip
gunzip ${outdir}/*.gz

# Upload results to DNA Nexus
dx-upload-all-outputs
