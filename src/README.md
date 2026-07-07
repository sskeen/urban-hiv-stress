
# src/

Source code for Urban life stress and HIV among Black PWH in New Orleans.

| File | Description |
| ---- | ----------- |
| `gent_patdown_analysis model C.R` | Runs model C PTSD symptomology analyses. |
| `Gentrification Patdown CD4 Smith MGMT` | Creates ecological dataset for model E, calculateds residential-based 911 exposures. |
| `poe_map model  E.R` | Creates New Orleans Gentrification map, runs Model E (ecological) analyses. |
| `efa_modela_modelb_margins.do` | Imports, cleans, de-identifies, $N$ = 395 NOAH BL cohort sample and $n$ = 274 geolinkable BL subsample. Computes weighted Factor 1 ("Hyperlocal everyday stressors") and Factor 2 ("Strife and disorder stressors") composite indices. Fits sequential Model A: $y_i$ = depressive symptom severity, Model B: $y_i$ = sub/optimal CD4 count iterating over multilevel control sets, plus post-estimation marginal effects.|
| `plot_efa_network.py` | Generates publication-quality exploratory factor analysis (EFA) network diagram. |
