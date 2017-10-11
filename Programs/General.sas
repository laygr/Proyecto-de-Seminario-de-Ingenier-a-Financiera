proc sql noprint;
        create table empresas_por_mes as
    select t.year, t.month, count(t.ticker) as num_empresas
    from (
            select year, month, ticker
            from pre.diario
            group by year, month, ticker
        ) as t
    group by t.year, t.month
;

%monthly_values(
        pre.diario,
        volumen,
        BA_SPREAD BM PRECIO PRECIO_US SIZE SIZE_US,
        ri rf rmswrld ripc ri_m_rf ripc_m_rf,
        mensual)

%merge_by(mensual, empresas_por_mes, year month, mensual)

%lead_1Month(mensual, ri, lead_ri, mensual)
%lag_1Month(mensual, ri, lagged_ri, mensual)

%lead_1Month(mensual, ri_m_rf, lead_ri_m_rf, mensual)
%lag_1Month(mensual, ri_m_rf, lagged_ri_m_rf, mensual)

%lead_1Month(mensual, ripc, lead_ripc, mensual)

%macro riskPremiumReg(inputTable, date, outputTable);
        proc reg data = &inputTable noprint outest = results ;
                model ri_m_rf = ripc_m_rf;
                by ticker;
        run;

        data &outputTable;
                set results /*(keep = ticker rm_rf _rmse_)*/;
                rename _rmse_ = errors;
                rename  ripc_m_rf = beta;
                label ripc_m_rf = 'Beta';

                label _rmse_ = 'Volatilidad Idiosincrática';
                label ticker = 'ticker';
                date_reg = &date;
                Format date_reg ddmmyy10.;
        run;
%mend riskPremiumReg;

%rolling_beta(pre.Diario, 01MAY1990, 01JAN2016, Month, one_month_window, riskPremiumReg, general.betasMensuales)

%rolling_beta(pre.Diario, 01MAY1990, 01JAN2016, Month, one_year_window, riskPremiumReg, general.betasAnuales)


Data general.BetasMensuales;
        set general.BetasMensuales;
        rename
                Beta = Beta_1M
                errors = errors_1M;
                DROP ri_m_rf INTERCEPT;
run;

Data general.BetasAnuales;
        set general.BetasAnuales;
        rename Beta = Beta_12M;
        drop ri_m_rf errors INTERCEPT;
run;

%left_merge_by(mensual, general.BetasMensuales, year month ticker, general.Mensual);
%left_merge_by(general.Mensual, general.BetasAnuales, year month ticker, general.Mensual);


proc sort data = general.betasAnuales;
    by ticker year month;
run;
