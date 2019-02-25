#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#### Functions ####
build_path () {
# Build a string containing optional command line flag for Canvas.
# Returns:
#   A canvas option string if the second argument is not an empty string.
# Example:
#   $ build_path "--filter-bed" "bed_file.bed"
#   >> " --filter-bed bed_file.bed"
    fopt=$1
    fpath=$2
    [[ ! -z $fpath ]] && echo " $fopt $fpath" || echo ""
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
mv $input_bam_index_path /home/dnanexus/in/input_bam/

# Create Canvas output directory for data upload
outdir=out/canvas/Results/canvas_out/
# Create temporary directory for renaming data
mkdir -p $outdir tempdir 

# Set canvas flags based on app inputs using the `build_path` function
extra_opts=""
extra_opts+=$(build_path "--ploidy-vcf" "$ploidy_vcf_path")
extra_opts+=$(build_path "--common-cnvs-bed" "$common_cnvs_bed_path")
# Use reference bundle filter file if no alternative is given as an app input
if [[ ! -z $filter_bed_path ]]; then
    extra_opts+=$(build_path "--filter-bed" "$filter_bed_path")
else
    extra_opts+=$(build_path "--filter-bed" "reference/filter13.bed")
fi

# Run Canvas SmallPedigree workflow for CNV calling
dotnet Canvas-1.39.0.1598+master_x64/Canvas.dll SmallPedigree-WGS \
    --bam=$input_bam_path \
    --population-b-allele-vcf=reference/dbsnp.vcf \
    --reference=reference/kmer.fa \
    --genome-folder=$genome_dir \
    --output=tempdir \
    $extra_opts # Note filter_13.bed packaged with app is used here.

# Move desired outputs to upload directory
mv tempdir/*.txt tempdir/*vcf.gz $outdir
# Change prepend BAM file name to output files
for outfile_path in $outdir/*; do
    new_name=$input_bam_prefix.$(basename $outfile_path)
    mv $outfile_path $outdir/$new_name
done

# Unzip output VCF containing CNV calls
gunzip ${outdir}/*.gz

# Upload results to DNA Nexus
dx-upload-all-outputs
