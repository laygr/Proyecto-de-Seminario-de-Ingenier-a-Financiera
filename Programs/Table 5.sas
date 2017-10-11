%do_over(values=Size BM Lagged_Ri Beta_1M Beta_12M Errors_1m,
         phrase = %nrstr(%single_sort(general.Mensual, 3, 0, t5.ew_?)))


%do_over(values=Size BM Lagged_Ri Beta_1M Beta_12M Errors_1m,
         phrase = %nrstr(%single_sort(general.Mensual, 3, 1, t5.wv_?)))
