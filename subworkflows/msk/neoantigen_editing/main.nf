include { NEOANTIGENEDITING_ALIGNTOIEDB      } from '../../../modules/msk/neoantigenediting/aligntoIEDB'
include { NEOANTIGENEDITING_COMPUTEFITNESS   } from '../../../modules/msk/neoantigenediting/computeFitness'


workflow NEOANTIGEN_EDITING {

    take:
    neoantigenInput_ch
    iedbfasta

    main:

    ch_versions = Channel.empty()

    NEOANTIGENEDITING_ALIGNTOIEDB (neoantigenInput_ch, iedbfasta)
    ch_versions = ch_versions.mix(NEOANTIGENEDITING_ALIGNTOIEDB.out.versions.first())


    NEOANTIGENEDITING_COMPUTEFITNESS ( neoantigenInput_ch , NEOANTIGENEDITING_ALIGNTOIEDB.out.iedb_alignment  )

    ch_versions = ch_versions.mix(NEOANTIGENEDITING_COMPUTEFITNESS.out.versions.first())

    emit:
    annotated_output      = NEOANTIGENEDITING_COMPUTEFITNESS.out.annotated_output           // channel: [ val(meta), [ annotated_json ] ]
    versions = ch_versions                     // channel: [ versions.yml ]
}