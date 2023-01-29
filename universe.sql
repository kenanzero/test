--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-2.pgdg20.04+1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-2.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE universe;
--
-- Name: universe; Type: DATABASE; Schema: -; Owner: freecodecamp
--

CREATE DATABASE universe WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';


ALTER DATABASE universe OWNER TO freecodecamp;

\connect universe

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: galaxy; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.galaxy (
    galaxy_id integer NOT NULL,
    name character varying(80) NOT NULL,
    is_spherical boolean,
    has_life boolean,
    distance_from_earth integer,
    age_in_millions_of_years integer,
    description text,
    planet_type numeric
);


ALTER TABLE public.galaxy OWNER TO freecodecamp;

--
-- Name: galaxy_id_galaxy_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.galaxy_id_galaxy_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.galaxy_id_galaxy_seq OWNER TO freecodecamp;

--
-- Name: galaxy_id_galaxy_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.galaxy_id_galaxy_seq OWNED BY public.galaxy.galaxy_id;


--
-- Name: moon; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.moon (
    moon_id integer NOT NULL,
    name character varying(80) NOT NULL,
    is_spherical boolean,
    has_life boolean,
    distance_from_earth integer,
    age_in_millions_of_years integer,
    description text,
    planet_type numeric,
    planet_id integer
);


ALTER TABLE public.moon OWNER TO freecodecamp;

--
-- Name: moon_moon_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.moon_moon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.moon_moon_id_seq OWNER TO freecodecamp;

--
-- Name: moon_moon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.moon_moon_id_seq OWNED BY public.moon.moon_id;


--
-- Name: planet; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.planet (
    planet_id integer NOT NULL,
    name character varying(80) NOT NULL,
    is_spherical boolean,
    has_life boolean,
    distance_from_earth integer,
    age_in_millions_of_years integer,
    description text,
    planet_type numeric,
    star_id integer
);


ALTER TABLE public.planet OWNER TO freecodecamp;

--
-- Name: planet_id_planet_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.planet_id_planet_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planet_id_planet_seq OWNER TO freecodecamp;

--
-- Name: planet_id_planet_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.planet_id_planet_seq OWNED BY public.planet.planet_id;


--
-- Name: planet_type; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.planet_type (
    planet_type_id integer NOT NULL,
    short_desc character varying(50) NOT NULL,
    description text,
    name character varying DEFAULT 'na'::character varying NOT NULL
);


ALTER TABLE public.planet_type OWNER TO freecodecamp;

--
-- Name: planet_type_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.planet_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planet_type_id_seq OWNER TO freecodecamp;

--
-- Name: planet_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.planet_type_id_seq OWNED BY public.planet_type.planet_type_id;


--
-- Name: star; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.star (
    star_id integer NOT NULL,
    name character varying(80) NOT NULL,
    is_spherical boolean,
    has_life boolean,
    distance_from_earth integer,
    age_in_millions_of_years integer,
    description text,
    planet_type numeric,
    galaxy_id integer
);


ALTER TABLE public.star OWNER TO freecodecamp;

--
-- Name: star_id_star_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.star_id_star_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.star_id_star_seq OWNER TO freecodecamp;

--
-- Name: star_id_star_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.star_id_star_seq OWNED BY public.star.star_id;


--
-- Name: galaxy galaxy_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.galaxy ALTER COLUMN galaxy_id SET DEFAULT nextval('public.galaxy_id_galaxy_seq'::regclass);


--
-- Name: moon moon_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.moon ALTER COLUMN moon_id SET DEFAULT nextval('public.moon_moon_id_seq'::regclass);


--
-- Name: planet planet_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet ALTER COLUMN planet_id SET DEFAULT nextval('public.planet_id_planet_seq'::regclass);


--
-- Name: planet_type planet_type_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet_type ALTER COLUMN planet_type_id SET DEFAULT nextval('public.planet_type_id_seq'::regclass);


--
-- Name: star star_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.star ALTER COLUMN star_id SET DEFAULT nextval('public.star_id_star_seq'::regclass);


--
-- Data for Name: galaxy; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.galaxy VALUES (1, 'Andromeda', true, true, 3, 10, 'Default description', 2);
INSERT INTO public.galaxy VALUES (2, 'Antennae Galaxy', true, true, 3, 10, 'This is a dual galaxy. Its gets its name because it is said to look like a pair of insect antennae.', 2);
INSERT INTO public.galaxy VALUES (3, 'Backward Galaxy', true, true, 5, 17, 'It seems to rotate to opposite direction.', 1);
INSERT INTO public.galaxy VALUES (4, 'Black eye  Galaxy', true, false, 6, 14, 'It looks like an eye with dark stripe underneath.', 1);
INSERT INTO public.galaxy VALUES (5, 'Butterfly  Galaxies', false, false, 12, 67, 'Binary Galaxies.', 0);
INSERT INTO public.galaxy VALUES (6, 'Cartwheel  Galaxy', false, false, 12, 67, 'It looks a bit like a cartweel.', 0);


--
-- Data for Name: moon; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.moon VALUES (1, 'Moon 1', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.moon VALUES (2, 'Moon 2', false, false, 12, 67, 'Default description', 0, 2);
INSERT INTO public.moon VALUES (3, 'Moon 3', false, false, 12, 67, 'Default description', 0, 3);
INSERT INTO public.moon VALUES (4, 'Moon 4', false, false, 12, 67, 'Default description', 0, 4);
INSERT INTO public.moon VALUES (5, 'Moon 5', false, false, 12, 67, 'Default description', 0, 5);
INSERT INTO public.moon VALUES (6, 'Moon 6', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (9, 'Moon 7', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (10, 'Moon 8', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (11, 'Moon 9', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (12, 'Moon 10', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (13, 'Moon 11', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (14, 'Moon 12', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (15, 'Moon 13', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (16, 'Moon 14', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (17, 'Moon 15', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (18, 'Moon 16', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (19, 'Moon 17', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (20, 'Moon 18', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (21, 'Moon 19', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.moon VALUES (22, 'Moon 20', false, false, 12, 67, 'Default description', 0, 6);


--
-- Data for Name: planet; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.planet VALUES (1, 'Planet 1', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (2, 'Planet 2', false, false, 12, 67, 'Default description', 0, 2);
INSERT INTO public.planet VALUES (3, 'Planet 3', false, false, 12, 67, 'Default description', 0, 3);
INSERT INTO public.planet VALUES (4, 'Planet 4', false, false, 12, 67, 'Default description', 0, 4);
INSERT INTO public.planet VALUES (5, 'Planet 5', false, false, 12, 67, 'Default description', 0, 5);
INSERT INTO public.planet VALUES (6, 'Planet 6', false, false, 12, 67, 'Default description', 0, 6);
INSERT INTO public.planet VALUES (7, 'Moon 7', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (8, 'Moon 8', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (9, 'Moon 9', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (10, 'Moon 10', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (11, 'Moon 11', false, false, 12, 67, 'Default description', 0, 1);
INSERT INTO public.planet VALUES (12, 'Moon 12', false, false, 12, 67, 'Default description', 0, 1);


--
-- Data for Name: planet_type; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.planet_type VALUES (1, 'NO', 'Does not have', 'na');
INSERT INTO public.planet_type VALUES (2, 'YES', 'Does have', 'na');
INSERT INTO public.planet_type VALUES (3, 'CANDIDATE', 'Have Candidates', 'na');


--
-- Data for Name: star; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.star VALUES (1, 'Alpha', false, false, 12, 67, 'The biggest star in constellation of Andromeda Galaxy.', 0, 1);
INSERT INTO public.star VALUES (2, 'X PA34', false, false, 12, 67, 'X PA34.', 0, 2);
INSERT INTO public.star VALUES (3, 'Redshift', false, false, 12, 67, 'X PA34.', 0, 3);
INSERT INTO public.star VALUES (4, 'Blue Star', false, false, 12, 67, 'Default description', 0, 4);
INSERT INTO public.star VALUES (5, 'White Star', false, false, 12, 67, 'Default description', 0, 5);
INSERT INTO public.star VALUES (6, 'Black Star', false, false, 12, 67, 'Default description', 0, 6);


--
-- Name: galaxy_id_galaxy_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.galaxy_id_galaxy_seq', 6, true);


--
-- Name: moon_moon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.moon_moon_id_seq', 22, true);


--
-- Name: planet_id_planet_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.planet_id_planet_seq', 12, true);


--
-- Name: planet_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.planet_type_id_seq', 3, true);


--
-- Name: star_id_star_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.star_id_star_seq', 6, true);


--
-- Name: galaxy galaxy_name_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.galaxy
    ADD CONSTRAINT galaxy_name_key UNIQUE (name);


--
-- Name: galaxy galaxy_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.galaxy
    ADD CONSTRAINT galaxy_pkey PRIMARY KEY (galaxy_id);


--
-- Name: planet_type id_planet_type_unique; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet_type
    ADD CONSTRAINT id_planet_type_unique UNIQUE (planet_type_id);


--
-- Name: moon moon_name_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.moon
    ADD CONSTRAINT moon_name_key UNIQUE (name);


--
-- Name: moon moon_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.moon
    ADD CONSTRAINT moon_pkey PRIMARY KEY (moon_id);


--
-- Name: planet planet_name_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet
    ADD CONSTRAINT planet_name_key UNIQUE (name);


--
-- Name: planet planet_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet
    ADD CONSTRAINT planet_pkey PRIMARY KEY (planet_id);


--
-- Name: planet_type planet_type_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet_type
    ADD CONSTRAINT planet_type_pkey PRIMARY KEY (planet_type_id);


--
-- Name: star star_id_galaxy_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.star
    ADD CONSTRAINT star_id_galaxy_key UNIQUE (galaxy_id);


--
-- Name: star star_name_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.star
    ADD CONSTRAINT star_name_key UNIQUE (name);


--
-- Name: star star_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.star
    ADD CONSTRAINT star_pkey PRIMARY KEY (star_id);


--
-- Name: moon moon_id_planet_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.moon
    ADD CONSTRAINT moon_id_planet_fkey FOREIGN KEY (planet_id) REFERENCES public.planet(planet_id);


--
-- Name: planet planet_id_star_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.planet
    ADD CONSTRAINT planet_id_star_fkey FOREIGN KEY (star_id) REFERENCES public.star(star_id);


--
-- Name: star star_id_galaxy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.star
    ADD CONSTRAINT star_id_galaxy_fkey FOREIGN KEY (galaxy_id) REFERENCES public.galaxy(galaxy_id);


--
-- PostgreSQL database dump complete
--

