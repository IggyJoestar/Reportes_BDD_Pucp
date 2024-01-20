set more off
clear
global dir "C:\Users\Iggy\Desktop"

global datadir "C:\Users\Iggy\Desktop\REPORTE_3\MODULO200-300"

foreach x of numlist 2013/2022{
    use "$datadir\enaho01-`x'-200", clear

    merge 1:1 conglome vivienda hogar codperso using "$datadir\enaho01-`x'-200", keep(3) nogen

    merge 1:1 conglome vivienda hogar codperso using "$datadir\enaho01a-`x'-300", keep(3) nogen

    gen year = `x'
    destring(codtarea codtiempo), replace
    tempfile b`x'
    save `b`x''
}


use `b2013'


append using `b2014', force
append using `b2015', force
append using `b2016', force
append using `b2017', force
append using `b2018', force
append using `b2019', force
append using `b2020', force
append using `b2021', force
append using `b2022', force

*Identifique a los jefes de hogar que tienen educación superior universitaria o no universitaria completa

gen jefedusup = .
replace jefedusup = 1 if p203b == 1 & (p301a == 8 | p301a == 10)
replace jefedusup = 0 if p203b == 1 & (p301a != 8 & p301a != 10)
*Clasifique a todos los hogares de acuerdo a esto, =1 para todos los miembros si el jefe/a de hogar tiene educación superior completa y = 0 en caso contrario 

egen grupo = group(conglome vivienda hogar)

gen filtro_hogar = (p203a == 1 & jefedusup == 1)
egen hedusup = max(filtro_hogar), by(grupo)
drop filtro_hogar

* Construya el indicador de años de educación para todos los miembros
gen study_years = p301b

replace study_years= 0 if p301a == 1 | p301a == 2 // Sin nivel o Inicial

recode  study_years (1=1) (2=2) (3=3) (4=4)               if p301a==3 // Primaria incompleta
recode  study_years (5=5) (6=6)                           if p301a==4 // Primaria completa
recode  study_years (1=7) (2=8) (3=9) (4=10)              if p301a==5 // Sec. incompleta
recode  study_years (4=11) (5=11)(6=12)                   if p301a==6 // Sec. completa
recode  study_years (1=12)(2=13)(3=14)(4=15)              if p301a==7 // Sup. No Uni. incompleta
recode  study_years (3=14)(4=15)(5=16)                    if p301a==8 // Sup. No Uni. completa
recode  study_years (1=12)(2=13)(3=14)(4=15)(5=16) (6=17) if p301a==9 // Sup. Uni incompleta
recode  study_years (4=15)(5=16)(6=17)(7=18)              if p301a==10 // Sup. Uni completa
recode  study_years (1=17)(2=18)                          if p301a==11 // Posgrado

* Obtenga el promedio de años de educación para mayores de 25 años para cada grupo

	* Para los hogares con jefes de hogar con educación superior completa:

	mean(study_years) if p208a > 25 & jefedusup == 1
	
	*Para los hogares con jefes de hogar que cuentan con jefe de hogar sin educación superior completa:
		
	mean(study_years) if p208a > 25 & jefedusup == 0
	
* Gráfico:
	label define jefedusup_labels 0 "Edu. Sup. No Completa" 1 "Edu. Sup. Completa"

	label values jefedusup jefedusup_labels

	* Crea el gráfico de barras con espacio adicional entre el eje y y el gráfico
	graph bar (mean) study_years, over(jefedusup) ///
    ylabel(0(1)18, labsize(*0.8) grid) ///
	title("Promedio de Años de Educación según nivel de educación del Jefe de Hogar", size(*0.5)) ///
    ytitle("Promedio de Años de Educación", size(*1.0) margin(medium)) ///
    legend(off)

clear
*___________________________________________________________________________________________



use "C:\Users\Iggy\Desktop\REPORTE_3\enaho01a-2004-300",
append using "C:\Users\Iggy\Desktop\REPORTE_3\enaho01a-2022-300", force
*NOTA IMPORTANTE: Tuvimos que cambiar el nombre el la variable año por year en la ventana de comandos (no se pudo hacer esto en la ventano de código) con "rename"
*o si estás en stata 17 o 18 ejecutar
rename a?o year
*primera pregunta:
*Variables geográficas (departamento, urbano/rural)
*Departamento (distinguir Lima Metropolitana de Lima Provincias)
destring ubigeo, generate(dpto) 
replace dpto=dpto/10000
replace dpto=round(dpto)
label define dpto_num 1  "Amazonas"
label define dpto_num 2  "Ancash",       add
label define dpto_num 3  "Apurimac",     add
label define dpto_num 4  "Arequipa",     add
label define dpto_num 5  "Ayacucho",     add
label define dpto_num 6  "Cajamarca",    add
label define dpto_num 7  "Callao",       add
label define dpto_num 8  "Cusco",        add
label define dpto_num 9  "Huancavelica", add
label define dpto_num 10 "Huanuco",      add
label define dpto_num 11 "Ica",          add
label define dpto_num 12 "Junin",        add
label define dpto_num 13 "La_Libertad",  add
label define dpto_num 14 "Lambayeque",   add
label define dpto_num 15 "Lima_Metropolitana",   add
label define dpto_num 16 "Lima_Provincias",      add
label define dpto_num 17 "Loreto",       add
label define dpto_num 18 "Madre_de_Dios",add
label define dpto_num 19 "Moquegua",     add
label define dpto_num 20 "Pasco",        add
label define dpto_num 21 "Piura",        add
label define dpto_num 22 "Puno",         add
label define dpto_num 23 "San_Martin",   add
label define dpto_num 24 "Tacna",        add
label define dpto_num 25 "Tumbes",       add
label define dpto_num 26 "Ucayali",      add
label values dpto dpto_num

gen study_years = p301b

replace study_years= 0 if p301a == 1 | p301a == 2 // Sin nivel o Inicial

recode  study_years (1=1) (2=2) (3=3) (4=4)               if p301a==3 // Primaria incompleta
recode  study_years (5=5) (6=6)                           if p301a==4 // Primaria completa
recode  study_years (1=7) (2=8) (3=9) (4=10)              if p301a==5 // Sec. incompleta
recode  study_years (4=11) (5=11)(6=12)                   if p301a==6 // Sec. completa
recode  study_years (1=12)(2=13)(3=14)(4=15)              if p301a==7 // Sup. No Uni. incompleta
recode  study_years (3=14)(4=15)(5=16)                    if p301a==8 // Sup. No Uni. completa
recode  study_years (1=12)(2=13)(3=14)(4=15)(5=16) (6=17) if p301a==9 // Sup. Uni incompleta
recode  study_years (4=15)(5=16)(6=17)(7=18)              if p301a==10 // Sup. Uni completa
recode  study_years (1=17)(2=18)                          if p301a==11 // Posgrado

sort dpto year
by dpto: egen educacion_promedio_2004 = mean(study_years) if year == "2004"
by dpto: egen educacion_promedio_2022 = mean(study_years) if year == "2022"

tab dpto, summarize(educacion_promedio_2022)
tab dpto, summarize(educacion_promedio_2004)
keep year study_years educacion_promedio_2022 educacion_promedio_2004 dpto

*reemplazando los proemdios con los de 2022

replace educacion_promedio_2022= 5.0375032 if dpto==1
replace educacion_promedio_2022= 6.4776387  if dpto==2
replace educacion_promedio_2022= 6.0401993 if dpto==3
replace educacion_promedio_2022= 8.4842587 if dpto==4
replace educacion_promedio_2022= 5.7312217 if dpto==5
replace educacion_promedio_2022= 5.052382 if dpto==6
replace educacion_promedio_2022= 8.6766834 if dpto==7
replace educacion_promedio_2022= 6.4639339 if dpto==8
replace educacion_promedio_2022= 5.603189 if dpto==9
replace educacion_promedio_2022= 5.4455194 if dpto==10
replace educacion_promedio_2022= 8.5550413 if dpto==11
replace educacion_promedio_2022= 7.2527719 if dpto==12
replace educacion_promedio_2022= 6.7994595 if dpto==13
replace educacion_promedio_2022= 7.3991504 if dpto==14
replace educacion_promedio_2022= 8.884676 if dpto==15
replace educacion_promedio_2022= 5.681458 if dpto==16
replace educacion_promedio_2022= 7.0435243 if dpto==17
replace educacion_promedio_2022= 5.681458 if dpto==18
replace educacion_promedio_2022= 7.0435243 if dpto==19
replace educacion_promedio_2022= 8.73316 if dpto==20
replace educacion_promedio_2022= 6.5734768 if dpto==21
replace educacion_promedio_2022= 6.5453753 if dpto==22
replace educacion_promedio_2022= 6.5702143 if dpto==23
replace educacion_promedio_2022= 5.6390085 if dpto==23
replace educacion_promedio_2022= 8.5765438 if dpto==24
replace educacion_promedio_2022= 7.4356332 if dpto==25
replace educacion_promedio_2022= 6.2194219  if dpto==26


drop if year=="2022"
gen diferencia = educacion_promedio_2022 - educacion_promedio_2004


scatter educacion_promedio_2022 diferencia, mcolor(red) msize(*0.5) mlabsize(*0.4) ///
mlabel(dpto) mlabcolor(blue)  ///
xtitle("Diferencia del promedio de años de estudio")

clear
*___________________________________________________________________________________________

set more off

global dir_enaho "C:\Users\Iggy\Desktop\REPORTE_3"

foreach x of numlist 2013/2022{
	use "$dir_enaho/MODULO500/enaho01a-`x'-500", clear

//Estime los ingresos laborales dependientes e independientes

*En primer lugar creamos las variables para ingresos laborales dependientes (inglabde) y para ingresos laborales independientes (inglabinde).
	egen inglabde= rowtotal(i524a1 d529t i538a1 d540t i541a  d544t) 
	label var inglabde "Ingreso laboral dependiente" 
	egen inglabinde= rowtotal(i530a d536 d543)
	label var inglabinde "Ingreso laboral independiente" 

*Elimino a todos los mising value en mi muestra de modo que no obtenga 0, es decir, no ocupados laboralmente.

	replace inglabde= . if i524a1== . & d529t== . & i538a1== . & d540t== . & i541a== . & d544t== . 
	replace inglabinde= . if i530a== . & d536== . & d543== . 
	
//Obtener un ratio de ambos montos

*genero una variable que nos de el ratio entre ambos
	gen rating = inglabde / inglabinde //cuando me piden ratio me piden esto?
	label var rating "Ratio de ingresos" 
	
//Obtener el promedio para cada región

*Primero debo estrablecer mis regiones. Para ello uso mi variable dominio y lo agrupo para recodificar la variable de modo que sea posible tener solo mis tres regiones naturales: costa, sierra y selva.
	recode dominio (1 2 3 8 = 1 "Costa") (4 5 6 = 2 "Sierra") (7 = 3 "Selva"), gen(regnat) 
	label var regnat "Region Natural" 

* Promedio de ingresos laborales para trabajadores dependientes e independientes por región
		preserve
		collapse (mean) promde = inglabde prominde=inglabinde [iw=fac500a], by(regnat)  //esta bien aca usar iw o no?
		gen year = `x'
		tempfile base`x'
		save `base`x''	
		restore
* Nacional
		preserve
		collapse (mean) promde = inglabde prominde=inglabinde [iw=fac500a]  
		gen regnat = 4 
		gen year = `x' 
		tempfile base`x'n 
		save `base`x'n'	
		restore
}

clear
foreach x of numlist 2013/2022{
	append using `base`x''
	append using `base`x'n'
	
}
* Con todo lo anterior ya tengo los promedios por región y también a nivel nacional.

//Gernerar un grafico con las caracteristicas correspondientes a la tarea.
reshape wide promde prominde, i(year) j(regnat) // lo convierto a wide para poder hacer line
line promde1 prominde1 promde2 prominde2 promde3 prominde3 promde4 prominde4 year, xlabel(2013(1)2022, labsize(*0.8) grid) ///
xtitle("year") ytitle("Mean") /// 
legend(order(1 "Costa dependiente" 2 "Costa independiente" 3 "Selva dependiente" 4 "Selva independiente" 5 "Sierra dependiente" 6 "Selva independiente" 7 "Nacional dependiente" 8 "Nacional independiente")) ///
lcolor(red red green green gray gray blue blue) 


*___________________________________________________________________________________________

*brecha salarial
set more off

foreach x of numlist 2020/2022{
    use "C:\Users\Iggy\Desktop\REPORTE_3\MODULO200-300\enaho01-`x'-200", clear

    merge 1:1 conglome vivienda hogar codperso using "$datadir\enaho01-`x'-200", keep(3) nogen

    merge 1:1 conglome vivienda hogar codperso using "$datadir\enaho01a-`x'-500", keep(3) nogen

    gen year = `x'
    destring(codtarea codtiempo), replace
    tempfile b`x'
    save `b`x''
}


use `b2020'

append using `b2021', force
append using `b2022', force
*Hombre
bysort year: egen sueldo_h = mean(p524a1) if p207 == 1
*Mujer
bysort year: egen sueldo_m = mean(p524a1) if p207 == 2
* Diferencia