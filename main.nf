#!/usr/bin/env nextflow

params.peptides = "$baseDir/data/small-yeast.fasta"
params.spectra = "$baseDir/data/demo.ms2"

peptides = file(params.peptides)
spectra = file(params.spectra)


process indexPeptides {  
    
    //container 'omicsdi/crux:latest'   
    container 'bc/crux:latest'

    publishDir "$baseDir/data/" 
    
    input:
    file small_yeast from peptides
    file demo_ms2 from spectra

    output:
    file 'crux-output/tide-search.target.txt' into searchResults
    file 'crux-output/tide-search.decoy.txt' into decoyResults

    script:
    """
    crux tide-index $small_yeast yeast-index
    crux tide-search --compute-sp T --mzid-output T $demo_ms2 yeast-index
    """
}

process postProcess {    
    
    container 'bc/crux:latest'
    input:
    file 'search.target.txt' from searchResults        
    file 'search.decoy.txt' from decoyResults

    output:
    file 'crux-output/percolator.target.psms.txt' into percResults

    script:
    """
    crux percolator search.target.txt
    """
}
