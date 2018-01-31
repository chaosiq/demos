CREATE SEQUENCE star_id_seq START 10000;

CREATE TABLE star
(
  id integer NOT NULL DEFAULT nextval('star_id_seq'::regclass),
  name character varying(120) NOT NULL,
  discovered_by character varying(120) NOT NULL,
  description character varying NOT NULL,
  link character varying NOT NULL,
  img_link character varying,
  CONSTRAINT star_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
GRANT all ON star TO frontend;
ALTER TABLE star
  OWNER TO frontend;

CREATE INDEX star_name_idx
  ON public.star
  USING btree
  (name COLLATE pg_catalog."default");

INSERT INTO star (name, discovered_by, description, link, img_link)
VALUES ('Antares', 'Unknown', 'Antares A is a red supergiant star with a stellar classification of M1.5Iab-Ib, and is indicated to be a spectral standard for that class.', 'https://en.wikipedia.org/wiki/Antares', 'https://upload.wikimedia.org/wikipedia/commons/1/15/Redgiants.svg');

INSERT INTO star (name, discovered_by, description, link, img_link)
VALUES ('KY Cygni', 'Unknown', 'KY Cygni is a red supergiant of spectral class M3.5Ia located in the constellation Cygnus. It is one of the largest stars known.', 'https://en.wikipedia.org/wiki/KY_Cygni', 'https://upload.wikimedia.org/wikipedia/commons/0/07/Sadr_Region_rgb.jpg');
