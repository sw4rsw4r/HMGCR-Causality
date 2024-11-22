library(vroom)
library(dplyr)

fname_LDLC <- "data/GWAS/GCST90239658_buildGRCh37.tsv"
fname_HDLC <- "data/GWAS/GCST90239652_buildGRCh37.tsv"
fname_HDLC_corrected <- "data/GWAS/GCST90239652_buildGRCh37_corrected_rsID.tsv"

if (!file.exists(fname_LDLC)) {
    download_addr_LDLC <- "http://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST90239001-GCST90240000/GCST90239658/GCST90239658_buildGRCh37.tsv"
    cmd <- paste0("wget ", download_addr_LDLC, " -O ", fname_LDLC)
    system(cmd)
}

df_ldlc <- vroom(fname_LDLC) %>%
    dplyr::filter(!is.na(variant_id)) %>%
    dplyr::select(chromosome, base_pair_location, effect_allele, other_allele, variant_id)

df_hdlc <- vroom(fname_HDLC)

merged <- df_hdlc %>%
    inner_join(df_ldlc, by = c("chromosome", "base_pair_location", "effect_allele", "other_allele")) %>%
    dplyr::select(-variant_id.x) %>%
    dplyr::rename(variant_id = variant_id.y)

write.table(merged, fname_HDLC_corrected, quote = F, row.names = F, col.names = T, sep = "\t")
