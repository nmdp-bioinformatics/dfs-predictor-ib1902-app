#
# Copyright (c) 2021 Be The Match.
#
# This file is part of Haplo-Donor Selector Disease-Free Survival Predictor 
# (see https://github.com/nmdp-bioinformatics/dfs-predictor-ib1902-app).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

library(shiny)
library(DT)
library(tibble)
library(dplyr)
library(plotly)
library(shinyjs)
library(shinyWidgets)

dr_raw_base <- as_tibble(readRDS("data/ib1902_dr_3yr.rds"))
drdq_raw_base <- as_tibble(readRDS("data/ib1902_drdq_3yr.rds"))

### setting text and url values for intro page
  
version_text <- "<strong>Version: 1.0</strong>"

disclaimer_text <- "<strong>Disclaimer:</strong> This web tool is intended for research purposes only. This calculator is based on results from a CIBMTR analysis of HLA-haploidentical transplantation with PTCy for acute leukemia and myelodysplastic syndrome. It remains the responsibility of each medical professional to decide on the appropriate medical advice, diagnosis, and treatment for patients."

study_url <- ""
intro_header <-"<h4 class='section-header'>Introduction</h4>"
intro_text <- paste0("<p>This tool predicts the probability of disease-free survival from attributes of a HSCT donor-recipient pair based on the research findings of <strong>HLA Considerations in Haploidentical Stem Cell Transplantation </strong> <a href='",study_url,"' target='_blank'>(Fuchs E, McCurdy S, et al., 2021)</a>.  This retrospective study of 1434 patients uses a Cox proportional hazards model to better understand the effects of HLA locus-specific risks following haploidentical transplantation using PTCy. </p>")


need_text <- "<p>The fields required for this tool are listed below.  Other factors such as donor age and relationship were studied but not found to be significant in the multivariate model and so you will not see them in this tool.</p> <h4 class='section-header'>What you will need:</h4> <p>To use this tool you will need the following patient and donor information:<br><strong>Patient:</strong> Age, CMV Serostatus, HCT Co-Morbidity Index, high resolution HLA typing at HLA-B, HLA-DRB1, HLA-DQB1, HLA-DPB1 to determine match statuses as described below.<br><strong>Donor:</strong> CMV Serostatus, high resolution HLA typing at HLA-B, HLA-DRB1, HLA-DQB1, HLA-DPB1 to determine match statuses as described below.</p>"

ci_url <- 'http://www.hctci.org/Home/Calculator'
ci_text <- paste0("<h5 class='section-header'>HCT Co-Morbidity Index</h5><p>This predicts the mortality of a patient with different comorbid conditions. You will need to know if this score is 0, 1, 2, or higher than 3.  You can calculate this score using this  <a href='",ci_url,"' target='_blank'>HCT CI Calculator</a> to calculate it.")

bleader_tool_url <- "https://bleader.nmdp.org/"
bleader_tool_paper_url <- ""
bleader_paper_url <- "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6948919/"
bleader_text <- paste0("<h5 class='section-header'>B Leader Match Status</h5><p>You will need to know if the donor and patient B leaders are matched or mismatched. You can use the information in this paper to calculate the status using the patient and donor HLA-B typing <a href='",bleader_paper_url,"' target='_blank'>(Petersdorf et al., 2020)</a>. Additionally, if you are able to log into MatchSource you can also request access to this <a href='",bleader_tool_url,"' target='_blank'>B Leader Matching Tool</a> <a href='",bleader_tool_paper_url,"' target='_blank'>(Sajulga et al., 2021 in review)</a> to have it calculate the status for you.</p>")

hla_url <- 'https://www.tctjournal.org/article/S1083-8791(08)00183-3/fulltext'
drb1_text <- paste0("<h5 class='section-header'>HLA-DRB1 and HLA-DQB1 GVH Match Status</h5> <p>You will need to know if the donor and patient are matched or mismatched at HLA-DRB1 and HLA-DQB1 based on whether the donor and recipient typing is the same at the highest level of resolution of the alleles.  The tool will still work if you do not have HLA-DQB1 information <a href='",hla_url,"' target='_blank'>(Spellman et al., 2008)</a>.</p>")

imgt_tce_url <- 'https://www.ebi.ac.uk/ipd/imgt/hla/dpb_v2.html'
tce_url <- 'https://www.tctjournal.org/article/S1083-8791(14)00656-9/fulltext'
tce_text <- paste0("<h5 class='section-header'>HLA-DPB1 T-Cell Epitope (TCE) Match Status</h5><p>If you have HLA-DPB1 high resolution typing, entering whether the donor and patient are matched/ permissively mismatched or non-permissively mismatched will give you more accurate DFS estimates. You can use this <a href='",imgt_tce_url,"' target='_blank'>IMGT DPB1 TCE Epitope Tool</a> to calculate the status based on HLA-DPB1 T-Cell epitopes <a href='",tce_url,"' target='_blank'>(Crivello et al. 2015)</a>. The tool will still work if you do not have this information.</p>")

cite_text <- "<p><strong>To cite this tool:</strong></p>"


