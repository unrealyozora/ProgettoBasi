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
    CHECK (cod_fiscale > 0),
    CHECK (genere_serie IN ('Azione', 'Avventura', 'Commedia', 'Drammatico', 'Fantascienza', 'Fantasy', 'Horror', 'Romantico', 'Thriller', 'Western', 'Giallo'))

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
	FOREIGN KEY (piattaforma_streaming) REFERENCES PIATTAFORMA_STREAMING(nome) ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (anno_inizio > 1900 AND genere IN ('Azione', 'Avventura', 'Commedia', 'Drammatico', 'Fantascienza', 'Fantasy', 'Horror', 'Romantico', 'Thriller', 'Western', 'Giallo'))
);

CREATE TABLE STAGIONE(
	titolo_serie VARCHAR (100),
	anno_serie INT,
	numero_stagione int,
	anno int NOT NULL,
	PRIMARY KEY (titolo_serie, anno_serie, numero_stagione),
	FOREIGN KEY (titolo_serie, anno_serie) REFERENCES SERIE_TV (titolo, anno_inizio) ON DELETE CASCADE ON UPDATE CASCADE,
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
    durata INT NOT NULL,
    PRIMARY KEY (titolo_serie, anno_serie, numero_stagione, numero_episodio),
    FOREIGN KEY (titolo_serie,anno_serie,numero_stagione) REFERENCES STAGIONE (titolo_serie, anno_serie, numero_stagione) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (numero_episodio > 0),
    CHECK (durata > 0)
);

CREATE TABLE OPENING(
	titolo VARCHAR (100) PRIMARY KEY,
    titolo_serie VARCHAR (100) NOT NULL,
    anno_serie INT NOT NULL,
    compositore VARCHAR (100) NOT NULL,
    durata INT NOT NULL,
    FOREIGN KEY (titolo_serie, anno_serie) REFERENCES SERIE_TV (titolo, anno_inizio) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (durata > 0)
);

CREATE TABLE VISUALIZZAZIONE(
    cod_fiscale INT NOT NULL,
    titolo_serie VARCHAR (100) NOT NULL,
    anno_serie INT NOT NULL,
    numero_stagione INT NOT NULL,
    numero_episodio INT NOT NULL,
    data DATE NOT NULL,
    voto INT,
	PRIMARY KEY (cod_fiscale, titolo_serie, anno_serie, numero_stagione, numero_episodio, data),
    FOREIGN KEY (cod_fiscale) REFERENCES UTENTE (cod_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (titolo_serie, anno_serie, numero_stagione, numero_episodio) REFERENCES EPISODIO (titolo_serie, anno_serie, numero_stagione, numero_episodio) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (voto >= 0 AND voto <= 10)
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
    CHECK (compenso > 0)
);



CREATE TABLE SOTTOSCRIZIONE(
    cod_fiscale INT
    nome_piattaforma VARCHAR (100),
    data_inizio DATE NOT NULL,
    data_fine DATE,
    tipo_abbonamento VARCHAR (100) NOT NULL,
    PRIMARY KEY (cod_fiscale, nome_piattaforma),
    FOREIGN KEY (cod_fiscale) REFERENCES UTENTE(cod_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome_piattaforma) REFERENCES PIATTAFORMA_STREAMING(nome) ON DELETE CASCADE ON UPDATE CASCADE
    --Decidere il significato di tipo_abbonamento e check di cosneguenza CHECK ()

);