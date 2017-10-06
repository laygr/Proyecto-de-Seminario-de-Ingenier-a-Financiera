%macro fama_macbeth(inputTable, dependentVariable, independentVariables, outputTable);
    %sort_by(&inputTable, Year Month)
    proc reg
        data = &inputTable
        outest = gammasTable
        rsquare
        noprint
        ;
        model &dependentVariable = %do_over(values = &independentVariables, phrase= ? );
        by year month;
        output cookd = cookd;

    run;

    %sort_by(gammasTable, &independentVariables)
    proc means data = gammasTable noprint;
        var %do_over(values = &independentVariables, phrase= ? ) _RSQ_;
        output
            out = &outputTable
            mean = t = /autoname
        ;

    run;
%mend;
