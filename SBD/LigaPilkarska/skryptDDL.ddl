-- Tabela Stadion
CREATE TABLE Stadion (
    Nazwa VARCHAR(255) PRIMARY KEY,
    Pojemnosc INT,
    Adres VARCHAR(255),
    Miasto VARCHAR(255),
    Data_budowy DATE
);

-- Tabela Sezon
CREATE TABLE Sezon (
    Numer_sezonu INT PRIMARY KEY,
    Data_rozpoczecia DATE,
    Data_zakonczenia DATE
);

-- Tabela Klub
CREATE TABLE Klub (
    Nazwa VARCHAR(255) PRIMARY KEY,
    Skrot VARCHAR(3),
    Data_zalozenia DATE,
    Nazwa_Stadionu VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (Nazwa_Stadionu) REFERENCES Stadion(Nazwa)
);

CREATE SEQUENCE mecz_id_seq START WITH 1 INCREMENT BY 1;

-- Tabela Mecz
CREATE TABLE Mecz (
    Mecz_ID INT DEFAULT mecz_id_seq.NEXTVAL PRIMARY KEY,
    Data_Meczu DATE NOT NULL,
    Klub_Gospodarz VARCHAR(255) NOT NULL,
    Klub_Gosc VARCHAR(255) NOT NULL,
    Nazwa_Stadionu VARCHAR(255) NOT NULL,
    Sezon_Numer_sezonu INT NOT NULL,
    CONSTRAINT Unikalny_Mecz UNIQUE (Data_Meczu, Klub_Gospodarz, Klub_Gosc),
    FOREIGN KEY (Klub_Gospodarz) REFERENCES Klub(Nazwa),
    FOREIGN KEY (Klub_Gosc) REFERENCES Klub(Nazwa),
    FOREIGN KEY (Nazwa_Stadionu) REFERENCES Stadion(Nazwa),
    FOREIGN KEY (Sezon_Numer_sezonu) REFERENCES Sezon(Numer_sezonu)
);

-- Tabela Zawodnik
CREATE TABLE Zawodnik (
    PESEL CHAR(11) PRIMARY KEY,
    Imie VARCHAR(255),
    Nazwisko VARCHAR(255),
    Data_urodzenia DATE,
    Pozycja VARCHAR(255),
    Numer INT
);

-- Tabela Trener
CREATE TABLE Trener (
    PESEL CHAR(11) PRIMARY KEY,
    Imie VARCHAR(255),
    Nazwisko VARCHAR(255),
    Data_urodzenia DATE,
    Numer_telefonu CHAR(9),
    email VARCHAR(255)
);

-- Tabela Historia_zatrudnienia_zawodnikow
CREATE TABLE Historia_zatrudnienia_zawodnikow (
    Od DATE,
    Do DATE,
    Zawodnik_PESEL CHAR(11),
    Klub_Nazwa VARCHAR(255),
    PRIMARY KEY (Zawodnik_PESEL, Klub_Nazwa, Od),
    FOREIGN KEY (Zawodnik_PESEL) REFERENCES Zawodnik(PESEL),
    FOREIGN KEY (Klub_Nazwa) REFERENCES Klub(Nazwa)
);

-- Tabela Historia_zatrudnienia_trenerow
CREATE TABLE Historia_zatrudnienia_trenerow (
    Od DATE,
    Do DATE,
    Trener_PESEL CHAR(11),
    Klub_Nazwa VARCHAR(255),
    PRIMARY KEY (Trener_PESEL, Klub_Nazwa, Od),
    FOREIGN KEY (Trener_PESEL) REFERENCES Trener(PESEL),
    FOREIGN KEY (Klub_Nazwa) REFERENCES Klub(Nazwa)
);

-- Tabela Statystyka

CREATE TABLE Statystyka (
    Ilosc_bramek INT,
    Ilosc_asyst INT,
    Minuty INT,
    Zolta_kartka INT,
    Czerwona_kartka INT,
    Mecz_Mecz_ID INT,
    Zawodnik_PESEL CHAR(11),
    PRIMARY KEY (Mecz_Mecz_ID, Zawodnik_PESEL),
    FOREIGN KEY (Mecz_Mecz_ID) REFERENCES Mecz(Mecz_ID),
    FOREIGN KEY (Zawodnik_PESEL) REFERENCES Zawodnik(PESEL)
);

-- Tabela Punktacja
CREATE TABLE Punktacja (
    Wygrane INT,
    Przegrane INT,
    Remisy INT,
    Klub_Nazwa VARCHAR(255),
    Sezon_Numer_sezonu INT,
    PRIMARY KEY (Klub_Nazwa, Sezon_Numer_sezonu),
    FOREIGN KEY (Klub_Nazwa) REFERENCES Klub(Nazwa),
    FOREIGN KEY (Sezon_Numer_sezonu) REFERENCES Sezon(Numer_sezonu)
);

--Funkcja do obliczania średniej ilosci bramek dlanego zespolu w konkretnym sezonie
CREATE OR REPLACE FUNCTION SredniaBramek(klubNazwa IN VARCHAR2, numerSezonu IN INT)
RETURN FLOAT IS
  srednia FLOAT;
BEGIN
  SELECT AVG(Ilosc_bramek)
  INTO srednia
  FROM Statystyka
  JOIN Mecz ON Statystyka.Mecz_Mecz_ID = Mecz.Mecz_ID
  WHERE (Mecz.Klub_Gospodarz = klubNazwa OR Mecz.Klub_Gosc = klubNazwa)
  AND Mecz.Sezon_Numer_sezonu = numerSezonu;

  RETURN srednia;
END SredniaBramek;

--Procedura aktualizująca bramki i asysty w tabeli statystyki
CREATE OR REPLACE PROCEDURE AktualizujStatystyki(
    meczID IN Statystyka.Mecz_Mecz_ID%TYPE,
    zawodnikPESEL IN Statystyka.Zawodnik_PESEL%TYPE,
    bramki IN Statystyka.Ilosc_bramek%TYPE,
    asysty IN Statystyka.Ilosc_asyst%TYPE
)
BEGIN
    UPDATE Statystyka
    SET Ilosc_bramek = Ilosc_bramek + bramki,
        Ilosc_asyst = Ilosc_asyst + asysty
    WHERE Mecz_Mecz_ID = meczID AND Zawodnik_PESEL = zawodnikPESEL;
END AktualizujStatystyki;

-- Wstawianie danych do tabeli Stadion
INSERT INTO Stadion (Nazwa, Pojemnosc, Adres, Miasto, Data_budowy) VALUES ('Stadion Narodowy', 58000, 'Av. Aristides Maillol 1', 'Barcelona', TO_DATE('2011-01-01', 'YYYY-MM-DD'));
INSERT INTO Stadion (Nazwa, Pojemnosc, Adres, Miasto, Data_budowy) VALUES ('Santiago Bernabeu', 42000, 'Av. de Concha Espina 1', 'Madryt', TO_DATE('1980-06-22', 'YYYY-MM-DD'));
INSERT INTO Stadion (Nazwa, Pojemnosc, Adres, Miasto, Data_budowy) VALUES ('Wanda Metropolitano', 54000, 'Av. de Luis Aragonés 4', 'Madryt', TO_DATE('1956-07-22', 'YYYY-MM-DD'));

-- Wstawianie danych do tabeli Sezon
INSERT INTO Sezon (Numer_sezonu, Data_rozpoczecia, Data_zakonczenia) VALUES (1, TO_DATE('2022-08-01', 'YYYY-MM-DD'), TO_DATE('2023-05-30', 'YYYY-MM-DD'));
INSERT INTO Sezon (Numer_sezonu, Data_rozpoczecia, Data_zakonczenia) VALUES (2, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2024-05-30', 'YYYY-MM-DD'));
INSERT INTO Sezon (Numer_sezonu, Data_rozpoczecia, Data_zakonczenia) VALUES (3, TO_DATE('2024-08-01', 'YYYY-MM-DD'), TO_DATE('2025-05-30', 'YYYY-MM-DD'));

-- Wstawianie danych do tabeli Klub
INSERT INTO Klub (Nazwa, Skrot, Data_zalozenia, Nazwa_Stadionu) VALUES ('FC Barcelona', 'FCB', TO_DATE('1899-11-29', 'YYYY-MM-DD'), 'Stadion Narodowy');
INSERT INTO Klub (Nazwa, Skrot, Data_zalozenia, Nazwa_Stadionu) VALUES ('Real Madryt', 'RMD', TO_DATE('1902-03-06', 'YYYY-MM-DD'), 'Stadion Miejski');
INSERT INTO Klub (Nazwa, Skrot, Data_zalozenia, Nazwa_Stadionu) VALUES ('Atletico Madryt', 'ATM', TO_DATE('1903-04-26', 'YYYY-MM-DD'), 'Stadion Śląski');

-- Wstawianie danych do tabeli Zawodnik
INSERT INTO Zawodnik (PESEL, Imie, Nazwisko, Data_urodzenia, Pozycja, Numer) VALUES ('12345678901', 'Lionel', 'Messi', TO_DATE('1987-06-24', 'YYYY-MM-DD'), 'Napastnik', 10);
INSERT INTO Zawodnik (PESEL, Imie, Nazwisko, Data_urodzenia, Pozycja, Numer) VALUES ('23456789012', 'Cristiano', 'Ronaldo', TO_DATE('1985-02-05', 'YYYY-MM-DD'), 'Napastnik', 7);
INSERT INTO Zawodnik (PESEL, Imie, Nazwisko, Data_urodzenia, Pozycja, Numer) VALUES ('34567890123', 'Neymar', 'Jr', TO_DATE('1992-02-05', 'YYYY-MM-DD'), 'Napastnik', 11);

-- Wstawianie danych do tabeli Trener
INSERT INTO Trener (PESEL, Imie, Nazwisko, Data_urodzenia, Numer_telefonu, email) VALUES ('45678901234', 'Pep', 'Guardiola', TO_DATE('1971-01-18', 'YYYY-MM-DD'), '123456789', 'pep@barca.com');
INSERT INTO Trener (PESEL, Imie, Nazwisko, Data_urodzenia, Numer_telefonu, email) VALUES ('56789012345', 'Zinedine', 'Zidane', TO_DATE('1967-03-21', 'YYYY-MM-DD'), '234567891', 'zizu@real.com');
INSERT INTO Trener (PESEL, Imie, Nazwisko, Data_urodzenia, Numer_telefonu, email) VALUES ('67890123456', 'Diego', 'Simeone', TO_DATE('1970-11-01', 'YYYY-MM-DD'), '345678912', 'diegoS@madrid.com');

-- Wstawianie danych do tabeli Mecz
-- Mecz_ID jest generowany automatycznie przez sekwencję
INSERT INTO Mecz (Data_meczu, Klub_Gospodarz, Klub_Gosc, Nazwa_Stadionu, Sezon_Numer_sezonu) VALUES (TO_DATE('2022-08-01', 'YYYY-MM-DD'), 'FC Barcelona', 'Real Madryt', 'Stadion Narodowy', 1);
INSERT INTO Mecz (Data_meczu, Klub_Gospodarz, Klub_Gosc, Nazwa_Stadionu, Sezon_Numer_sezonu) VALUES (TO_DATE('2022-09-01', 'YYYY-MM-DD'), 'Real Madryt', 'Atletico Madryt', 'Stadion Miejski', 1);
INSERT INTO Mecz (Data_meczu, Klub_Gospodarz, Klub_Gosc, Nazwa_Stadionu, Sezon_Numer_sezonu) VALUES (TO_DATE('2022-10-01', 'YYYY-MM-DD'), 'Atletico Madryt', 'FC Barcelona', 'Stadion Śląski', 1);

-- Wstawianie danych do tabeli Statystyka
-- Załóżmy, że Mecz_ID ma wartości 1, 2, 3 po kolei dla powyższych wstawień
INSERT INTO Statystyka (Ilosc_bramek, Ilosc_asyst, Minuty, Zolta_kartka, Czerwona_kartka, Mecz_Mecz_ID, Zawodnik_PESEL) VALUES (1, 2, 90, 0, 0, 1, '12345678901');
INSERT INTO Statystyka (Ilosc_bramek, Ilosc_asyst, Minuty, Zolta_kartka, Czerwona_kartka, Mecz_Mecz_ID, Zawodnik_PESEL) VALUES (2, 0, 78, 1, 0, 2, '23456789012');
INSERT INTO Statystyka (Ilosc_bramek, Ilosc_asyst, Minuty, Zolta_kartka, Czerwona_kartka, Mecz_Mecz_ID, Zawodnik_PESEL) VALUES (0, 1, 85, 0, 0, 3, '34567890123');

-- Wstawianie danych do tabeli Punktacja
INSERT INTO Punktacja (Wygrane, Przegrane, Remisy, Klub_Nazwa, Sezon_Numer_sezonu) VALUES (10, 2, 5, 'FC Barcelona', 1);
INSERT INTO Punktacja (Wygrane, Przegrane, Remisy, Klub_Nazwa, Sezon_Numer_sezonu) VALUES (8, 3, 6, 'Real Madryt', 1);
INSERT INTO Punktacja (Wygrane, Przegrane, Remisy, Klub_Nazwa, Sezon_Numer_sezonu) VALUES (6, 5, 6, 'Atletico Madryt', 1);