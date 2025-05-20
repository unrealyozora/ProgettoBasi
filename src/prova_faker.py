from faker import Faker
import random
from datetime import date


fake = Faker(["it_IT", "en_US"])
NUM_UTENTI = 1000
NUM_SERIE = 200
NUM_REGISTI = 50
NUM_ATTORI = 100
GENERI = ["Azione", "Avventura", "Commedia", "Drammatico", "Fantascienza", "Fantasy", "Horror", "Romantico", "Thriller", "Western", "Giallo"]
PIATTAFORME_STREAMING = ['Netflix', 'Amazon Prime', 'Disney+', 'HBO Max', 'Apple TV+']
RUOLI_ATTORE = ["Protagonista", "Secondario", "Guest Star"]

episodi=[]
lista_registi = []
serie={} #dizionari per memorizzare le serie e l'anno di inizio

lista_utenti = []
with open('src/populate.sql', "w", encoding="utf-8") as f:
   
     
   #UTENTI
   for i in range(NUM_UTENTI):
      id = fake.unique.random_int(min=1, max=99999)
      username = fake.user_name()
      nome = fake.name().replace("'", "''")
      nascita = fake.date_of_birth(minimum_age=18, maximum_age=80)
      email = fake.email()
      f.write(f"INSERT INTO UTENTE (idm username, nome, email) VALUES ({id}, '{username}', '{nome}', '{nascita}', {email}');\n")
      lista_utenti.append(id)

      
    #REGISTI
   for i in range(NUM_REGISTI):
    id = fake.unique.random_int(min=1,max=99999)
    lista_registi.append(id)
    nome = fake.name().replace("'", "''")
    nascita = fake.date_of_birth(minimum_age=18, maximum_age=80)
    nazionalita = fake.country()
    genere_serie = random.choice(GENERI)
    f.write(f"INSERT INTO REGISTA (id, nome, nascita, nazionalita, genere_serie) VALUES ({id}, '{nome}', '{nascita}', '{nazionalita}', '{genere_serie}');\n")

   

   #SERIE
   for i in range(NUM_SERIE):
     titolo=fake.unique.catch_phrase().replace("'", "''")
     anno_inizio=random.randint(1980, 2024)
     serie[titolo] = anno_inizio
     genre=random.choice(GENERI)
     descrizione=fake.text(max_nb_chars=200).replace("'", "''")
     regista=random.choice(lista_registi)
     piattaforma=random.choice(PIATTAFORME_STREAMING)
     f.write(f"INSERT INTO SERIE_TV (titolo, anno_inizio, genere, descrizione, regista, piattaforma) VALUES ('{titolo}', {anno_inizio}, '{genre}', '{descrizione}', {regista}, '{piattaforma}');\n")
     

     num_stagioni=random.randint(1, 10)
     for numero_stagione in range(1, num_stagioni+1):
       if numero_stagione == 1:
         anno_stagione = anno_inizio
       else:
         anno_stagione = anno_inizio + (numero_stagione -1) + random.randint(0,3)
       f.write(f"INSERT INTO STAGIONE (titolo_serie, anno_serie, numero_stagione, anno) VALUES ('{titolo}', {anno_inizio}, {numero_stagione}, {anno_stagione});\n")

       #EPISODI
       num_episodi=random.randint(1,20)
       for episodio in range(1, num_episodi+1):
         titolo_episodio=fake.sentence(nb_words=3).replace("'", "''")
         durata=random.randint(20, 60)
         f.write(f"INSERT INTO EPISODIO (titolo, stagione, episodio, titolo_episodio, durata) VALUES ('{titolo}', {anno_inizio}, {numero_stagione}, {episodio}, '{titolo_episodio}', {durata});\n")
         episodi.append((titolo, anno_inizio, numero_stagione, episodio))


   #OPENING
   random_serie = random.sample(list(serie.items()), k=150)
   for titolo, anno in random_serie:
     titolo_serie = titolo.replace("'", "''")
     anno_serie = anno
     titolo_op = fake.sentence(nb_words=3).replace("'", "''")
     compositore = fake.name().replace("'", "''")
     durata = random.randint(30, 120)

   #ATTORI
   lista_attori = []
   for i in range (NUM_ATTORI):
     id = fake.unique.random_int(min=1_000_000, max=9_999_999)
     nome = fake.name().replace("'", "''")
     data_nascita = fake.date_of_birth(minimum_age=18, maximum_age=80)
     nazionalita = fake.country().replace("'", "''")
     numero_serie = random.randint(1, min(15, len(list(serie))))
     lista_attori.append({'id': id, 'nome': nome, 'data_nascita': data_nascita, 'nazionalita': nazionalita, 'num_serie': numero_serie})
     f.write(f"INSERT INTO ATTORE (id, nome, data_nascita, nazionalita) VALUES ({id}, '{nome}', '{data_nascita}', '{nazionalita}', {numero_serie});\n")


   #VISUALIZZAZIONI
   visualizzazioni = set()
   for i in range(1000):
     user=random.choice(lista_utenti)
     titolo, anno, stagione, episodio = random.choice(episodi)
     data_visione = fake.date_between(start_date=date(anno,1,1), end_date=date(2024,12,31))
     voto = random.choice([None] +list(range(1,11)))
     key=(user, titolo, anno, stagione, episodio, data_visione)
     if key in visualizzazioni:
       continue
     visualizzazioni.add(key)
     voto_str=str(voto) if voto is not None else "NULL"
     f.write(
            f"INSERT INTO VISUALIZZAZIONE (username, titolo_serie, anno_serie, numero_stagione, numero_episodio, data, voto) "
            f"VALUES ('{user}', '{titolo}', {anno}, {stagione}, {episodio}, '{data_visione}', {voto_str});\n"
        )
    
   #PERFORMANCE
   performance = set()

   for attore in lista_attori:
     id_attore = attore["id"]
     num_serie = attore["num_serie"]

     if num_serie > len(list(serie)):
       num_serie = len(list(serie))
     serie_scelte = random.sample(list(serie.items()), num_serie)
     for titolo, anno in serie_scelte:
       if (id_attore, titolo, anno) in performance:
         continue
       ruolo = random.choice(RUOLI_ATTORE)
       compenso=round(random.uniform(1000, 10000),2)
       f.write(
                f"INSERT INTO PERFORMANCE (id_attore, titolo_serie, anno_serie, ruolo, compenso) "
                f"VALUES ({id_attore}, '{titolo}', {anno}, '{ruolo}', {compenso});\n"
            )
       performance.add((id_attore, titolo, anno))

   


   
        

     
