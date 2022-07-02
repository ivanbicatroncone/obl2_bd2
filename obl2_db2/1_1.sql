CREATE TABLE public.inconsist_tot_pel (
    id_alerta serial NOT NULL,
    id_pelicula int2 NOT NULL
);

CREATE
OR REPLACE FUNCTION tot_peliculas_trigger() RETURNS trigger AS $ tot_peliculas_trigger $ BEGIN
insert into
    inconsist_tot_pel (id_pelicula)
values
    (NEW."idPelicula");

return NEW;

END;

$ tot_peliculas_trigger $ LANGUAGE plpgsql;

CREATE TRIGGER tot_peliculas
AFTER
INSERT
    ON "peliculas" FOR EACH ROW EXECUTE PROCEDURE tot_peliculas_trigger();

CREATE
OR REPLACE FUNCTION tot_peliculas_borrar_trigger() RETURNS trigger AS $ tot_peliculas_borrar_trigger $ BEGIN
delete from
    inconsist_tot_pel
where
    id_pelicula = NEW."idPelicula";

return NEW;

END;

$ tot_peliculas_borrar_trigger $ LANGUAGE plpgsql;

CREATE TRIGGER tot_peliculas_borrar
AFTER
INSERT
    ON "idiomasDePeliculas" FOR EACH ROW EXECUTE PROCEDURE tot_peliculas_borrar_trigger();