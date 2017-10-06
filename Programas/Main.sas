%macro Main;
        %let should_clean = 0;
        %let run_all = 0;

        %let load_macros        = 1;
        %let run_Preprocessing  = 0;
        %let run_General        = 0;

        %let run_Tabla0         = 0;
        %let run_Tabla1         = 0;
        %let run_Tabla2         = 0;
        %let run_Tabla3         = 0;
        %let run_Tabla4         = 0;
        %let run_Tabla5         = 0;
        %let run_Tabla6         = 0;
        %let run_Tabla7         = 0;
        %let run_Tabla8         = 0;

        %let Path = C:\Users\salamicros2-st.ITAM\Desktop\Proyecto Final;

        /*  \folders\myfolders\proyecto Final; */



        libname datos   "&Path\Input";
        libname pre     "&Path\Preproceso";
        libname general "&Path\General";

        libname t0 "&Path\Tablas\Tabla 0";
        libname t1 "&Path\Tablas\Tabla 1";
        libname t2 "&Path\Tablas\Tabla 2";
        libname t3 "&Path\Tablas\Tabla 3";
        libname t4 "&Path\Tablas\Tabla 4";
        libname t5 "&Path\Tablas\Tabla 5";
        libname t6 "&Path\Tablas\Tabla 6";
        libname t7 "&Path\Tablas\Tabla 7";
        libname t8 "&Path\Tablas\Tabla 8";
        libname ap "&Path\Tablas\Apendice";

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

        %let Programs = &Path\Programas;

        %IF &load_macros OR &run_all %THEN %do;
                %INCLUDE "&Programs\Macros\Do Over.sas";
                %INCLUDE "&Programs\Macros\Utilidades.sas";
                %INCLUDE "&Programs\Macros\Betas.sas";
                %INCLUDE "&Programs\Macros\Portafolios.sas";
                %INCLUDE "&Programs\Macros\Fama MacBeth.sas";
        %end;

        %IF &run_Preprocessing OR &run_all %THEN %DO;
                %INCLUDE "&Programs\Preproceso.sas";
        %END;

        %IF &run_General OR &run_all %THEN %do;
                %INCLUDE "&Programs\General.sas";
        %end;

        %IF &run_Tabla0 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 0.sas";
        %end;
        %IF &run_Tabla1 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 1.sas";
        %end;
        %IF &run_Tabla2 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 2.sas";
        %end;
        %IF &run_Tabla3 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 3.sas";
        %end;
        %IF &run_Tabla4 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 4.sas";
        %end;
        %IF &run_Tabla5 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 5.sas";
        %end;
        %IF &run_Tabla6 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 6.sas";
        %end;
        %IF &run_Tabla7 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 7.sas";
        %end;
        %IF &run_Tabla8 OR &run_all %THEN %do;
                %INCLUDE "&Programs\Tabla 8.sas";
        %end;
%MEND;
%Main
