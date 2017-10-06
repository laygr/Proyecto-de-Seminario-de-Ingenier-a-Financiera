Data t0.Panel_A;
        Set general.mensual;
        where ticker = 'MX:HZB'
        and month = 6 and year = 2000;
Run;
Proc tabulate
        data = general.mensual
        out = t0.panel_B (drop= _table_ _type_ _page_)
        ;

        var dias size size_US BM volumen precio precio_US BA_spread beta_1M beta_12M errors_1m ri Lagged_ri Lead_ri;
        class year;
        table Year, (dias size size_US BM volumen precio precio_US BA_spread beta_1m beta_12m errors_1m ri Lagged_ri Lead_Ri) * mean;
        where ticker = 'MX:HZB';
Run;
