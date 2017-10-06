%macro n_prior_rows_by_ticker(table, n, date, outputTable);
    data upToDate;
        set &table;
        where date <= &date;
    ;

    proc sort data=upToDate;
        by ticker descending date;
    run;

    data temp;
        set upToDate;
        by ticker;
        if first.ticker then num = 0;
        num +1;
    run;

    data temp;
        set temp;
        if num >= 1 and num <= &n ;
    run;

    proc sql noprint;
        create table tickers_with_n_obs as
        select distinct ticker
        from temp
        group by ticker
        having count(num) = &n
    ;
    %merge_by(temp, tickers_with_n_obs, ticker, &outputTable)
%mend n_prior_rows_by_ticker;

%macro one_year_window(inputTable, date, outputTable);
        %n_prior_rows_by_ticker(&inputTable, 250, &date, &outputTable)
%mend one_year_window;

%macro one_month_window(inputTable, date, outputTable);
        %let year = %sysfunc(year(&date));
    %let month = %sysfunc(month(&date));
    Data one_month;
        set &inputTable;
        if year = &year and month = &month;
    run;

        proc sql noprint;
                CREATE TABLE &outputTable AS
                select m.*
        from one_month as m
        where m.ticker in (
                select m2.ticker
            from one_month as m2
            group by m2.ticker
            having count(m2.ri)>= 15
        )
        order by m.ticker, m.date
    ;
%mend one_month_window;

/* step can be Day, Month, Year */
/* windowMacro(inputTable, date, outputTable) */
/* regresion(inputTable, date_reg, outputTable) */
%macro rolling_beta(inputTable, fromDate, toDate, step, windowMacro, regression, outputTable);
        proc sort data = &inputTable;
                by ticker;
        run;
        %let start=%sysfunc(inputn(&fromDate,anydtdte9.));
    %let end=%sysfunc(inputn(&toDate,anydtdte9.));
    %let dif=%sysfunc(intck(&step,&start,&end));
    %do i=0 %to &dif;
        %let date_i = %sysfunc(intnx(&step,&start,&i,same));
        %&windowMacro(&inputTable, &date_i, window)
        %&regression(window, &date_i, beta_results)
        %append_tables(&outputTable, beta_results)
    %end;

    Data &outputTable;
        set &outputTable;
        Year = Year(date_reg);
        Month = Month(date_reg);
        drop _MODEL_ _TYPE_ _DEPVAR_ RI_RF DATE_REG INTERCEPT;
    run;

%mend rolling_beta;
