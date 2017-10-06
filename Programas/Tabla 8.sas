

data trucada;
        set trucada;
        where year = 1990 and month < 7;
run;

%fama_macbeth(general.Mensual, Lead_Ri_m_Rf, BM Size, bm_size)
%fama_macbeth(trucada, Lead_Ri_m_Rf, Size, size)

proc sort data = Data6;
        by cookd;
run;


%single_sort(trucada, size, 3, 0, ew_size)

%fama_macbeth(general.Mensual,
        Lead_Ri_m_Rf, SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M PRECIO VOLUMEN BA_SPREAD, all)


%sort_by(general.mensual, year month ticker)

proc princomp
        data = general.mensual
        output = pc
        standard
        plots=patternprofile
        ;

        var SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M
                precio volumen BA_spread;
run;


%fama_macbeth(pc, Lead_Ri_m_Rf, prin1, pc_1)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2, pc_2)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3, pc_3)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4, pc_4)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5, pc_5)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5 prin6, pc_6)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5 prin6 prin7, pc_7)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8, pc_8)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9, pc_9)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9, pc_all)

%do_over(values=prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9,
         phrase= %nrstr(%fama_macbeth(pc, Lead_Ri_m_Rf, ?, ?))
)

%fama_macbeth(pc, Lead_Ri_m_Rf, prin1, prin1)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin2, prin2)
%fama_macbeth(pc, Lead_Ri_m_Rf, prin1 prin2, one_two)
