proc rank
        data = general.mensual
        out = beta_ranked groups=3;

    var beta_1M;
    where year = 2000
      and month = 12;
    ranks beta_rank;
run;

proc tabulate data = beta_ranked;
        var beta_1M lead_Ri;
        class beta_rank name;
        table
                beta_rank='Beta Rank', name='Stock', mean=''*(Beta_1M Lead_Ri);
run;

%DifferenceOfPortfolios(beta_ranked, beta_rank, 3, Beta_1M Lead_Ri, diferencia)
%union_by(beta_ranked, diferencia, YEAR MONTH BETA_1M Lead_Ri Beta_Rank, con_diferencia )

proc tabulate data = con_diferencia;
        var beta_1M lead_Ri;
        class beta_rank;
        table mean='Promedios'*(Beta_1M Lead_Ri), beta_rank='Beta Rank';
run;

%macro union_by(table1, table2, variables, outputTable);
        proc sql;
        create table &outputTable as
        select %do_over(values = &variables, phrase=o.?, between=comma)
        from &table1 as o
        union
        select %do_over(values = &variables, phrase=l_m_s.?, between=comma)
        from &table2 as l_m_s
;
%mend;
