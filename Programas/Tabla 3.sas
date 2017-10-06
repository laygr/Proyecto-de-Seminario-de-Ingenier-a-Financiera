proc tabulate data = general.mensual;
        var num_empresas size size_US BM volumen precio precio BA_spread beta_1M Beta_12M errors_1M;
        class year;
        table
                year,
                (mean) *
                (num_empresas size size_US BM volumen precio precio BA_spread beta_1M Beta_12M errors_1M)

                ;
run;
