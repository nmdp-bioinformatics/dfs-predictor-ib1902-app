# Haplodonor Selector

**Disease-Free Survival Predictor Shiny App (IB1902)**

**Version:** 1.0

**Author and Maintainer:** Stephanie Fingerson

Please, open an issue if you see any problems.


## Requirements For Running Locally
To run, you will need RStudio with R > 4.x and the following libraries:

```r
install.packages(c('shiny', 'DT', 'tibble', 'dplyr', 'plotly', 'shinyjs', 'shinyWidgets'))
```

Open an RStudio session in the project directory and run this to start the app locally.
```r
shiny::runApp()
```

## How to use the tool

### Introduction
This tool predicts the probability of disease-free survival from attributes of a HSCT donor-recipient pair based on the research findings of HLA Considerations in Haploidentical Stem Cell Transplantation (Fuchs E, McCurdy S, et al., 2021 in review). This retrospective study of 1434 patients uses a Cox proportional hazards model to better understand the effects of HLA locus-specific risks following haploidentical transplantation using PTCy.

**Disclaimer: This web tool is intended for research purposes only. This calculator is based on results from a CIBMTR analysis of HLA-haploidentical transplantation with PTCy for acute leukemia and myelodysplastic syndrome. It remains the responsibility of each medical professional to decide on the appropriate medical advice, diagnosis, and treatment for patients.**

The fields required for this tool are listed below. Other factors such as donor age and relationship were studied but not found to be significant in the multivariate model and so you will not see them in this tool.

### What you will need to use the tool:
To use this tool you will need the following patient and donor information:
Patient: Age, CMV Serostatus, HCT Co-Morbidity Index, high resolution HLA typing at HLA-B, HLA-DRB1, HLA-DQB1, HLA-DPB1 to determine match statuses as described below.
Donor: CMV Serostatus, high resolution HLA typing at HLA-B, HLA-DRB1, HLA-DQB1, HLA-DPB1 to determine match statuses as described below.

### HCT Co-Morbidity Index
This predicts the mortality of a patient with different comorbid conditions. You will need to know if this score is 0, 1, 2, or higher than 3. You can calculate this score using this HCT CI Calculator (http://www.hctci.org/Home/Calculator).

### B Leader Match Status
You will need to know if the donor and patient B leaders are matched or mismatched. This paper has information on how to calculate the status using the patient and donor HLA-B typing (Petersdorf et al., 2020). Additionally, there are two tools you can use to calculate it. BTM B Leader Matching Tool (https://bleader.nmdp.org/) (Sajulga et al., 2021 accepted) to have it calculate the status for you.

### HLA-DRB1 and HLA-DQB1 GVH Match Status
You will need to know if the donor and patient are matched or mismatched at HLA-DRB1 and HLA-DQB1 based on whether the donor and recipient typing is the same at the highest level of resolution of the alleles. The tool will still work if you do not have HLA-DQB1 information (Spellman et al., 2008).

### HLA-DPB1 T-Cell Epitope (TCE) Match Status
If you have HLA-DPB1 high resolution typing, entering whether the donor and patient are matched/ permissively mismatched or non-permissively mismatched will give you more accurate DFS estimates. You can use this IMGT DPB1 TCE Epitope Tool (https://www.ebi.ac.uk/ipd/imgt/hla/dpb_v2.html) to calculate the status based on HLA-DPB1 T-Cell epitopes (Crivello et al. 2015). The tool will still work if you do not have this information.

#### References
(Fuchs E, McCurdy S, et al., 2021) Paper in Review.

(Petersdorf et al., 2020) https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6948919/

(Sajulga et al., 2021 accepted) Link available soon.

(Spellman et al., 2008) https://www.astctjournal.org/article/S1083-8791(08)00183-3/fulltext

(Crivello et al. 2015) https://www.astctjournal.org/article/S1083-8791(14)00656-9/fulltext
