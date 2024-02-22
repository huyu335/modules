process PVMAF_TAG {
    tag "$meta.id"
    label 'process_single'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/postprocessing_variant_calls:fix_concat7':
        'ghcr.io/msk-access/postprocessing_variant_calls:fix_concat7' }"

    input:
    tuple val(meta), path(maf)
    val(type)

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def output = prefix ? "${prefix}_${type}.maf": "multi_sample_${type}.maf"

    """
    pv maf tag \\
    $type \\
    -m $maf \\
    --output $output \\
    $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version  )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def output = prefix ? "${prefix}_${type}.maf": "multi_sample_${type}.maf"
    """
    touch $output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version  )
    END_VERSIONS
    """
}
