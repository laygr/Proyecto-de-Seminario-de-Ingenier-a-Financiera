/*
 * %lag_1Month(table, dataColumn, laggedDataName, outputTable)
 * %lead_1Month(table, dataColumn, leadDataName, outputTable)
 * %append_tables(tabla1, tabla2)
 */

%macro sort_by(inputTable, variables);
        proc sort data = &inputTable;
                by %do_over(values = &variables, phrase = ? );
        run;
%mend;

%macro winsorizing(inputTable, variables, lowP, highP, outputTable);
	proc tabulate data = &inputTable out = limits;
	  var &variables ;
	  class Date ;
	  table
	  	Date,
	  	&variables,
	  	(&lowP &highP);
	  
	run;

	%left_merge_by(&inputTable, limits, Date, with_limits)
	
	data &outputTable;
		set with_limits;
	  %do_over(
	       values = &variables
	       , phrase = if ? > ?_&highP then ? = ?_&highP;  if ? < ?_&lowP then ? = ?_&lowP;
	  )
	  drop _Type_ _Page_ _Table_ %do_over(values = &variables, phrase = ?_&lowP ?_&highP) ;
	run;

%mend;

%macro merge_by(table1, table2, variables, outputTable);
        %sort_by(&table1, &variables)
        %sort_by(&table2, &variables)

        data &outputTable;
            merge
                &table1 (in=in1)
                &table2 (in=in2);
            if (in1 and in2) then output &outputTable;
            by %do_over(values = &variables, phrase = ? );
        Run;
%mend;

%macro left_merge_by(table1, table2, variables, outputTable);
        proc sort data = &table1;
                by %do_over(values = &variables, phrase = ? );
        Run;

        Proc sort data = &table2;
                by %do_over(values = &variables, phrase = ? );
        Run;

        data &outputTable;
            merge
                &table1 (in=in1)
                &table2 (in=in2);
            if (in1) then output &outputTable;
            by %do_over(values = &variables, phrase = ? );
        Run;
%mend;

%macro cartesian_product(table1, table2, outputTable);
        proc sql;
                create table &outputTable as
                select *
                from &table1 , &table2
        ;
%mend;

%macro replace_missings_by_monthly_avg(inputTable, variables, outputTable);
        PROC SQL;
        CREATE TABLE promedios_mensuales as
        SELECT
                YEAR, MONTH, TICKER,
                %do_over(values=&variables, phrase = AVG(?) as ?_avg, between=comma)
        FROM &inputTable
        GROUP BY YEAR, MONTH, TICKER
        ;
        %merge_by(&inputTable, promedios_mensuales, YEAR MONTH TICKER, con_promedios)
        data &outputTable;
                set con_promedios;
                %do_over(values=&variables, phrase= if ? eq . THEN ? = ?_avg, between=%str(;)) ;
                drop %do_over(values=&variables, phrase= ?_avg) ;
        run;
%mend;

%macro replace_missings_by_annual_avg(inputTable, variables, outputTable);
        PROC SQL;
        CREATE TABLE promedios_anuales as
        SELECT
                YEAR, TICKER,
                %do_over(values=&variables, phrase = AVG(?) as ?_avg, between=comma)
        FROM &inputTable
        WHERE BM IS NOT NULL
        GROUP BY YEAR, TICKER
        ;
        %left_merge_by(&inputTable, promedios_anuales, YEAR TICKER, con_promedios)
        data &outputTable;
                set con_promedios;
                %do_over(values=&variables, phrase= if ? eq . THEN ? = ?_avg, between=%str(;)) ;
                drop %do_over(values=&variables, phrase= ?_avg) ;
        run;
%mend;

%macro replace_miss_2y_avg(inputTable, variables, outputTable);
        PROC SQL;
        CREATE TABLE promedios_anuales as
        SELECT
                YEAR, TICKER,
                %do_over(values=&variables, phrase = AVG(?) as ?_avg, between=comma)
        FROM &inputTable
        WHERE BM IS NOT NULL
        GROUP BY YEAR, TICKER
        ;
        %do_over(values = &variables, phrase = %shift_n_Months(promedios_anuales, ?_avg, ?_avg_lagged, 2, promedios_anuales))


        %merge_by(&inputTable, promedios_anuales, YEAR TICKER, con_promedios)
        data &outputTable;
                set con_promedios;
                %do_over(values=&variables, phrase= if ? eq . THEN ? = (?_avg + ?_avg_lagged)/2;)
                drop %do_over(values=&variables, phrase= ?_avg ?_avg_lagged) ;
        run;
%mend;

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



%macro monthly_values(inputTable, toBeAdded, toBeAveraged, toArithmetic, outputTable);
        data with_logs;
                set &inputTable;
                %do_over(values = &toArithmetic, phrase = log_? = log(? + 1);)
        run;

        proc tabulate data=with_logs out=mensual_temp;
                var
                        %do_over(values = &toBeAveraged, phrase = ? )
                        %do_over(values = &toBeAdded, phrase = ? )
                        %do_over(values = &toArithmetic, phrase = ?)
                ;

                class year month ticker;
                table
                        year * month * ticker
                        ,
                    n
                    (%do_over(values = &toBeAveraged, phrase = ? )) * mean
                    (
                                %do_over(values = &toBeAdded, phrase = ? )
                                %do_over(values = &toArithmetic, phrase = ?)
                        ) * sum
                ;
        run;

        data &outputTable;
                set mensual_temp;
                Format Date ddmmyy10.;
                %do_over(values = &toArithmetic, phrase = ? = exp(?_SUM) - 1;)
                rename
                        n = dias
                        %do_over(values = &toBeAveraged, phrase = ?_MEAN = ?)
                        %do_over(values = &toBeAdded, phrase = ?_SUM = ?)
                ;
                drop
                        _table_
                        _type_
                        _page_
                        Date
                        %do_over(values = &toBeAveraged, phrase = ? )
                        %do_over(values = &toBeAdded, phrase = ? )
                        %do_over(values = &toArithmetic, phrase = ?_SUM)
                        %do_over(values = &toArithmetic, phrase = log_?)
                ;
        run;

        proc sql noprint;
                create table ticker_names as
                select distinct ticker, name
                from &inputTable
                group by ticker;

        %merge_by(&outputTable, ticker_names, ticker, &outputTable)
%mend;

%macro shift_n_Months(table, dataColumn, shiftedDataName, n, outputTable);
        PROC SQL;
            create table &outputTable as
            select notShifted.*, shifted.&dataColumn as &shiftedDataName
            from &table as notShifted
            left join &table as shifted
            on mdy(notShifted.Month, 1, notShifted.Year) = intnx('Month', mdy(shifted.Month, 1, shifted.Year), &n)
            and notShifted.ticker = shifted.ticker
            ;
        Quit;
%mend;

%macro lag_1Month(table, dataColumn, laggedDataName, outputTable);
        %shift_n_Months(&table, &dataColumn, &laggedDataName, 1, &outputTable);
%mend;

%macro lead_1Month(table, dataColumn, leadDataName, outputTable);
        %shift_n_Months(&table, &dataColumn, &leadDataName, -1, &outputTable);
%mend;

/* Macro para adjuntar tabla1 y tabla 2*/
%macro append_tables(tabla1, tabla2);
    proc append base = &tabla1 data = &tabla2;
    run;
%mend append_tables;
