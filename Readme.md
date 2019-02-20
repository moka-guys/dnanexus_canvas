# Canvas Germline-WGS v1.0
Illumina/canvas [v1.34.0.1201](https://github.com/Illumina/canvas/releases/tag/1.34.0.1201%2Bmaster)

## What does this app do?

Canvas identifies copy number variants (CNVs) from whole genome sequencing (WGS) data. Canvas is designed to work with germline data or paired tumor/normal samples. This app packages the Canvas Germline-WGS module for the DNA Nexus platform.

## What are typical use cases for this app?

This app is designed to be run on an alignment file from a single WGS sample, returning a variant call format (VCF) output file containing the location and details of copy number variants in the genome, detected using Canvas.

## What data are required for this app to run?

The following inputs are required for this app to run:
* An alignment (`*.bam`) of a human WGS sample to the **hg19** reference genome using BWA
* A BAM index file (`*.bai`) derived from the same alignment as the input bam sequence 

In addition to the input files, the Canvas Germline-WGS module requires the following reference data, all of which are packaged with the app on DNA Nexus:
* The reference genome (`genome.fa`) and index (`genome.fa.fai`)
* An XML file (`GenomeSize.xml`) containing Genome Size data specific to the reference genome file
* The Canvas-ready reference fasta file (`kmer.fa`) and index (`kmer.fa.fai`)
* A VCF (`dbsnp.vcf`) containing sites of SNVs and small indels in the normal sample; used to determine which germline SNPs are heterozygous
* A BED file of regions to skip. The bed file provided with Canvas (`filter13.bed`) contains standard centromere regions to be skipped

Note: Canvas does not fully support custom reference genomes due to the requirement of an XML file containing genome contig sizes (`GenomeSize.xml`), specific to the reference genome build used. There is currently no automated process for generating this file for custom references, however this file is provided for builds hg19, GRCh37 and GRCh38. The required reference files for Canvas are available here (http://canvas-cnv-public.s3.amazonaws.com/).

This app uses the reference build hg19 and associated Canvas files, therefore the sample BAM must be generated from WGS reads aligned to this reference. The reference files for BWA and Canvas are packaged in DNA Nexus under 001_ToolsReferenceData:/Data/ReferenceGenomes/

## What does this app output?

The primary output of this app is a VCF report (`*.vcf.gz`) containing the CNV calls for the input sample. A statistics file (`*.CoverageAndVariantFrequency.txt`) containing coverage and variant frequency for each 100Kb window of the reference genome is also produced, along with various log files.

## This app was made by Viapath Genome Informatics
