proc tabulate data = general.mensual out = t1.Tabla1;
        var num_empresas size size_US BM volumen precio precio BA_spread beta_1M Beta_12M errors_1M;
        table
                (num_empresas size size_US BM volumen precio precio BA_spread beta_1M Beta_12M errors_1M)
                ,
                (mean stddev skew kurt min max p10 p25 p50 p75 p90)
                ;
run;
