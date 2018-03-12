#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

# Install required libraries via apt-get
sudo apt-get install -y libunwind8

# Download input bam file and canvas refs to $HOME/in/
dx-download-all-inputs
# Move input bam index file to location expected by Canvas
mv $input_bam_index_path /home/dnanexus/in/input_bam/${input_bam_index_prefix}.bam.bai

# Extract Canvas binaries and set executeable permissions
tar -xzvf Canvas-1.34.0.1201.master_x64.tar.gz
sudo chmod 755 -R Canvas-1.34.0.1201+master_x64/

# Extract reference genome data to working directory ($HOME)
tar -xzvf $canvas_ref_path
# Create reference genome directory structure expected by Canvas
canvas_dir=reference/Homo_sapiens/NCBI/GRCh37/Sequence/WholeGenomeFasta
mkdir -p $canvas_dir
# Move reference genome data to new directory ($canvas_dir)
mv CanvasGRCh37/* $canvas_dir/

# Create Canvas output directory
outdir=out/canvas/canvas_out/$input_bam_index_prefix
mkdir -p $outdir

# Run Canvas Germline-WGS for CNV calling
dotnet Canvas-1.34.0.1201+master_x64/Canvas.dll Germline-WGS --bam=$input_bam_path \
    --sample-name=$input_bam_prefix \
    --genome-folder=$canvas_dir \
    --reference=$canvas_dir/kmer.fa \
    --population-b-allele-vcf=$canvas_dir/dbsnp.vcf \
    --filter-bed=$canvas_dir/filter13.bed \
    --output=$outdir \

# Change prefix of output files to input BAM sample name
rename "s/CNV/$input_bam_prefix/" $outdir/CNV*

# Upload results to DNA Nexus
dx-upload-all-outputs
