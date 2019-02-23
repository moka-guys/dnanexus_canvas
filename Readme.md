# Canvas Germline-WGS v1.1
Illumina/canvas [v1.39.0.1598](https://github.com/Illumina/canvas/releases/tag/1.39.0.1598+master)

## What does this app do?

Canvas identifies copy number variants (CNVs) from whole genome sequencing (WGS) data. This app packages the Canvas SmallPedigree-WGS submodule for Germline CNV calling on DNA Nexus.

## What are typical use cases for this app?

Call CNVs from a single sample WGS alignment. Returns a variant call format (VCF) file.

## What data are required for this app to run?

|Input|Description|
|---|---|
|`*.bam`|WGS sample aligned to the **hg19** reference genome|
|`*.bai`|Index file for the input BAM|

Optional inputs can be provided to ignore regions or mark regions of known common variation and ploidy. Details can be found on the [Canvas Wiki](https://github.com/Illumina/canvas/wiki).

Canvas requires a reference genome and associated index files. The files for reference hg19 are linked as a default app input in a compressed tar file. Specifically this contains:
* The reference genome (`genome.fa`) and index (`genome.fa.fai`)
* An XML file (`GenomeSize.xml`) containing Genome Size data specific to the reference genome file
* The Canvas-ready reference fasta file (`kmer.fa`) and index (`kmer.fa.fai`)
* A VCF (`dbsnp.vcf`) containing sites of SNVs and small indels in the normal sample; used to determine which germline SNPs are heterozygous
* A BED file of regions to skip. The bed file provided with Canvas (`filter13.bed`) contains standard centromere regions to be skipped

## What does this app output?

The following outputs can be found in the `Results/canvas_out` directory:
* A VCF with CNV calls for the input sample (`*.vcf.gz`).
* A statistics file with coverage and variant frequency for each 100Kb window of the reference genome is also produced, along with various log files (`*.CoverageAndVariantFrequency.txt`).

## Additional notes

* Canvas does not fully support custom reference genomes due to the requirement of an XML file containing genome contig sizes (`GenomeSize.xml`), specific to the reference genome build used. There is currently no automated process for generating this file for custom references, however this file is provided for builds hg19, GRCh37 and GRCh38. The required reference files for Canvas are available here (http://canvas-cnv-public.s3.amazonaws.com/).

* This app uses the reference build hg19 and associated Canvas files, therefore the sample BAM must be generated from WGS reads aligned to this reference. The reference files for BWA and Canvas are packaged in DNA Nexus under 001_ToolsReferenceData:/Data/ReferenceGenomes/

## This app was made by Viapath Genome Informatics
