Data diarios;
    set datos.mex;
    year = year(DATE);
    month = month(DATE);
    size = p *nosh;
    size_US = p_US *nosh;
    BM = 1/(MTBV);
    Volumen = Vo;
    Precio = p;
    Precio_US = p_US;
    BA_Spread = PA - PB;
    rename
        Ret_1D = Ri;
    where
        INDM not in ("Banks", "Investment", "Investment Companies", "Investment Services")
        AND ret_1d IS NOT MISSING
        AND p IS NOT MISSING
        AND nosh IS NOT MISSING
        AND VO IS NOT MISSING
        AND MTBV <> 0
        AND Vo <> 0
        AND ret_1d <> 0
        AND ticker like 'MX%';
    Keep DATE YEAR MONTH TICKER NAME Ret_1d SIZE SIZE_US BM VOLUMEN PRECIO PRECIO_US BA_SPREAD;

run;

proc datasets library=work nolist;
  modify diarios;
  attrib _all_ label='';
quit;

%replace_missings_by_annual_avg(diarios, BM, diarios)

%winsorizing(diarios, SIZE BM PRECIO VOLUMEN BA_SPREAD, p5, p90, diariosprueba)


/* Cetes 28 */
/* Importar excel de cetes */

FILENAME REFFILE 'C:\Users\salamicros2-st.ITAM\Desktop\Proyecto Final\Input\IPC_Cetes.xlsx';

PROC IMPORT DATAFILE=REFFILE
    DBMS=XLSX
    OUT=Cetes28;
    GETNAMES=YES;
    SHEET="28";
RUN;
data cetes28;
        set cetes28;
        rename tasa_diaria = rf;
        keep year month tasa_diaria;
run;
%merge_by(diarios, cetes28, year month, diarios_cetes)

PROC IMPORT DATAFILE=REFFILE
    DBMS=XLSX
    OUT=IPC;
    GETNAMES=YES;
    SHEET="Rendimiento_IPC";
RUN;

data IPC;
        set IPC;
        rename
                rendimiento = rIPC
                Fecha = Date;
        keep Fecha rendimiento;
run;
%merge_by(diarios_cetes, IPC, Date, diarios_cetes_IPC)

data morgan_stanley_world;
    set datos.indice;
    where ticker = 'MSWRLD';
    rename ret_1d = rMSWRLD;
    keep date ret_1d;
Run;
%merge_by(diarios_cetes_IPC, morgan_stanley_world, date, diarios_cetes_IPC_msworld)

data pre.Diario;
        set diarios_cetes_IPC_msworld;
        Ri_m_rf = ri - rf;
        Ripc_m_rf = rIPC - rf;
run;
