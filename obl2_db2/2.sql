CREATE or replace FUNCTION balance_cliente(id_cliente integer, fecha timestamp)
	RETURNS numeric AS $MONTOTOTAL$
	
#variable_conflict use_variable

declare pagosal numeric;
declare costos numeric;
declare montototal numeric;
declare unatraso numeric;
declare tripleatraso numeric;


	BEGIN

        SELECT sum(p."costoAlquiler") into costos
        FROM peliculas as p join pagos as pa on p."idPelicula"=pa."idPeliculaAlquilo"
        WHERE ("idClienteAlquilo"= id_cliente) and (pa."fechaAlquilo" < fecha);
        
        IF costos is null then
        	costos = 0;
        end if; 
        
        SELECT sum(monto) into pagosal
        FROM pagos as p
		WHERE (p."fecha" < fecha) and ("idClienteAlquilo"=id_cliente);
        
        IF pagosal is null then
        	pagosal = 0;
        end if;
                  
        SELECT SUM(DATE_PART('day', a."fechaDevolucion" - a."fecha") - pe."duracionAlquiler") into unatraso
        FROM alquileres as a join peliculas as pe on pe."idPelicula"=a."idPelicula"
        WHERE (a."fecha" < fecha) and a."idCliente"=id_cliente 
            and pe."duracionAlquiler" < (SELECT DATE_PART('day', a."fechaDevolucion" - a."fecha"))
            and (pe."duracionAlquiler"*3) >(SELECT DATE_PART('day', a."fechaDevolucion" - a."fecha"));
            
        IF unatraso is null then
        	unatraso = 0;
        end if;
        	
        SELECT sum(pe."costoReemplazo") into tripleatraso
        FROM alquileres as a join peliculas as pe on pe."idPelicula"=a."idPelicula"
        WHERE (a."fecha" < fecha) and a."idCliente"=id_cliente 
			and (pe."duracionAlquiler"*3) < (SELECT DATE_PART('day', a."fechaDevolucion" - a."fecha"));
  
        IF tripleatraso is null then
        	tripleatraso = 0;
        end if;
        
        montototal := costos - pagosal + unatraso*5 + tripleatraso;
        
        RETURN montototal;
		
	END;
	
	$MONTOTOTAL$
	Language 'plpgsql';