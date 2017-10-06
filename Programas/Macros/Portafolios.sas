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

        proc tabulate data = ranked out = t7.&outputTable (drop=_TYPE_);
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
                        where rank_&variable1 in (&nm1, 0) and rank_&variable2 eq &I;
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
                        where rank_&variable2 in (&nm1, 0) and rank_&variable1 eq &I;
                        class rank_&variable2;
                        title1 "Diferencia de medias rank_&variable2 con rank_&variable1=&I";
                run;
        %END;

%mend double_sort_independent;


%macro triple_sort_independent(inputTable, variable1, variable2, variable3, nGroups, outputTable);
        %sort_by(&inputTable, year month)

        proc rank data = &inputTable out = ranked groups = &nGroups;
                var &variable1 &variable2 &variable3;
                by year month;
                ranks rank_&variable1 rank_&variable2 rank_&variable3;
        run;

        proc tabulate data = ranked out = t7.&outputTable (drop=_TYPE_);
                class year month rank_&variable1 rank_&variable2 rank_&variable3;
                var Lead_Ri_m_Rf;
                table
                        rank_&variable1 * Lead_Ri_m_Rf * (mean t)
                        , rank_&variable2, rank_&variable3;
                title1 "Portafolios para rank_&variable1 con rank_&variable2 y rank_&variable3";
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
                        where rank_&variable1 in (&nm1, 0) and rank_&variable2 eq &I and rank_&variable3 eq &I;
                        class rank_&variable1;
                        title1 "Diferencia de medias rank_&variable1 con rank_&variable2 = &I y rank_&variable3 = &I";
                run;
        %END;

%mend triple_sort_independent;
