proc corr data=general.mensual outp=t2.table2 noprint;
	var num_empresas size size_US BM volumen precio precio_US BA_spread beta_1M beta_12M errors_1M;
run;

data t2.table2;
	set t2.table2;
	drop _TYPE_ _NAME_;
	where _TYPE_="CORR";
run;
