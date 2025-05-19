DROP TABLE IF EXISTS SOTTOSCRIZIONE;
DROP TABLE IF EXISTS PERFORMANCE;
DROP TABLE IF EXISTS ATTORE;
DROP TABLE IF EXISTS VISUALIZZAZIONE;
DROP TABLE IF EXISTS OPENING;
DROP TABLE IF EXISTS EPISODIO;
DROP TABLE IF EXISTS STAGIONE;
DROP TABLE IF EXISTS SERIE_TV;
DROP TABLE IF EXISTS REGISTA;
DROP TABLE IF EXISTS PIATTAFORMA_STREAMING;
DROP TABLE IF EXISTS REGISTA;
DROP TABLE IF EXISTS SERIE_TV;
DROP TABLE IF EXISTS UTENTE;

CREATE TABLE PIATTAFORMA_STREAMING(
    nome VARCHAR (100) PRIMARY KEY,
    costo_mensile float NOT NULL
    CHECK (costo_mensile > 0)
);

CREATE TABLE UTENTE(
    username VARCHAR (100) PRIMARY KEY,
    nome VARCHAR (100) NOT NULL,
    data_nascita DATE NOT NULL,
    email VARCHAR (100) NOT NULL
);

CREATE TABLE ATTORE(
    cod_fiscale INT PRIMARY KEY,
    nome VARCHAR (100) NOT NULL,
    data_nascita DATE NOT NULL,
    nazionalita VARCHAR (100) NOT NULL,
    numero_serie int NOT NULL
    CHECK (numero_serie >= 0),
    CHECK (cod_fiscale > 0)
);

CREATE TABLE REGISTA(
    cod_fiscale INT PRIMARY KEY,
    nome VARCHAR (100) NOT NULL,
    data_nascita DATE NOT NULL,
    nazionalita VARCHAR (100) NOT NULL,
    genere_serie varchar (100) NOT NULL
    CHECK (cod_fiscale > 0)

);

CREATE TABLE SERIE_TV (
	titolo VARCHAR (100),
	anno_inizio INT,
	genere VARCHAR (100) NOT NULL,
	descrizione TEXT NOT NULL,
	regista INT NOT NULL,
	piattaforma_streaming VARCHAR (100) NOT NULL,
	PRIMARY KEY (titolo, anno_inizio),
	FOREIGN KEY (regista) REFERENCES REGISTA(cod_fiscale) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (piattaforma_streaming) REFERENCES PIATTAFORMA_STREAMING(nome) ON DELETE RESTRICT ON UPDATE CASCADE
    CHECK (anno_inizio > 1900),
);

CREATE TABLE STAGIONE(
	titolo_serie VARCHAR (100),
	anno_serie INT,
	numero_stagione int,
	anno int NOT NULL,
	PRIMARY KEY (titolo_serie, anno_serie, numero_stagione),
	FOREIGN KEY (titolo_serie, anno_serie) REFERENCES SERIE_TV (titolo, anno_inizio) ON DELETE CASCADE ON UPDATE CASCADE
    CHECK (anno > 1900),
    CHECK (numero_stagione > 0),
    CHECK (
        (numero_stagione <> 1)
        OR
        (anno = anno_serie)
    )
);

CREATE TABLE EPISODIO(
    titolo_serie VARCHAR (100),
    anno_serie INT,
    numero_stagione INT,
    numero_episodio INT,
    titolo_episodio VARCHAR (100) NOT NULL,
    anno INT NOT NULL,
    durata INT NOT NULL,
    numero_utenti INT NOT NULL,
    PRIMARY KEY (titolo_serie, anno_serie, numero_stagione, numero_episodio),
    FOREIGN KEY (titolo_serie,anno_serie,numero_stagione) REFERENCES STAGIONE (titolo_serie, anno_serie, numero_stagione) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (anno > 1900),
    CHECK (numero_episodio > 0),
    CHECK (durata > 0),
);

CREATE TABLE OPENING(
	titolo VARCHAR (100) PRIMARY KEY,
    titolo_serie VARCHAR (100) NOT NULL,
    anno_serie INT NOT NULL,
    compositore VARCHAR (100) NOT NULL,
    durata INT NOT NULL,
    FOREIGN KEY (titolo_serie, anno_serie) REFERENCES SERIE_TV (titolo, anno_inizio) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (durata > 0),
);

CREATE TABLE VISUALIZZAZIONE(
    username VARCHAR (100) NOT NULL,
    titolo_serie VARCHAR (100) NOT NULL,
    anno_serie INT NOT NULL,
    numero_stagione INT NOT NULL,
    numero_episodio INT NOT NULL,
    data DATE NOT NULL,
    voto INT,
	PRIMARY KEY (username, titolo_serie, anno_serie, numero_stagione, numero_episodio, data),
    FOREIGN KEY (username) REFERENCES UTENTE (username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (titolo_serie, anno_serie, numero_stagione, numero_episodio) REFERENCES EPISODIO (titolo_serie, anno_serie, numero_stagione, numero_episodio) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (voto >= 0 AND voto <= 10),
);

CREATE TABLE PERFORMANCE (
    id_attore INT,
    titolo_serie VARCHAR (100),
    anno_serie INT,
    ruolo VARCHAR (100) NOT NULL,
    compenso float NOT NULL,
    PRIMARY KEY (id_attore, titolo_serie, anno_serie),
    FOREIGN KEY (id_attore) REFERENCES ATTORE(cod_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (titolo_serie, anno_serie) REFERENCES SERIE_TV(titolo, anno_inizio) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (compenso > 0),
);



CREATE TABLE SOTTOSCRIZIONE(
    username VARCHAR (100),
    nome_piattaforma VARCHAR (100),
    data_inizio DATE NOT NULL,
    data_fine DATE,
    tipo_abbonamento VARCHAR (100) NOT NULL,
    PRIMARY KEY (username, nome_piattaforma),
    FOREIGN KEY (username) REFERENCES UTENTE(username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome_piattaforma) REFERENCES PIATTAFORMA_STREAMING(nome) ON DELETE CASCADE ON UPDATE CASCADE,
    --Decidere il significato di tipo_abbonamento e check di cosneguenza CHECK ()

);



-- PIATTAFORMA_STREAMING
INSERT INTO PIATTAFORMA_STREAMING VALUES
('Netflix', 15.99),
('Amazon Prime', 12.99),
('Disney+', 9.99);

-- UTENTE
INSERT INTO UTENTE VALUES
('mario_rossi', 'Mario Rossi', '1985-03-15', 'mario.rossi@example.com'),
('anna_bianchi', 'Anna Bianchi', '1990-07-22', 'anna.bianchi@example.com'),
('luigi_verdi', 'Luigi Verdi', '1978-11-30', 'luigi.verdi@example.com');

-- ATTORE
INSERT INTO ATTORE VALUES
(1, 'Giovanni Esposito', '1970-05-05', 'Italia', 3),
(2, 'Laura Neri', '1982-12-11', 'Italia', 2);

-- REGISTA
INSERT INTO REGISTA VALUES
(1, 'Federico Fellini', '1920-01-20', 'Italia', 'Drammatico'),
(2, 'Sofia Coppola', '1971-05-14', 'USA', 'Commedia');

-- SERIE_TV
INSERT INTO SERIE_TV VALUES
('La Grande Avventura', 2015, 'Avventura', 'Serie drammatica ambientata in montagna.', 1, 'Netflix', 'Tema Principale'),
('Amori e Destini', 2018, 'Romantico', 'Storie di amori complicati.', 2, 'Amazon Prime', 'Love Song');

-- STAGIONE
INSERT INTO STAGIONE VALUES
('La Grande Avventura', 2015, 1, 2015),
('La Grande Avventura', 2015, 2, 2016),
('Amori e Destini', 2018, 1, 2018);

-- EPISODIO
INSERT INTO EPISODIO VALUES
('La Grande Avventura', 2015, 1, 1, 'Inizio del viaggio', 2015, 45, 100),
('La Grande Avventura', 2015, 1, 2, 'La scoperta', 2015, 47, 95),
('Amori e Destini', 2018, 1, 1, 'Primo incontro', 2018, 50, 80);

-- OPENING
INSERT INTO OPENING VALUES
('Tema Principale', 'La Grande Avventura', 2015, 'Ennio Morricone', 120),
('Love Song', 'Amori e Destini', 2018, 'John Williams', 110);

-- VISUALIZZAZIONE
INSERT INTO VISUALIZZAZIONE VALUES
('mario_rossi', 'La Grande Avventura', 2015, 1, 1, '2023-05-01', 8),
('anna_bianchi', 'Amori e Destini', 2018, 1, 1, '2023-05-03', 9),
('luigi_verdi', 'La Grande Avventura', 2015, 1, 2, '2023-05-02', 7);

-- PERFORMANCE
INSERT INTO PERFORMANCE VALUES
(1, 'La Grande Avventura', 2015, 'Protagonista', 5000),
(2, 'Amori e Destini', 2018, 'Supporto', 3000);

-- SOTTOSCRIZIONE
INSERT INTO SOTTOSCRIZIONE VALUES
('mario_rossi', 'Netflix', '2023-01-01', '2023-12-31', 'Premium'),
('anna_bianchi', 'Amazon Prime', '2023-03-01', NULL, 'Standard'),
('luigi_verdi', 'Netflix', '2023-02-01', NULL, 'Standard');
