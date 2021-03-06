%macro all_triple_portfolios(inputTable, combinations, variables, outputTable);
  %delete_tables(total)
  Data prueba;
    set &combinations;

    call execute(
        '%let v1 = %scan(&variables, ' || variables1 || ');'||
        '%let v2 = %scan(&variables, ' || variables2 || ');'||
        '%let v3 = %scan(&variables, ' || variables3 || ');'||
        '%triple_sort_independent(&inputTable, &v1, &v2, &v3, 3, acum)'||
        '%append_tables(total, acum)'
    );
  run;
  
  proc sql;
  create table &outputTable as
  select
  	fixed_v,
  	avg(fixed_v_mean) as mean_mean,
  	avg(fixed_v_stddev) as stddev_mean,
  	count(fixed_v_t) as significance_count
  from total
  where fixed_v_t < -1.65 OR fixed_v_t > 1.65
  group by fixed_v
  ;

%mend all_triple_portfolios;

proc plan;
    factors
    	block = 84 ordered
    	variables= 3 of 9 comb;
    ods output Plan= combinations;
run;

%all_triple_portfolios(general.mensual, combinations,
        SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M precio volumen BA_spread,
        t8.byVariables
)
/* PCA */
%sort_by(general.mensual, year month ticker)
proc princomp
	data = general.mensual
	output = pc
	standard
	plots=patternprofile;
	var SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M precio volumen BA_spread;
run;
%all_triple_portfolios(pc, combinations,
        prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9,
        t8.byPrincipalComponents
)