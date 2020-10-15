function poblacion = generarUnaPoblacion(limiteInferior,limiteSuperior,numeroDeIndividuos)
        distanciaEntreCotas = limiteSuperior - limiteInferior;
        poblacion = rand( 1, numeroDeIndividuos) * distanciaEntreCotas + limiteInferior;
end

function poblaciones = generarPoblacionInicial ( cotas, numeroDeIndividuos )
       poblaciones = [];
        for i = 1:rows(cotas)
                poblaciones = [poblaciones; generarUnaPoblacion( cotas(i,1), cotas (i,2),numeroDeIndividuos)];
        end
end

%function seleccionado = seleccionarIndividuo(individuos, funcionDeDensidad)
        %numeroAleatorio = rand;
        %if (numeroAleatorio < funcionDeDensidad( 1 ))
                %seleccionado = individuos( :,1 );
        %else
                %numeroDeColumna = find(funcionDeDensidad>= numeroAleatorio)(1);
                %seleccionado =  individuos(:,numeroDeColumna);
        %endif
%end

function seleccionado = seleccionarIndividuo(individuos, funcionDeDensidad)
        numeroAleatorio = rand;
        numeroDeColumna = find(funcionDeDensidad>= numeroAleatorio)(1);
        seleccionado =  individuos(:,numeroDeColumna);
end

function aptitudes = calcularAptitudes ( funcionObjetivo, poblacion )
        aptitudes= [];
        for i = 1:columns(poblacion)
                columnaI = num2cell (poblacion(:,i));
                x = columnaI(1){:};
                y = columnaI(2){:};
                aptitudes = [aptitudes ; funcionObjetivo(x,y)];
        end
end

function resultado = seleccion(funcionObjetivo, poblacionAnterior)
        numeroDeIndividuos = columns(poblacionAnterior);
        aptitudesDeIndividuos = calcularAptitudes(funcionObjetivo, poblacionAnterior);
        sumaDeAptitudes = sum(aptitudesDeIndividuos);
        probabilidadParaRuletaDeIndividuos = arrayfun (@(x) (x)/sumaDeAptitudes , aptitudesDeIndividuos );
        funcionDeDensidad = arrayfun(@(x) sum(probabilidadParaRuletaDeIndividuos(1:x)), 1: numeroDeIndividuos );
        resultado = seleccionarIndividuo(poblacionAnterior, funcionDeDensidad);
end


function poblacion = seleccionarEnMasDeUnaVariable (funcionObjetivo, poblacionAnterior)
        cantidadDePoblaciones = rows(poblacionAnterior);
        poblacion = [];
        for i = 1: cantidadDePoblaciones
                poblacion = [poblacion; seleccion(funcionObjetivo,poblacionAnterior(i,:))];
        end
end


function salida = mutacionIndividual(genDeHijo, porcentajeDeMutacion, cotaInferior, cotaSuperior)
       if (rand <= porcentajeDeMutacion)
               genDeHijo = num2str(genDeHijo);
               variacionDeCotas = cotaSuperior - cotaInferior;
               mutacionDeGen = ceil(rand * variacionDeCotas) + cotaInferior;
               salida = num2str(mutacionDeGen);
               for i = 2:length(genDeHijo)
                       if(genDeHijo(i) != "." && rand <= porcentajeDeMutacion)
                               salida = strcat(salida, num2str(ceil(rand * 9)));
                       else
                               salida = strcat(salida, genDeHijo(i));
                       end
               end
               salida = str2num(salida);
       else
               salida = genDeHijo;
       end
end



function individuoMutado = mutacion(individuo, porcentajeDeMutacion, cotas)
       individuoMutado = [];
        for i = 1: rows(individuo)
                cotaInferior = cotas(i,1);
                cotaSuperior = cotas(i,2);
                individuoMutado = [individuoMutado; mutacionIndividual(individuo(i,1), porcentajeDeMutacion, cotaInferior, cotaSuperior)];
        end
end



function ganadores = torneo (hijo1, hijo2,  padre1, padre2, funcionObjetivo)
               competidores =[ hijo1 hijo2 padre1 padre2 ];
               aptitudes = rot90(calcularAptitudes(funcionObjetivo , competidores) );
               [maximo indiceDeGanador1 ] = max(aptitudes);
               ganador1 = competidores(:,indiceDeGanador1);
               aptitudes(indiceDeGanador1) = -inf;
               [maximo indiceDeGanador2 ] = max(aptitudes);
               ganador2 = competidores(:,indiceDeGanador2);
               ganadores = [ganador1 ganador2];
end

function nuevos = reproduccion(padre1, padre2, porcentajeDeReproduccion, porcentajeDeMutacion, cotas, funcionObjetivo)
        if(rand <= porcentajeDeReproduccion)
                filasDePadres = rows(padre1);
                puntoDeCorte = ceil(rand *  filasDePadres);
                hijo2 = [padre2(1:puntoDeCorte,1) ;padre1(puntoDeCorte + 1:filasDePadres,1)]; %,1 es para pasar de columna a fila
                hijo1 = [padre1(1:puntoDeCorte,1) ;padre2(puntoDeCorte + 1:filasDePadres,1)];
                hijo1 = mutacion(hijo1,porcentajeDeMutacion, cotas);
                hijo2 = mutacion(hijo2,porcentajeDeMutacion, cotas);
                nuevos = torneo(hijo1, hijo2, padre1, padre2, funcionObjetivo);
        else
                padre1Mutado = mutacion(padre1,porcentajeDeMutacion, cotas);
                padre2Mutado = mutacion(padre2,porcentajeDeMutacion, cotas);
                nuevos = [ padre1Mutado  padre2Mutado ];
        endif
end

function graficar(funcionObjetivo, entradas)
        if(rows(entradas) == 2)
                x = entradas(1,:);
                y = entradas(2,:);
                numeroDeIndividuos = columns(entradas);
                resultado = arrayfun (@(x) funcionObjetivo (entradas(1,x), entradas(2,x)), 1: numeroDeIndividuos);
                scatter3(x,y,resultado);
        else
                display('Numero de variables incorrecto');
        endif
end

function nuevaPoblacion = generarNuevaPoblacion(poblacionAntigua, numeroDeIndividuos, funcionObjetivo, cotas, porcentajeDeReproduccion, porcentajeDeMutacion)
        nuevaPoblacion = [];
        aptitudesDeLaPoblacionAntigua = calcularAptitudes(funcionObjetivo, poblacionAntigua);
        [max indiceDelMasAptoDeLaPoblacionAntigua] = max(aptitudesDeLaPoblacionAntigua);
        individuoMasAptoDeLaPoblacionAntigua = poblacionAntigua(indiceDelMasAptoDeLaPoblacionAntigua);
        for i= 1:(numeroDeIndividuos/2)
                padre1 = seleccion(funcionObjetivo, poblacionAntigua);
                padre2 = seleccion(funcionObjetivo, poblacionAntigua);
                nuevaPoblacion = [nuevaPoblacion reproduccion(
                  padre1,padre2,porcentajeDeReproduccion,porcentajeDeMutacion, cotas, funcionObjetivo
                  )];
        endfor
        aptitudesDeLaPoblacionNueva = calcularAptitudes(funcionObjetivo, nuevaPoblacion);
        [min indiceDelMenosAptoDeLaPoblacionNueva] = min(aptitudesDeLaPoblacionNueva);
        nuevaPoblacion(indiceDelMenosAptoDeLaPoblacionNueva) = individuoMasAptoDeLaPoblacionAntigua;
end

function generarPoblacionFinal(cantidadDePoblaciones, numeroDeIndividuos, cotas, funcionObjetivo, poblacionesIntermediasAGraficar, porcentajeDeReproduccion, porcentajeDeMutacion)
        poblacionAntigua = generarPoblacionInicial(cotas,numeroDeIndividuos);
        for i= 1: cantidadDePoblaciones
                display('Generando poblacion numero: ')
                display(i)
                nuevaPoblacion = generarNuevaPoblacion(poblacionAntigua, numeroDeIndividuos, funcionObjetivo, cotas, porcentajeDeReproduccion, porcentajeDeMutacion);
                if(length(poblacionesIntermediasAGraficar) > 0 && poblacionesIntermediasAGraficar(1) == i)
                        graficar(funcionObjetivo, nuevaPoblacion)
                        poblacionesIntermediasAGraficar = poblacionesIntermediasAGraficar(2:end);
                        display('Pulse cualquier tecla para cerrar la grafica y continuar la ejecución')
                        pause()
                        close()
                endif
                poblacionAntigua = nuevaPoblacion;
        endfor
        graficar(funcionObjetivo, nuevaPoblacion)
        display('Pulse cualquier tecla para cerrar la grafica y terminar la ejecución')
        pause()
        close()
end

numeroDeGeneraciones = 6
numeroDeIndividuos = 400;
cotas = [1,5;3,4];
funcionObjetivo = @(x,y) x+y
poblacionesIntermediasAGraficar = [2,4]
porcentajeDeReproduccion = 0.4
porcentajeDeMutacion = 0.03
generarPoblacionFinal(
                      numeroDeGeneraciones,
                      numeroDeIndividuos,
                      cotas,
                      funcionObjetivo,
                      poblacionesIntermediasAGraficar,
                      porcentajeDeReproduccion,
                      porcentajeDeMutacion
                      )
