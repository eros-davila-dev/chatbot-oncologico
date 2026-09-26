* Encoding: UTF-8.
* =====================================================================.
* Sistema web con chatbot para la gestión de pacientes en una fundación
* oncológica privada de Lima, 2026.
* Análisis pretest-postest sobre 13 pares de sesiones (IBM SPSS 29).
*
* ANTES DE EJECUTAR:
* 1. Complete los datos reales en Instrumento_v6_PRE_POST.xlsx y verifique
*    que la hoja Control_Calidad no tenga alertas sin resolver.
* 2. Guarde y cierre el Excel.
* 3. Cambie la ruta de la línea /FILE por la ubicación real del archivo.
* 4. Ejecute todo (Ejecutar > Todo).
* =====================================================================.

GET DATA
  /TYPE=XLSX
  /FILE='C:\Tesis\Instrumento_v6_PRE_POST.xlsx'
  /SHEET=name 'SPSS_Pares'
  /CELLRANGE=RANGE 'A1:J14'
  /READNAMES=ON
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.

* Las celdas vacías (pares no válidos) pueden importarse como texto.
* Se convierten a numérico: los vacíos quedan como perdidos del sistema.
ALTER TYPE par mismo_dia tpr_pre tpr_post ta_pre ta_post nca_pre nca_post (F8.2).

VARIABLE LABELS
  par 'Par de sesiones'
  fecha_pre 'Fecha de la sesión pretest'
  fecha_post 'Fecha de la sesión postest'
  mismo_dia 'Par con el mismo día de la semana'
  tpr_pre 'Tiempo promedio de registro - pretest (min)'
  tpr_post 'Tiempo promedio de registro - postest (min)'
  ta_pre 'Tasa de ausentismo - pretest (%)'
  ta_post 'Tasa de ausentismo - postest (%)'
  nca_pre 'Nivel de consultas atendidas - pretest (%)'
  nca_post 'Nivel de consultas atendidas - postest (%)'.
VALUE LABELS mismo_dia 1 'Sí' 0 'No'.

* Diferencias postest - pretest (base de la prueba de normalidad).
COMPUTE dif_tpr = tpr_post - tpr_pre.
COMPUTE dif_ta = ta_post - ta_pre.
COMPUTE dif_nca = nca_post - nca_pre.
VARIABLE LABELS dif_tpr 'Diferencia TPR (post - pre)'
  dif_ta 'Diferencia TA (post - pre)'
  dif_nca 'Diferencia NCA (post - pre)'.
EXECUTE.

SAVE OUTFILE='C:\Tesis\Pares_PRE_POST.sav'.

* ---------------------------------------------------------------------.
* 1. ESTADÍSTICA DESCRIPTIVA (Tablas de estadísticos descriptivos).
* ---------------------------------------------------------------------.
DESCRIPTIVES VARIABLES=tpr_pre tpr_post ta_pre ta_post nca_pre nca_post
  /STATISTICS=MEAN STDDEV MIN MAX.
FREQUENCIES VARIABLES=tpr_pre tpr_post ta_pre ta_post nca_pre nca_post
  /FORMAT=NOTABLE
  /STATISTICS=MEDIAN.

* ---------------------------------------------------------------------.
* 2. NORMALIDAD DE LAS DIFERENCIAS (Shapiro-Wilk).
*    Si p >= 0,05: usar t de Student para muestras relacionadas.
*    Si p <  0,05: usar Wilcoxon.
* ---------------------------------------------------------------------.
EXAMINE VARIABLES=dif_tpr dif_ta dif_nca
  /PLOT NPPLOT
  /STATISTICS DESCRIPTIVES
  /MISSING PAIRWISE.

* ---------------------------------------------------------------------.
* 3. CONTRASTE DE HIPÓTESIS (se ejecutan ambas pruebas; en el informe se
*    reporta la que corresponda según el paso 2).
*    Hipótesis direccionales: TPR post < pre; TA post < pre; NCA post > pre.
*    SPSS 29 muestra la p unilateral en la prueba t ("p de un factor").
*    Para Wilcoxon, la p unilateral es la bilateral / 2, solo si la
*    diferencia va en la dirección esperada.
* ---------------------------------------------------------------------.
T-TEST PAIRS=tpr_pre ta_pre nca_pre WITH tpr_post ta_post nca_post (PAIRED)
  /ES DISPLAY(TRUE) STANDARDIZER(SD)
  /CRITERIA=CI(.95)
  /MISSING=ANALYSIS.

NPAR TESTS
  /WILCOXON=tpr_pre ta_pre nca_pre WITH tpr_post ta_post nca_post (PAIRED)
  /STATISTICS DESCRIPTIVES
  /MISSING ANALYSIS.

* Tamaño del efecto para Wilcoxon: r = |Z| / raíz(n de pares válidos).
* Calcúlelo con el Z de la tabla "Estadísticos de prueba".

* ---------------------------------------------------------------------.
* 4. ANÁLISIS DE SENSIBILIDAD: solo pares con el mismo día de la semana
*    (excluye el par 13: lunes 31/08 - miércoles 30/09).
* ---------------------------------------------------------------------.
TEMPORARY.
SELECT IF (mismo_dia = 1).
T-TEST PAIRS=tpr_pre ta_pre nca_pre WITH tpr_post ta_post nca_post (PAIRED)
  /ES DISPLAY(TRUE) STANDARDIZER(SD)
  /CRITERIA=CI(.95)
  /MISSING=ANALYSIS.

TEMPORARY.
SELECT IF (mismo_dia = 1).
NPAR TESTS
  /WILCOXON=tpr_pre ta_pre nca_pre WITH tpr_post ta_post nca_post (PAIRED)
  /MISSING ANALYSIS.

* Fin de la sintaxis. Exporte el visor de resultados (Archivo > Exportar)
* y envíelo para redactar el capítulo de Resultados.
