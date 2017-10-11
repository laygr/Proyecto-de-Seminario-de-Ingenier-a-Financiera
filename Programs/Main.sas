%macro Main;
	%let should_clean = 0;
	%let run_all = 0;
	
	%let load_macros        = 1;
	%let run_Preprocessing  = 0;
	%let run_General        = 0;
	
	%let run_Table0         = 0;
	%let run_Table1         = 0;
	%let run_Table2         = 0;
	%let run_Table3         = 0;
	%let run_Table4         = 0;
	%let run_Table5         = 0;
	%let run_Table6         = 0;
	%let run_Table7         = 0;
	%let run_Table8         = 0;
	%let run_Appendix       = 0;
	
	/*
    La variable Path se debe de adaptar al entorno en que se ejecute el proyecto.
    Según sea unix o windows, igual se deberá de cambiar los "/" por "\"
      en todas las direcciones de este archivo únicamente.
  */
	%let Path = /folders/myfolders/proyecto Final;

  /*
  Para correrlo en las computadoras del itam:
  %let Path = C:/Users/salamicros2-st.ITAM/Desktop/Proyecto Final;
  */
	
	libname input   "&Path/Input";
	libname pre     "&Path/Preprocessing";
	libname general "&Path/General";
	
	libname t0 "&Path/Tables/Table 0";
	libname t1 "&Path/Tables/Table 1";
	libname t2 "&Path/Tables/Table 2";
	libname t3 "&Path/Tables/Table 3";
	libname t4 "&Path/Tables/Table 4";
	libname t5 "&Path/Tables/Table 5";
	libname t6 "&Path/Tables/Table 6";
	libname t7 "&Path/Tables/Table 7";
	libname t8 "&Path/Tables/Table 8";
	libname ap "&Path/Tables/Appendix";
	
	%IF &should_clean %THEN %DO;
	  proc datasets library=pre kill;
	  proc datasets library=general kill;
	  proc datasets library=t0 kill;
	  proc datasets library=t1 kill;
	  proc datasets library=t2 kill;
	  proc datasets library=t3 kill;
	  proc datasets library=t4 kill;
	  proc datasets library=t5 kill;
	  proc datasets library=t6 kill;
	  proc datasets library=t7 kill;
	  proc datasets library=t8 kill;
	  proc datasets library=work kill;
	  run;
	%END;
	
	%let Programs = &Path/Programs;
	
	%IF &load_macros OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Macros/Do Over.sas";
	  %INCLUDE "&Programs/Macros/Utilities.sas";
	  %INCLUDE "&Programs/Macros/Betas.sas";
	  %INCLUDE "&Programs/Macros/Portfolios.sas";
	  %INCLUDE "&Programs/Macros/Fama MacBeth.sas";
	%end;
	
	%IF &run_Preprocessing OR &run_all %THEN %DO;
  	%INCLUDE "&Programs/Preprocessing.sas";
	%END;
	
	%IF &run_General OR &run_all %THEN %do;
		%INCLUDE "&Programs/General.sas";
	%end;
	
	%IF &run_Table0 OR &run_all %THEN %do;
		%INCLUDE "&Programs/Table 0.sas";
	%end;
	%IF &run_Table1 OR &run_all %THEN %do;
		%INCLUDE "&Programs/Table 1.sas";
	%end;
	%IF &run_Table2 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 2.sas";
	%end;
	%IF &run_Table3 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 3.sas";
	%end;
	%IF &run_Table4 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 4.sas";
	%end;
	%IF &run_Table5 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 5.sas";
	%end;
	%IF &run_Table6 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 6.sas";
	%end;
	%IF &run_Table7 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 7.sas";
	%end;
	%IF &run_Table8 OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Table 8.sas";
	%end;
	%IF &run_Appendix OR &run_all %THEN %do;
	  %INCLUDE "&Programs/Appendix.sas";
	%end;
%MEND;

%Main