#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <string.h>
#include <stdbool.h>
typedef int (*QueryFunction)(PGconn* conn);

char* PIATTAFORME_STREAMING[]={
    "Netflix", "Amazon Prime", "Disney+", "HBO Max", "Apple TV+"
};

char* NAZIONALITA[]={
    "Italy", "USA", "UK", "France", "Germany"
};
int query1(PGconn* conn);
int query2(PGconn* conn);
int query3(PGconn* conn);
int query4(PGconn* conn);
int query5(PGconn* conn);




int main(int argc, char* argv[]) {
    //Array of function pointers to our queries
    QueryFunction queries[] = {
        NULL,       
        query1,
        query2,
        query3,
        query4,
        query5
    };

    // Connect to database and handle errors
    PGconn* conn = PQconnectdb("host=localhost dbname=progettoSerieTv user=postgres password=");
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        return 1;
    }


    printf("Connected successfully!\n");
    if (argc > 1) {
        int query = atoi(argv[1]);
        if (query <1 || query > 5){
            printf("Invalid query number. Please select a number between 1 and 5.\n");
            PQfinish(conn);
            return 1;
        }
        return queries[query](conn);
    }
    while (1){
        int query=0;

        printf("Available queries:\n"
            "    1. Show all Tv Series of a specific Streaming Service, with related informations\n"
            "    2. Show the average rating of a specific Tv Series' episodes, with average rating > 7.5\n"
            "    3. Show the last month's views, and the total users of a every streaming platform\n"
            "    4. Show the 10 most payed actors for a specific TV Series\n"
            "    5. Show the first 3 TV Series (for total views number) by directors from a specific Country, available on streaming platforms with a cost less than 10 euros\n"
            "    0. Exit\n");
        printf("---------------------------------------------------------------\n");
        printf("Select a query: ");
        scanf("%d", &query);
        if (query==0){
            printf("Exiting...\n");
            break;
        }else if (query<1 || query>5){
            printf("Invalid query number. Please select a number between 1 and 5.\n");
            continue;
        }
        queries[query](conn);
        printf("---------------------------------------------------------------\n");
    }
    PQfinish(conn);
    return 0;
}



int query1(PGconn* conn){
    // Query 1: Show all Tv Series of a specific Streaming Service, with related informations
    char streaming_service[50];
    printf("Enter the name of the streaming service: ");
    scanf("%49s", streaming_service);
    int len = sizeof(PIATTAFORME_STREAMING)/sizeof(PIATTAFORME_STREAMING[0]);
    bool found = false;
    for (int i = 0; i<len; i++){
        if (!strcmp(PIATTAFORME_STREAMING[i], streaming_service)){
            found = true;
            break;
        }
    }
    if (!found){
        printf("Invalid streaming service. Please select a valid one. \n");
        return 1;
    }
    char query[512];
    snprintf(query, sizeof(query), 
        "SELECT stv.titolo, COUNT(*) as numero_stagioni, op.titolo"
        " FROM serie_tv stv" 
        " JOIN stagione st ON st.titolo_serie=stv.titolo AND st.anno_serie=stv.anno_inizio"
        " JOIN opening op ON op.titolo_serie=stv.titolo AND op.anno_serie=stv.anno_inizio" 
        " WHERE piattaforma_streaming = '%s' "
        " GROUP BY stv.titolo, op.titolo", streaming_service);

    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int rows = PQntuples(res);
    if (rows==0) {
        printf("No TV Series found for the specified streaming service.\n");
    }
    for (int i = 0; i < rows; i++) {
        printf("Tv Series: %s, Seasons: %s, Opening: %s\n", PQgetvalue(res, i, 0), PQgetvalue(res, i, 1), PQgetvalue(res, i, 2));
    }

    PQclear(res);
    PQfinish(conn);
    return 0;
}

int query2(PGconn* conn){
    //Query 2: Show the average rating of a specific Tv Series' episodes, with average rating > 7.5
    char tv_series[100];
    printf("Enter the name of the TV Series: ");
    scanf("%99s", tv_series);
    char query[512];
    snprintf(query, sizeof(query),
        "SELECT E.TITOLO_episodio, AVG(V.Voto) as MediaVoto"
        " FROM Episodio E"
        " JOIN VISUALIZZAZIONE V ON "
        " E.Titolo_Serie = V.Titolo_Serie AND "
        " E.Anno_Serie = V.Anno_Serie AND "
        " E.Numero_Stagione = V.Numero_Stagione AND "
        " E.Numero_Episodio = V.Numero_Episodio "
        " WHERE E.Titolo_Serie = '%s' "
        " GROUP BY E.Titolo_episodio "
        " HAVING AVG(V.Voto)>7.5", tv_series);
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    if (PQntuples(res) == 0) {
        printf("No episodes found with an average rating greater than 7.5 for the specified TV Series.\n");
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int rows = PQntuples(res);
    printf("Tv Series: %s\n", tv_series);
    for (int i = 0; i < rows; i++) {
        printf("Episode title: %s Average rating: %.2f\n", PQgetvalue(res, i, 0), atof(PQgetvalue(res, i, 1)));
    }

    PQclear(res);
    PQfinish(conn);
    return 0;
}

int query3(PGconn* conn){
    //Query 3: Show the last month's views, and the total users of every streaming platform
    char query[800];
    snprintf(query, sizeof(query),
        "SELECT "
        "ps.nome AS piattaforma, "
        "vstats.totale_visualizzazioni AS totale_visualizzazioni, "
        "sstats.utenti_iscritti AS utenti_iscritti "
        "FROM PIATTAFORMA_STREAMING ps "
        "LEFT JOIN ( "
            "SELECT "
            "st.piattaforma_streaming AS piattaforma, "
            "COUNT(*) AS totale_visualizzazioni "
            "FROM VISUALIZZAZIONE v "
            "JOIN SERIE_TV st ON v.titolo_serie = st.titolo AND v.anno_serie = st.anno_inizio "
            "WHERE v.data BETWEEN DATE '2025-04-20' AND DATE '2025-05-20' "
            "GROUP BY st.piattaforma_streaming "
        ") AS vstats ON ps.nome = vstats.piattaforma "
        "LEFT JOIN ( "
            "SELECT nome_piattaforma AS piattaforma, "
            "COUNT(DISTINCT username) AS utenti_iscritti "
            "FROM SOTTOSCRIZIONE "
            "GROUP BY nome_piattaforma "
        ") AS sstats ON ps.nome = sstats.piattaforma "
        "ORDER BY totale_visualizzazioni DESC;");
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    if (PQntuples(res) == 0) {
        printf("No views found for the specified date range.\n");
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int rows = PQntuples(res);

    printf("%-25s %-15s %-15s\n", "Streaming Platform", "Total Views", "Total Users");
    printf("---------------------------------------------------------------\n");

    for (int i = 0; i < rows; i++) {
        printf("%-25s %-15s %-15s\n",
            PQgetvalue(res, i, 0),
            PQgetvalue(res, i, 1),
            PQgetvalue(res, i, 2));
    }

    PQclear(res);
    PQfinish(conn);
    return 0;
}

int query4(PGconn* conn){
    //Query 4: Show the 10 most payed actors from a selected country, and the relative TV Series
    char country[100];
    printf("Countries available:\n");
    for (int i = 0; i<sizeof(NAZIONALITA)/sizeof(NAZIONALITA[0]); i++){
        printf("%d. %s\n", i+1, NAZIONALITA[i]);
    }
    printf("Enter the name of the Country: ");
    scanf("%99s", country);
    int len = sizeof(NAZIONALITA)/sizeof(NAZIONALITA[0]);
    bool found = false;
    for (int i = 0; i<len; i++){
        if (!strcmp(NAZIONALITA[i], country)){
            found = true;
            break;
        }
    }
    if (!found){
        printf("Invalid country. Please select a valid one. \n");
        return 1;
    }
    char query[512];
    snprintf(query, sizeof(query),
        "SELECT DISTINCT a.nome, p.compenso, stv.titolo "
        "FROM attore AS a "
        "JOIN performance AS p "
        "ON p.id_attore=a.cod_fiscale and a.nazionalita= '%s' "
        "JOIN serie_tv as stv "
        "ON stv.titolo=p.titolo_serie and stv.anno_inizio=p.anno_serie "
        "ORDER BY p.compenso DESC "
        "LIMIT 10", country);
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int rows = PQntuples(res);
    printf("Most payed actors for a single TV series from %s:\n", country);
    printf("%-27s %-15s %-15s\n", "Actor Name", "Salary", "Tv Series");
    printf("---------------------------------------------------------------\n");
    for (int i = 0; i < rows; i++) {
        printf("%-27s€ %-15s %-15s\n",
            PQgetvalue(res, i, 0),
            PQgetvalue(res, i, 1),
            PQgetvalue(res, i, 2));
    }
}

int query5(PGconn* conn){
    //Query 5: Show the first 3 TV Series (for total views number) by directors from a specific Country, available on streaming platforms within a selected cost.
    char country[100];
    char cost[10];
    printf("Countries available:\n");
    for (int i = 0; i<sizeof(NAZIONALITA)/sizeof(NAZIONALITA[0]); i++){
        printf("%d. %s\n", i+1, NAZIONALITA[i]);
    }
    printf("Enter the name of the Country: ");
    scanf("%99s", country);
    int len = sizeof(NAZIONALITA)/sizeof(NAZIONALITA[0]);
    bool found = false;
    for (int i = 0; i<len; i++){
        if (!strcmp(NAZIONALITA[i], country)){
            found = true;
            break;
        }
    }
    if (!found){
        printf("Invalid country. Please select a valid one. \n");
        return 1;
    }
    printf("Enter the maximum cost of the streaming platform: ");
    scanf("%9s", cost);
    char query[512];
    snprintf(query, sizeof(query),
        "SELECT stv.titolo, COUNT(*) AS Visualizzazioni, r.nome, stv.piattaforma_streaming as PiattaformaStreaming "
        "FROM serie_tv AS stv "
        "JOIN Visualizzazione AS v "
        "ON stv.titolo=v.titolo_serie and stv.anno_inizio=v.anno_serie "
        "JOIN regista AS r "
        "ON r.cod_fiscale=stv.regista "
        "JOIN piattaforma_streaming AS p "
        "ON p.nome=stv.piattaforma_streaming "
        "WHERE r.nazionalita='%s' and p.costo_mensile<%s "
        "GROUP BY stv.titolo, r.nome, stv.piattaforma_streaming "
        "ORDER BY Visualizzazioni DESC "
        "LIMIT 3;", country, cost);
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    if (PQntuples(res) == 0) {
        printf("No TV Series found within the specified cost.\n");
        PQclear(res);
        PQfinish(conn);
        return 1;
    }
    int rows = PQntuples(res);
    printf("Top 3 TV Series from %s:\n", country);
    printf("%-35s %-15s %-20s %-15s\n", "Tv Series", "Views", "Director", "Streaming Platform");
    printf("---------------------------------------------------------------------------------------\n");
    for (int i = 0; i < rows; i++) {
        printf("%-35s %-15s %-20s %-15s\n",
            PQgetvalue(res, i, 0),
            PQgetvalue(res, i, 1),
            PQgetvalue(res, i, 2),
            PQgetvalue(res, i, 3));
    }
}