%macro DifferenceOfPortfolios(rankedportfolios, rankvariable, newGroup, variables, outputTable);
        proc sql;
        create table &outputTable as
        select l.Year, l.Month, &newGroup as &rankvariable,
                %do_over(values = &variables, phrase=(l.? - s.?) as ?, between=comma)
        from &rankedportfolios as l
        inner join &rankedportfolios as s
        on l.year = s.year
        and l.month = s.month
        and l.&rankvariable = (&newGroup - 1)
        and s.&rankvariable = 0
        ;
%mend;

%macro single_sort(inputTable, variable, nGroups, weighted, output_table);
    proc sort data = &inputTable;
            by year month &variable;
    run;
    proc rank data = &inputTable out = ranked_variable groups = &nGroups;
        var &variable;
        by year month;
        ranks rank_&variable;
    run;

    proc means data = ranked_variable noprint;
        var Lead_Ri Lead_ri_m_rf Beta_1M ripc_m_rf %if &weighted = 1 %then %str(/ weight = SIZE);;
        output
                out = portfolios_by_variable
                mean = t = /autoname
        ;
        by year month rank_&variable;
    run;
    Data portfolios_by_variable;
        set portfolios_by_variable;
        Alpha = Lead_Ri_m_rf_mean - Beta_1M_mean * ripc_m_rf_mean;
    run;

    %DifferenceOfPortfolios(portfolios_by_variable, rank_&variable, &nGroups, Lead_ri_Mean Lead_Ri_M_Rf_Mean alpha, newPortfolio)
    %union_by(portfolios_by_variable, newPortfolio, year month Lead_ri_Mean Lead_Ri_M_Rf_Mean alpha rank_&variable, portfolios_by_variable)

    proc sort data = portfolios_by_variable;
        by rank_&variable;
    run;

    proc means data = portfolios_by_variable noprint;
        var Lead_Ri_Mean Lead_Ri_M_Rf_Mean Alpha;
        output
                out = &output_table
                mean = t = /autoname
        ;
        by rank_&variable;
    run;

%mend single_sort;

%macro double_sort_independent(inputTable, variable1, variable2, nGroups, outputTable);
        %sort_by(&inputTable, year month)

        proc rank data = &inputTable out = ranked groups = &nGroups;
                var &variable1 &variable2;
                by year month;
                ranks rank_&variable1 rank_&variable2;
        run;

        proc tabulate data = ranked out = &outputTable (drop=_TYPE_);
                class year month rank_&variable1 rank_&variable2;
                var Lead_Ri_m_Rf;
                table
                        rank_&variable2 * Lead_Ri_m_Rf * (mean t)
                        , rank_&variable1;
                title1 "Portafolios para rank_&variable1 con rank_&variable2";
        run;

        %let nm1 = %Eval(&nGroups - 1);

         /* Fixing the first variable */
        %sort_by(ranked, &variable1)

        proc ttest data=ranked plots=none;
                var Lead_Ri_m_Rf;
                where rank_&variable1 in (&nm1,0);
                class rank_&variable1;
                title1 "Diferencia de medias rank_&variable1";
        run;

         %DO I = 0 %TO &nGroups-1;
                proc ttest data=ranked plots=none;
                        var Lead_Ri_m_Rf;
                        where rank_&variable1 in (&nm1, 0)
                                and rank_&variable2 eq &I;
                        class rank_&variable1;
                        title1 "Diferencia de medias rank_&variable1 con rank_&variable2=&I";
                run;
        %END;

         /* Fixing the second variable */
        %sort_by(ranked, &variable2)

        proc ttest data=ranked plots=none;
                var Lead_Ri_m_Rf;
                where rank_&variable2 in (&nm1,0);
                class rank_&variable2;
                title1 "Diferencia de medias rank_&variable2";
        run;

         %DO I = 0 %TO &nGroups-1;
                proc ttest data=ranked plots=none;
                        var Lead_Ri_m_Rf;
                        where rank_&variable2 in (&nm1, 0)
                                and rank_&variable1 eq &I;
                        class rank_&variable2;
                        title1 "Diferencia de medias rank_&variable2 con rank_&variable1=&I";
                run;
        %END;

%mend double_sort_independent;

%macro analyze_variable_of_3(ranked, variable1, variable2, variable3, nGroupsm1, outputTable);
	%delete_tables(&outputTable)
  %sort_by(&ranked, &variable1)
  %DO I = 0 %TO &nGroupsm1;
    %DO J = 0 %TO &nGroupsm1;
      ods output statistics=stats ttests=ttests equality=equality;
      proc ttest data=&ranked plots=none;
        var Lead_Ri_m_Rf;
        where rank_&variable1 in (&nGroupsm1, 0)
          and rank_&variable2 eq &I
          and rank_&variable3 eq &J;
        class rank_&variable1;
      run;
      ods output close;
      proc sql;
      	create table portfolio_diff as
      	select
      		stats.mean as fixed_v_mean,
      		stats.StdDev as fixed_v_stddev,
      		ttests.tValue as fixed_v_t
      	from stats as stats
      	join ttests as ttests
      	on stats.variable = ttests.variable
      	where stats.class like 'Diff%' and ttests.Method = "Agrupado"
      ;
      Data portfolio_diff;
		    set portfolio_diff;
		    length fixed_v $25;
		    length ctrl_v_1 $25;
		    length ctrl_v_2 $25;
		    
		    fixed_v = "&variable1" ;
		    ctrl_v_1 = "&variable2" ;
		    ctrl_v_2 = "&variable3" ;
		    
		    ctrl_v_1_Rank = &I ;
		    ctrl_v_2_Rank = &J ;
  		Run;
  		%append_tables(&outputTable, portfolio_diff)
    %END;
  %END;
   
%mend;

%macro triple_sort_independent(inputTable, variable1, variable2, variable3, nGroups, outputTable);
  %delete_tables(&outputTable)
  %sort_by(&inputTable, year month)

  proc rank data = &inputTable out = ranked groups = &nGroups;
    var &variable1 &variable2 &variable3;
    by year month;
    ranks rank_&variable1 rank_&variable2 rank_&variable3;
  run;

  %let nm1 = %Eval(&nGroups - 1);

  /* Fixing the first, second and third variable */
  %analyze_variable_of_3(ranked, &variable1, &variable2, &variable3, &nm1, fixed1)
  %analyze_variable_of_3(ranked, &variable2, &variable3, &variable1, &nm1, fixed2)
  %analyze_variable_of_3(ranked, &variable3, &variable1, &variable2, &nm1, fixed3)

  %append_tables(&outputTable, fixed1 fixed2 fixed3)

%mend triple_sort_independent;
