# slutprojektvt19webbserver

# Projektplan
## 1. Projektbeskrivning
Visionen och målet med uppgiften är att skapa en slags "wikihow" för spelet the division 2. Men upplägget kommer att vara lite mer likt reddit på det viset att alla användare med ett konto skall kunna lägga ut bilder tillsammans med texter vilket kan vara allt från tips till upplevelser inom spelet. Användare skall i övrigt kunna gilla och ogilla dessa inlägg. Siktar på att man skall kunna redigera sin profil d.v.s användarnamn, lösenord och ev. en profilbild. Man skall även kunna logga ut och därmed länkas tillbaka till startsidan. Projektet är likt en reddit subpage för The Division 2. 
## 2. Vyer (sidor)
Startsida: Visar namnet på webbsidan, inloggningsfält samt en länk till registrerings sida. Under allting finns de posts som nyligen lagts upp av andra användare, kan endast se vilka inlägg det är, men kan ej interagera med dessa inlägg (Kan man göra som inloggad, förklarar det längre ner). Registrering: Välj användarnamn och lösenord, vid submit, kommer man tillbaka till inloggningssidan d.v.s. startsidan. 
Logged in: ser man alla de nyaste postsen samtidigt som man själv har möjlighet att göra inlägg, gilla, ogilla och kommentera andras inlägg. Profil: Redigera användarnamn och byta lösenord. ev. kunna välja en profilbild. Failed login: Misslyckad login med länk tillbaka till startsidan. 
## 3. Funktionalitet (med sekvensdiagram)
## 4. Arkitektur (Beskriv filer och mappar)
DB mapp: mappen där databasen users.db är lagrad.
Public: img mapp: Lagrar alla bilder som användare lägger upp, ligger i public för att de skall vara tillgängliga för alla. 
Views: Lagrat alla slimfiler, index.slim: Slimkod för startsidan med ett login formulär och en länk till registrerings sidan. Printar även ut de senaste postsen. failed.slim: Sidan som användaren länkas till vid en misslyckad inloggning eller försök till att manipulera sidan. failedregister.slim: Vid registrering av ny användare kommer man hit om det användarnamn man försökar använda redan existerar. 
editprofile.slim: När man är inloggad kan man gå hit ifall man vill ändra sina inloggningsuppgifter, finns formulär med två textinputs som tar det nya lösenordet och användarnamnet samt en submit knapp när man är klar. layout.slim: Filen med DOCTYPE samt yield för att länka alla slimfilerna. 
loggedin.slim: Sidan som dyker upp när man gör en lyckad inloggning. Här finns utloggningsknapp, knapp för att gå till editprofile sidan, det finns formulär där man kan lägga ut posts med header, undertext samt bilder. Det går även att gilla posts som gjort på sidan, inklusive sina egna och man kan ta bort sina egna posts. register.slim: När utloggad är det här man registrerar sig som ny användare. 
app.rb: Filen med alla gets och posts. Här sker först en before do loop som ser till att man inte kommer åt vissa sidor utan att vara inloggad, sedan ser vi gets för alla slimfiler som är beskrivna ovan och post('/register') som kör register funktionen i model. post login kollar ifall det inskrivna lösenordet och användarnamnet stämmer överens med existerande inloggningsuppgifter i databasen.
post upload kör post funktionen från model. post logout förstör aktuell session vid logout tryck och redirectar till inloggningssidan. post like kör likesdislikes funktionen i model och redirectar till inloggade sidan (Då man endast kan gilla som inloggad). post editpro kör updatepro funktionen från model och redirectar till editprofile.slim. post del kör del_post funktionen och redirectar till inloggade sidan. error 404 redirectar till failed.slim när sidan kraschar eller får en error 404.

Model: connect funktionen är funktionen där jag skapar en variabel som öppnar databasen och gör att results_as_hash = true för att sedan kunna använda "db" i nedgående funktioner. 
I övrigt är det här jag gör funktionerna där jag kan lägga ut posts med bilder som därmed också går att ta bort, gilla och ogilla. Dessutom kan man byta inloggningsuppgifter.

## 5. (Databas med ER-diagram)
