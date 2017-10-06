%triple_sort_independent(general.mensual, Size, BM, Lagged_Ri, 3, p_size_bm_laggedR);
%triple_sort_independent(general.mensual, Size, BM, Beta_1M, 3, p_size_BM_beta1M);
%triple_sort_independent(general.mensual, Size, BM, Beta_12M, 3, p_size_BM_beta12M);
%triple_sort_independent(general.mensual, Size, BM, Errors_1M, 3, p_size_BM_Errors_1M);


%fama_macbeth(general.Mensual, Lead_Ri_m_Rf, BM Size, bm_size)
%fama_macbeth(general.Mensual,
        Lead_Ri_m_Rf, SIZE BM LAGGED_RI BETA_1M BETA_12M ERRORS_1M PRECIO VOLUMEN BA_SPREAD, all)

/* PCA */
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

%do_over(values=prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9,
         phrase = %nrstr(%single_sort(pc, ?, 3, 0, pc_ew_?)))
      
%double_sort_independent(pc, prin1, prin2, 3, p_p1_p2)
%double_sort_independent(pc, prin1, prin3, 3, p_p1_p3)

%triple_sort_independent(pc, prin1, prin2, prin3, 3, p_p1_p2_p3_);
       


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
