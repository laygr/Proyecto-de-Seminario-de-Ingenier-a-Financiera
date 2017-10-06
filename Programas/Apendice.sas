proc tabulate data = general.mensual out = ap.tabla3A;
        var  Lead_Ri_m_Rf SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M PRECIO VOLUMEN BA_SPREAD;
        table Lead_Ri_m_Rf SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M PRECIO VOLUMEN BA_SPREAD,
        (mean p1 p5 p10 p20 p80 p90 p95 p99);
run;
