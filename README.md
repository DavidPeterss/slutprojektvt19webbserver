# slutprojektvt19webbserver

# Projektplan
## 1. Projektbeskrivning
Visionen och målet med uppgiften är att skapa en slags "wikihow" för spelet the division 2. Men upplägget kommer att vara lite mer likt reddit på det viset att alla användare med ett konto skall kunna lägga ut bilder tillsammans med texter vilket kan vara allt från tips till upplevelser inom spelet. Använder skall i övrigt kunna gilla, ogilla och kommentera dessa inlägg. Siktar på att man skall kunna redigera sin profil d.v.s användarnamn, lösenord och ev. en profilbild. Man skall även kunna logga ut och därmed länkas tillbaka till startsidan. Projektet är likt en reddit subpage för The Division 2. 
## 2. Vyer (sidor)
Startsida: Visar namnet på webbsidan, inloggningsfält samt en länk till registrerings sida. Under allting finns de posts som nyligen lagts upp av andra användare, kan endast se vilka inlägg det är, men kan ej interagera med dessa inlägg (Kan man göra som inloggad, förklarar det längre ner). Registrering: Välj användarnamn och lösenord, vid submit, kommer man tillbaka till inloggningssidan d.v.s. startsidan. 
Logged in: ser man alla de nyaste postsen samtidigt som man själv har möjlighet att göra inlägg, gilla, ogilla och kommentera andras inlägg. Profil: Redigera användarnamn och byta lösenord. ev. kunna välja en profilbild. Failed login: Misslyckad login med länk tillbaka till startsidan. 
## 3. Funktionalitet (med sekvensdiagram)
Fuckoff (förlåt jag menade det inte snälla ge mig ett betyg)
## 4. Arkitektur (Beskriv filer och mappar)
DB mapp: mappen där databasen är lagrad.
Public: img mapp: Lagrar alla bilder som användare lägger upp, ligger i public för att de skall vara tillgängliga för alla. 
Views: Lagrat alla slimfiler, index fil: Slimkod för startsidan med ett login formulär och en länk till registrerings sidan. Printar även ut de senaste postsen.
## 5. (Databas med ER-diagram)
