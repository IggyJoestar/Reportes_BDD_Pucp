*ingreso
use "C:\Users\Iggy\Desktop\Primer informe\ENIGH\ingresos2022.dta", clear

*Hogares solo hay tarjeta acá
use "C:\Users\Iggy\Desktop\Primer informe\ENIGH\hogares2022.dta", clear

*Población
use "C:\Users\Iggy\Desktop\Primer informe\ENIGH\poblacion2022.dta", clear

* emparejar el módulo de ingreso y de características del hogar
use "C:\Users\Iggy\Desktop\Primer informe\ENIGH\ingresos2022.dta", clear
merge m:1 folioviv foliohog using "C:\Users\Iggy\Desktop\Primer informe\ENIGH\hogares2022.dta"

* Para crear norte=1 y sur=0 
destring entidad, replace

gen Estado = 0

replace Estado = 1 if inlist(entidad, 1, 2, 3, 5, 6, 8, 10, 14, 18, 19, 24, 25, 26, 28, 32)
replace Estado = 0 if inlist(entidad, 4, 7, 9, 11, 12, 13, 15, 16, 17, 20, 21, 22, 23, 27, 29, 30, 31)

* Para recodificar la variable de tendencia de tarjeta de modo que 2(no tiene)=0 y 1(si tiene), se mantenga
destring tarjeta, replace
recode tarjeta (2=0)

label define tarjeta_1 0 "No tiene" 1 "Sí tiene"
label values tarjeta tarjeta_1 

* Para recodificar la varible de negocio en el hogar de modo que 2(no tiene)=0 y 1 (si tiene)
destring negcua, replace
recode negcua (2=0)

label define negcua_1 0 "No tiene" 1 "Sí tiene"
label values negcua negcua_1 

* Hallamos los estadísticos descriptivos de los ingresos trimestrales de todos los estados
summarize ing_tri [aw=factor]


* Hallamos los estadisticos descriptivos de los ingresos trimestrales de los estados del norte
summarize ing_tri if Estado == 1 [aw=factor]


* Hallamos los estadísticos descriptivos de los ingresos trimestrales de los estado del sur
summarize ing_tri if Estado == 0 [aw=factor]


*Hallamos los estadísticos descriptivos de los ingresos trimestrales de los hogares que no tienen tarjeta=0
summarize ing_tri if tarjeta == 0 [aw=factor]


*Hallamos los estadísticos descriptivos de los ingresos trimestrales de los hogares que sí tienen tarjeta=1 
summarize ing_tri if tarjeta == 1 [aw=factor]



*Hallamos los estadísticos descriptivos de los hogares que no tienen negocio=0
summarize ing_tri if negcua == 0 [aw=factor]


*Hallamos los estadísticos descriptivos de los hogares que sí tienen negocio=1 
summarize ing_tri if negcua == 1 [aw=factor]


//kernel
kdensity ing_1, generate(x1 y1)
kdensity ing_2, generate(x2 y2)
kdensity ing_3, generate(x3 y3)
kdensity ing_4, generate(x4 y4)
kdensity ing_5, generate(x5 y5)
kdensity ing_6, generate(x6 y6)

twoway (line y1 x1, lcolor(blue)) ///
       (line y2 x2, lcolor(red)) ///
       (line y3 x3, lcolor(green)) ///
       (line y4 x4, lcolor(purple)) ///
       (line y5 x5, lcolor(orange)) ///
       (line y6 x6, lcolor(black)), ///
       legend(order(1 "Enero" 2 "Febrero" 3 "Marzo" 4 "Abril" 5 "Mayo" 6 "Junio")) ///
       title("Kernel de densidad de ingresos de cada uno de los 6 meses") ///
       xtitle("Ingresos") ///
       ytitle("Densidad")


//boxplot
graph box ing_tri if entidad == 15 | entidad == 19 | entidad == 7 | entidad == 20, ///
    title("Distribución del Ingreso Trimestral en Estados Más Ricos y Más Pobres") ///
    ytitle("Ingreso Trimestral")
	
//EJERCICIO 3

* Generar una variable aleatoria
set seed 1
gen variable_aleatoria = runiformint(1, 100)

* Crear una variable para el número de iteración (utilizando egen)
egen run = seq(), from(1) to(10000)

* Realizar el procedimiento 1,000 veces
forval x = 1/1000 {
    preserve
    gen var1 = runiform()
    sort var1
    keep if _n <= 10000  // Mantener las primeras 10,000 observaciones
    collapse (mean) ing_tri = ing_tri
    tempfile b`x'
    save `b`x''.dta, replace
    restore
}

* Limpiar y unir los archivos temporales
clear
forval x = 1/1000 {
    append using `b`x''.dta
}

* Limpiar los archivos temporales
forval x = 1/1000 {
    erase `b`x''.dta
}

* Cargar los datos generados
use "ingresos2022"
* Crear un gráfico de dispersión (scatter plot) de ing_tri vs. run
scatter ing_tri run, title("Gráfico de Dispersión de ing_tri vs. run") ///
xtitle("Número de Iteración") ytitle("Ingresos Trimestrales Promedio")
	


//OPCIONAL 2
* Creamos una matriz para almacenar los promedios de los ingresos
matrix A = J(20,1,.)

* Creamos una variable local "j" que nos ayude para llenar los promedios en la matriz, y hacemos un bucle con forvalues
local j = 1
forvalues i = 5(5)100 {
    preserve
    sample `i'

    * Calculamos el promedio
    sum ing_tri, meanonly

    * Almacenamos el promedio en la matrzi
    matrix A[`j',1] = r(mean)
    restore
    local ++j
}

* Mostramos los resultados
matrix list A


* Convertimos la matriz en un conjunto de datos
svmat A

* Creamos el box plot
graph box A1



