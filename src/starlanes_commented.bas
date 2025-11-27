REM Variables
REM
REM Everything is 1-based unless otherwise specified.
REM
REM B(I)     Cash in bank of each player
REM D1(5)    Total stock value of each player (used only in game over code)
REM I        Temporary: current player number, candidate move number
REM K        Current turn (initialized to 0)
REM M$(5)    Company names
REM M$       Characters A-L for map column labels
REM M(10,13) The map, 10 rows, 13 columns
REM N$(5)    Unknown. Maybe a typo.
REM P        Current player number
REM P$(I)    Player names
REM P1       Total number of players
REM Q(5)     Number of spaces occupied by company I
REM R(5)     Candidate space rows
REM C(5)     Candidate space columns
REM R$       Temporary: hold player response to question
REM S1(5)    Stock price per company
REM S(5,4)   Stock holdings S(company, player)
REM
REM Map Values
REM
REM 1: Empty Space
REM 2: Unattached outpost
REM 3: Star
REM 4: Company 1 (A)
REM 5: Company 2 (B)
REM 6: Company 3 (C)
REM 7: Company 4 (D)
REM 8: Company 5 (E)
REM
REM Company Names
REM
REM 1: ALTAIR STARWAYS
REM 2: BETELGEUSE, LTD.
REM 3: CAPELLA FREIGHT CO.
REM 4: DENEBOLA SHIPPERS
REM 5: ERIDANI EXPEDITERS
REM
REM Game over
REM 
REM The game ends when the current turn reaches 48.
REM
REM Lines
REM 
REM 70 New game initialization
REM 200 Main loop start
REM 680 New shipping company formed
REM 700 detect stars nearby company and increase price
REM 800 Add dividends to current player
REM 1000 Subroutine: Print map
REM 1060 Subroutine: Merge two (param A1-A4 are surrounding map values)
REM 1180 Subroutine: Merge announcement (param X=mergee, T1= merger)
REM 1400 Subroutine: Stock split (param T1 is the company number)
REM 1440 Subroutine: Show stock prices and holdings of current player
REM 7900 Subroutine: Special announcement banner
REM 9500 Routine: Game over

10 REM THE GAME OF STAR LANES - AN INTERSTELLAR COMMERCE GAME
20 REM FOR 2-4 PLAYERS - COPYRIGHT 1977 BY STEVEN FABER
30 REM WRITTEN IN ALTAIR BASIC 12/17/76

REM Print title
REM CHR$(12) is formfeed

40 PRINT CHR$(12): PRINT: PRINT: PRINT TAB(10)"* S * T * A * R **";
50 PRINT " L * A * N * E * S *"

REM Array dimensions
REM
REM Is `N$` a typo in the source listing? Should it be `M$`? The Osborne
REM version also has `N$`, but it doesn't appear anywhere else in the
REM source.

60 DIM M(10,13), S(5,4), N$(5), D1(5), S1(5), Q(5)

REM Initialize company names and ???

70 M$(5) = "ERIDANI EXPEDITERS": FOR I=1 TO 5: FOR J=1 TO 4: S(I,J)=0
75 D1(I) = 0: S1(I) = 100: Q(I) = 0: B(I) = 6000: NEXT J,I
80 M$(3) = "CAPELLA FREIGHT CO.": M$(4) = "DENEBOLA SHIPPERS"
90 M$(1) = "ALTAIR STARWAYS": M$(2) = "BETELGEUSE, LTD."

REM Populate map
REM
REM There's a 1/20 chance that space will be a star, else it's empty
REM space.

100 L$ = ".+*ABCDE": M$ = "ABCDEFGHIJKL": FOR I=1 TO 9: FOR J=1 TO 12
110 IF INT(RND(1)*20)+1 <> 10 THEN M(I,J) = 1: GOTO130
120 M(I,J) = 3

REM Get player count and ask about instructions

130 NEXT J,I: INPUT "HOW MANY PLAYERS (2-4)";P1
140 INPUT "DOES ANY PLAYER NEED INSTRUCTIONS";R$
150 IF LEFT$(R$,1) = "Y" THEN GOSUB 8000

REM Get player names

160 FOR I=1 TO P1: PRINT"PLAYER";I;: INPUT "WHAT IS YOUR NAME";P$(I)

REM Choose first player

170 NEXT I: PRINT: PRINT "NOW I WILL DECIDED WHO GOES FIRST...": PRINT
180 I = INT(P1*RND(1)+1): PRINT P$(I);" IS THE FIRST PLAYER TO MOVE."

REM Current turn to 0, current player to first chosen player, then jump
REM over end of game check and incrementing current player number.

185 K = 0
190 P = I: GOTO 220

REM *MAIN LOOP START*
REM
REM Check for game over.

200 K = K + 1: IF K = 48 THEN 9500

REM Incremement player count, wrapping around.

210 P = P + 1: IF P = P1 + 1 THEN P = 1

REM Choose 5 unique, empty sites (row, column) as candidate moves. Line
REM 240 verifies uniqueness. Line 250 verifies emptiness.

220 FOR I = 1 TO 5
230 R(I) = INT(9*RND(1)+1): C(I) = INT(12*RND(1)+1)
240 FOR I1 = I-1 TO 0 STEP -1: IF R(I) = RI(I1) AND C(I) = C(I1) THEN 230
250 NEXT I1: IF M(R(I),C(I)) > 1 THEN 230

REM If the number of spaces occupied by any company is 0, we'll skip the
REM next block. This is answering the question, "Are there any companies
REM not in use that we can form?"
REM
REM If the answer is no, the player cannot be given a candidate location
REM that would form a new company. The subsequent blocks of code verify
REM that the candidate location would *not* form a new company.
REM
REM Jumping to 340 means we'll allow the candidate for now.

260 FOR I1 = 1 TO 5: IF Q(I1) = 0 THEN 340

REM At this point, there are no companies available, so we can't be
REM allowed to form a new one. But if up, down, left, or right of the
REM candidate has a company in it, then this will just add to an
REM existing company (or merge), and so we'll allow the candidate for
REM now.

270 NEXT I1: IF M(R(I),C(I)+1) > 3 OR M(R(I),C(I)-1) > 3 THEN 340
280 IF M(R(I)+1,C(I)) > 3 OR M(R(I)-1),C(I)) > 3 THEN 340

REM Look at the map in 4 directions from the candidate
REM
REM      A4
REM   A2    A1
REM      A3

290 A1 = M(R(I),C(I)+1): A2 = M(R(I),C(I)-1)
300 A3 = M(R(I)+1,C(I)): A4 = M(R(I)-1,C(I))

REM If one direction is an outpost and the rest are not companies, then
REM this would form a company. Discard it and try again. (If it's an
REM outpost and another neighbor *is* a company, both the new cell and
REM outpost would be merged into the existing company.)

310 IF A1 = 2 AND A2 < 4 AND A3 < 4 AND A4 < 4 THEN 230
315 IF A2 = 2 AND A1 < 4 AND A3 < 4 AND A4 < 4 THEN 230
320 IF A3 = 2 AND A1 < 4 AND A2 < 4 AND A4 < 4 THEN 230
325 IF A4 = 2 AND A1 < 4 AND A2 < 4 AND A3 < 4 THEN 230
330 IF A1 = 3 AND A2 < 4 AND A3 < 4 AND A4 < 4 THEN 230
332 IF A2 = 3 AND A1 < 4 AND A3 < 4 AND A4 < 4 THEN 230
335 IF A3 = 3 AND A1 < 4 AND A2 < 4 AND A4 < 4 THEN 230
337 IF A4 = 3 AND A1 < 4 AND A2 < 4 AND A3 < 4 THEN 230

REM Print the map and player name

340 NEXT I: GOSUB 1000:PRINT :PRINT P$(P);

REM Show legal moves (columns are shown "A" through "L")

350 PRINT", HERE ARE YOUR LEGAL MOVES FOR THIS TURN:"
360 FOR I=1 TO 5: PRINT R(I);MID$(M$,C(I),1);" /";:NEXT I: PRINT

REM Get move, special case "M" for showing the map and "S" the score.

370 INPUT"WHAT IS YOUR MOVE";R$:IFLEFT$(R$,1)="M"THENGOSUB1000:GOTO350
372 IFLEFT$(R$,1)="S"THENGOSUB1440:GOTO350

REM Get the entered row and column, converting the column to an index.
REM Check that the entered r,c is in the candidate list.

375 R = VAL(LEFT$(R$,1))
380 C = ASC(RIGHT$(R$,1)) - 64: FOR I=1 TO 5: IF R=R(I) AND C=C(I) THEN 400
390 NEXT I: PRINT"THAT SPACE WAS NOT INCLUDED IN THE LIST...": GOTO 370

REM Look at the map in 4 directions from the move (different than the
REM last time)
REM
REM      A1
REM   A4    A3
REM      A2

400 A1 = M(R-1,C): A2 = M(R+1,C): A3 = M(R,C+1): A4 = M(R,C-1)

REM If the move is surrounded by empty space, it becomes an outpost and
REM we're done. (Why <= 1 and not just =1? Are spaces ever
REM non-positive???)

410 IF A1 <= 1 AND A2 <= 1 AND A3 <= 1 AND A4 <= 1 THEN M(R,C) = 2: GOTO800

REM If any pair of directions are companies that are NOT the same, check
REM for a merge.

420 IF A1 > 3 AND A2 > 3 AND A2 <> A1 THEN GOSUB 1060
430 IF A1 > 3 AND A3 > 3 AND A3 <> A1 THEN GOSUB 1060
440 IF A1 > 3 AND A4 > 3 AND A4 <> A1 THEN GOSUB 1060
450 IF A2 > 3 AND A3 > 3 AND A3 <> A2 THEN GOSUB 1060
460 IF A2 > 3 AND A4 > 3 AND A4 <> A2 THEN GOSUB 1060
470 IF A3 > 3 AND A4 > 3 AND A4 <> A3 THEN GOSUB 1060

REM If there are no companies in any direction, then skip the next
REM block???

480 IF A1 < 4 AND A2 < 4 AND A3 < 4 AND A4 < 4 THEN 660

REM If there is already a company at this location, skip to scoring???
REM How can this ever happen???

490 IF M(R,C) > 3 THEN 800

REM Assign `I` the company number in the given direction. Note that
REM later directions will overwrite previously-assigned values of `I`.

500 IF A1 > 3 THEN I = A1-3
510 IF A2 > 3 THEN I = A2-3
520 IF A3 > 3 THEN I = A3-3
530 IF A4 > 3 THEN I = A4-3

REM Increment the number of spaces occupied by the company in Q(I).
REM Add 100 to the stock price of the company in S1(I).
REM Set the map in at the current move to the same company.
REM Jump ahead to star detection (700)

540 Q(I) = Q(I) + 1: S1(I) = S1(I) + 100: M(R,C) = I+3: GOTO 700

REM If there are any available companies, skip the next line and form a
REM new company

660 FOR I=1 TO 5: IF Q(I) = 0 THEN 680

REM If the map at the move is empty space or an outpost (how could
REM it be an outpost???), make it an outpost. Almost redundant with line
REM 410 excepts allows for outposts to overwrite existing outposts.

670 NEXTI: IF M(R,C) < 3 THEN M(R,C) = 2: GOTO 800

REM Notify that a new shipping company has been formed (at index `I`).
REM Give the founding player (current player, in `P`) 5 shares in that
REM company. Set the size of the company to 1. (The size will increase
REM during the merge phase???) (Why not set the size to 5 immediately,
REM why add???)

680 GOSUB 7900: PRINT "A NEW SHIPPING COMPANY HAS BEEN FORMED!"
690 PRINT "IT'S NAME IS ";M$(I): S(I,P) = S(I,P) + 5: Q(I) = 1
695 PRINT: PRINT: PRINT: PRINT: PRINT

REM If there is a star in any direction, add 500 to the stock price for
REM the new company.

700 IF A1=3 THEN S1(I) = S1(I) + 500
710 IF A2=3 THEN S1(I) = S1(I) + 500
720 IF A3=3 THEN S1(I) = S1(I) + 500
730 IF A4=3 THEN S1(I) = S1(I) + 500

REM Any outposts next to the new company add 100 to the stock value and
REM add 1 to the company size. Also, the outpost is converted to the new
REM company on the map.

740 IF A1=2 THEN S1(I) = S1(I) + 100: Q(I) = Q(I) + 1: M(R-1,C) = I + 3
750 IF A2=2 THEN S1(I) = S1(I) + 100: Q(I) = Q(I) + 1: M(R+1,C) = I + 3
760 IF A3=2 THEN S1(I) = S1(I) + 100: Q(I) = Q(I) + 1: M(R,C+1) = I + 3
770 IF A4=2 THEN S1(I) = S1(I) + 100: Q(I) = Q(I) + 1: M(R,C-1) = I + 3

REM If the stock price exceeds 3000, set parameter T1 to the company
REM index, then call the stock split code.

780 IF S1(I) >= 3000 THEN T1=I: GOSUB 1400

REM Set the selected site to the company number

790 M(R,C) = I + 3

REM Dividends: Add to the current player's bank account 5% of the value
REM of their holdings in all companies.

800 FOR I=1 TO 5: B(P) = B(P) + INT(.05 * S(I,P) * S1(I)): NEXT I

REM Loop through all companies doing buy/sell, skipping non-existent
REM companies.

810 FOR I=1 TO 5: IF Q(I) = 0 THEN 900
820 PRINT "YOUR CURRENT CASH= $";B(P)
830 PRINT "BUY HOW MANY SHARES OF ";M$(I);" AT $";S1(I): PRINT TAB(5);
840 PRINT "YOU NOW OWN";S(I,P);

REM User can enter "M" to get the map or "S" to see stock prices and
REM their holdings.

850 INPUT R3$:IF LEFT$(R3$,1) = "M" THEN R3$="": GOSUB 1000: GOTO 830
855 IF LEFT$(R3$,1) = "S" THEN R3$="": GOSUB 1440:GOTO 830

REM Get numeric value entered and check for enough cash to buy.

856 R3 = VAL(R3$): R3$ = ""
860 IF R3 * S1(I) <= B(P) THEN 880
870 PRINT "YOU ONLY HAVE $";B(P);"- TRY AGAIN": GOTO 830

REM If 0 shares requested, do nothing, else add the shares to player's
REM holdings (S(I,P)) and lower player's bank account (B(P)) by the
REM total purchase price.
REM
REM The IF guard is mathematically unnecessary.

880 IF R3=0 THEN 900
890 S(I,P) = S(I,P) + R3: B(P) = B(P) - (R3*S1(I))

REM Go back to start of main loop.

900 NEXTI:GOTO200

REM Subroutine: Print galaxy map

1000 PRINT CHR$(12): PRINT TAB(22)"MAP OF THE GALAXY"
1010 PRINT TAB(21)"*******************"
1020 PRINT TAB(12)" A  B  C  D  E  F  G  H  I  J  K  L"
1030 FOR R2=1 TO 9:PRINT TAB(9)R2;: FOR C2=1 TO 12: PRINT " ";
1040 PRINT MID$(L$,M(R2,C2),1);" ";: NEXT C2: PRINT: NEXT R2
1050 RETURN

REM Subroutine: Merge two
REM
REM Merges two companies.
REM
REM When this function is called, it has already been determined that a
REM merge is going to happen.
REM
REM Values in neighboring cells in A1-A4. Company numbers in F1-F4
REM (zero if no company is there).
REM
REM      A1             F1
REM   A4    A3       F4    F3
REM      A2             F2
REM
REM This is called multiple times for merges in the following order:
REM
REM A1 A2
REM A1 A3
REM A1 A4
REM A2 A3
REM A2 A4
REM A3 A4
REM
REM which seems weird, because it goes on to check for merges in all
REM possible directions. Are there repeated unnecessary calls???

REM Get the company numbers in neighboring cells (clamp up to zero if no
REM company is there).

1060 F1 = A1 - 3: IF F1 < 0 THEN F1 = 0
1061 F2 = A2 - 3: IF F2 < 0 THEN F2 = 0
1062 F3 = A3 - 3: IF F3 < 0 THEN F3 = 0
1063 F4 = A4 - 3: IF F4 < 0 THEN F4 = 0

REM Find the largest (size) company. This looks in order F1-F4. If there
REM is a tie for largest, the *first* company with that size becomes the
REM one under consideration, e.g. if the sizes are F1=1 F2=2 F3=2 F4=2,
REM the largest company will be F2.

1065 T = Q(F1): T1 = F1: IF Q(F2) > Q(F1) THEN T = Q(F2): T1 = F2
1070 IF Q(F3) >T THEN T = Q(F3): T1 = F3
1080 IF Q(F4) >T THEN T = Q(F4): T1 = F4

REM Repeated logic: if the company in that direction is equal to the
REM largest company, or the other space is not a company, skip to the
REM next check.
REM
REM Else set X to that company number and call the merge announcement
REM subroutine.

1090 IF F1 = T1 OR A1 < 4 THEN 1110
1100 X = F1: GOSUB 1180
1110 IF F2 = T1 OR A2 < 4 THEN 1130
1120 X = F2: GOSUB 1180
1130 IF F3 = T1 OR A3 < 4 THEN 1150
1140 X = F3: GOSUB 1180
1150 IF F4 = T1 OR A4 < 4 THEN 1170
1160 X = F4: GOSUB 1180
1170 RETURN

REM Subroutine: Merge announcement
REM
REM Also handles the update of the map and all player holdings.

REM Print the announcement and header

1180 GOSUB 7900: PRINT M$(X);" HAS JUST BEEN MERGED INTO ";
1190 PRINT M$(T1);"!": PRINT "PLEASE NOTE THE FOLLOWING TRANSACTIONS."
1200 PRINT: PRINT TAB(4)"OLD STOCK = ";M$(X);"       NEW STOCK = ";
1210 PRINT M$(T1): PRINT
1220 PRINT "PLAYER";TAB(10)"OLD STOCK";TAB(22)"NEW STOCK";TAB(34);
1230 PRINT "TOTAL HOLDINGS";TAB(53)"BONUS PAID"

REM Print each player's name, stock in mergee company, and new stock.
REM
REM New stock is old stock * 50% rounded to the nearest integer. This
REM calculation is performed repeatedly for some reason:
REM
REM   INT((.5*S(X,I))+.5)

1240 FOR I=1 TO P1: PRINT P$(I);TAB(10)S(X,I);TAB(22)INT((.5*S(X,I))+.5);

REM Print total holdings (current holdings in S(T1,I) plus computed new
REM holdings).

1250 PRINT TAB(34) S(T1,I) + INT((.5*S(X,I))+.5);

REM Add all player holdings in old company X, store in X1,

1260 X1=0:FORI1=1TOP1:X1=X1+S(X,I1):NEXTI1

REM Print bonus. Bonus is this, rounded down:
REM
REM    10 * player_holding_fraction * REM old_company_price
REM
REM player_holding_fraction is the number of shares the player held in
REM the old company divided by total shares in that company.
REM
REM This value is recomputed again later, as well.

1265 PRINTTAB(53);
1270 PRINT" $";INT(10*((S(X,I)/X1)*S1(X))):NEXTI

REM For all players
REM
REM Add converted old holdings onto remaining company.

1290 FOR I=1 TO P1: S(T1,I) = S(T1,I) + INT((.5*S(X,I))+.5)

REM And add the bonus to the bank account.

1300 B(I) = B(I) + INT(10*((S(X,I)/X1)*S1(X))): NEXTI

REM Go through the map and change all the old company cells to the new
REM company.

1310 FOR I=1 TO 9: FOR J=1 TO 12: IF M(I,J) = X+3 THEN M(I,J) = T1+3
1315 NEXT J,I

REM Recompute A1-A4, F1-F4. Is this needed later? The Osborne code omits
REM it.
REM
REM Values in neighboring cells in A1-A4. Company numbers in F1-F4
REM (zero if no company is there).
REM
REM      A1             F1
REM   A4    A3       F4    F3
REM      A2             F2

1317 A1 = M(R-1,C): A2 = M(R+1,C): A3 = M(R,C+1): A4 = M(R,C-1)
1318 F1 = A1-3: IF F1 < 0 THEN F1 = 0
1319 F2 = A2-3: IF F2 < 0 THEN F2 = 0

REM In the middle of the above computation, let's do some bookkeeping
REM and test for stock split. Seems like this would have been better ca.
REM line 1330, so I wonder if that was a typo. It's not harmful here
REM since A1-A4 and F1-F4 are further unused in this subroutine.
REM
REM Add the spaces of the old company onto the spaces of the remaining
REM company (Q(T1) and Q(X)).
REM
REM Add the stock price of the old company onto the stock price of the
REM remaining company (S1(T1 and S1(X)).
REM
REM If the new stock price of the remaining company is over 3000, do a
REM stock split.

1320 Q(T1) = Q(T1) + Q(X): S1(T1) = S1(T1) + S1(X): IF S1(T1) > 3000 THEN GOSUB 1400

REM Continuing with F3-F4:

1321 F3 = A3-3: IF F3 < 0 THEN F3=0
1322 F4 = A4-3: IF F4 < 0 THEN F4=0

REM Reset the stock price in the old company to 100, and the number of
REM spaces held to 0. For each player, set their holdings in the old
REM company to 0.

1340 S1(X) = 100: Q(X) = 0: FOR I=1 TO P1: S(X,I)=0: NEXT I
1355 PRINT:PRINT:PRINT:PRINT:PRINT

REM Set the map in the player's chosen sector to the new company.

1360 M(R,C)u = T1+3
1370 RETURN

REM Subroutine: Announce and perform stock split
REM
REM Divide the stock price of company T1 (S1(T1)) in half, rounding
REM down.
REM
REM For each player, double their holdings in that company.

1400 GOSUB 7900:PRINT "THE STOCK OF ";
1410 PRINT M$(T1);" HAS SPLIT 2 FOR 1!": S1(T1) = INT(S1(T1)/2)
1415 PRINT: PRINT: PRINT: PRINT: PRINT
1420 FOR I1 = 1 TO P1: S(T1,I1) = 2 * S(T1,I1): NEXT I1
1430 RETURN

REM Subroutine: Print holdings
REM
REM Uses the stock price of 100 as a sentinel that a company is
REM non-existent.

1440 PRINT CHR$(12): PRINT
1450 PRINT "STOCK";TAB(30)"PRICE PER SHARE";TAB(50)"YOUR HOLDINGS"

REM For each company that exists (stock price != 100), print company
REM name, price per share and current player's holdings.

1460 FOR I3 = 1 TO 5: IF S1(I3) = 100 THEN 1480
1470 PRINT M$(I3);TAB(30)S1(I3);TAB(50)S(I3,P)
1480 NEXT I3: RETURN

REM Subroutine: Special Announcement header
REM
REM Rings terminal bell, ideally.

7900 REM INSERT BELL (CNTRL G) HERE
7910 PRINT TAB(22)"SPECIAL ANNOUNCEMENT!!": PRINT
7920 RETURN

8000 PRINT: PRINT "   STAR LANES IS A GAME OF INTERSTELLAR TRADING."
8010 PRINT "THE OBJECT OF THE GAME IS TO AMASS THE GREATEST AMOUNT"
8020 PRINT "OF MONEY. THIS IS ACCOMPLISHED BY ESTABLISHING VAST,"
8030 PRINT "INTERSTELLAR SHIPPING LANES, AND PURCHASING STOCK IN"
8040 PRINT "THE COMPANIES THAT CONTROL THOSE TRADE ROUTES. DURING"
8050 PRINT "THE COURSE OF THE GAME, STOCK APPRECIATES IN VALUE AS"
8060 PRINT "THE SHIPPING COMPANIES BECOME LARGER. ALSO, SMALLER"
8070 PRINT "COMPANIES CAN BE MERGED INTO LARGER ONES, AND STOCK"
8080 PRINT "IN THE SMALLER FIRM IS CONVERTED INTO STOCK IN THE "
8090 PRINT "LARGER ONE AS DESCRIBED BELOW.": PRINT
8100 PRINT "   EACH TURN, THE COMPUTER WILL PRESENT THE PLAYER WITH"
8120 PRINT "FIVE PROSPECTIVE SPACES TO OCCUPY ON A 9X12 MATRIX"
8130 PRINT "(ROWS 1-9, COLUMNS A-L). THE PLAYER, AFTER EXAMINING"
8140 PRINT "THE MAP OF THE GALAXY TO DECIDE WHICH SPACE HE WISHES"
8150 PRINT "TO OCCUPY, RESPONDS WITH THE ROW AND COLUMN OF THAT"
8160 PRINT "SPACE, I.E., 7E, 8A, ETC. THERE ARE FOUR POSSIBLE"
8170 PRINT "MOVES A PLAYER CAN MAKE.": PRINT
8180 PRINT "   1. HE CAN ESTABLISH AN UNATTACHED OUTPOST- IF HE"
8190 PRINT "SELECTS A SPACE THAT IS NOT ADJACENT TO A STAR, ANOTHER"
8200 PRINT "UNATTACHED OUTPOST, OR AN EXISTING SHIPPING LANE, THIS"
8210 PRINT "SPACE WILL BE DESIGNATED WITH A '+'. HE WILL THEN PROCEED"
8230 PRINT "WITH STOCK TRANSACTIONS, AS LISTED BELOW.": PRINT
8240 PRINT "   2. HE CAN ADD TO AN EXISTING LANE- IF HE SELECTS A SPACE"
8250 PRINT "WHICH IS ADJACENT TO ONE - AND ONLY ONE EXISTING SHIPPING"
8260 PRINT "LANE, THE SPACE HE SELECTS WILL BE ADDED TO THAT SHIPPING"
8270 PRINT "LANE, AND WILL BE DESIGNATED WITH THE FIRST LETTER OF "
8280 PRINT "THE COMPANY THAT OWNS THAT LANE. IF THERE ARE ANY STARS"
8290 PRINT "OR UNATTACHED OUTPOSTS ALSO ADJACENT TO THE SELECTED SPACE,"
8300 PRINT "THEY, TOO, WILL BE INCORPORATED INTO THE EXISTING LANE."
8310 PRINT "EACH NEW SQUARE ADJACENT TO A STAR ADDS $500 PER SHARE, AND"
8320 PRINT "EACH NEW OUTPOST ADDS $100 PER SHARE TO THE MARKET VALUE"
8330 PRINT "OF THE STOCK OF THAT SHIPPING COMPANY.": PRINT
8340 PRINT "   3. HE MAY ESTABLISH A NEW SHIPPING LANE- IF THERE"
8350 PRINT "ARE FIVE OR LESS EXISTING SHIPPING LANES ESTABLISHED,"
8360 PRINT "THE PLAYER MAY, GIVEN THE PROPER SPACE TO PLAY, ESTABLISH"
8370 PRINT "A NEW SHIPPING LANE. HE MAY DO THIS BY OCCUPYING A SPACE"
8380 PRINT "ADJACENT TO A STAR OR ANOTHER UNATTACHED OUTPOST, BUT "
8390 PRINT "NOT ADJACENT TO AN EXISTING SHIPPING LANE. IF HE "
8400 PRINT "ESTABLISHES A NEW SHIPPING LANE, HE IS AUTOMATICALLY"
8410 PRINT "ISSUED 5 SHARES IN THE NEW COMPANY AS A REWARD. HE"
8420 PRINT "MAY THEN PROCEED TO BUY STOCK IN THAT COMPANY, OR ANY"
8430 PRINT "OTHER ACTIVE COMPANY, AS DESCRIBED BELOW. THE MARKET "
8440 PRINT "VALUE OF THE NEW STOCK IS ESTABLISHED BY THE NUMBER OF"
8450 PRINT "STARS AND OCCUPIED SPACES AS DESCRIBED IN #2 ABOVE.": PRINT
8460 PRINT "   4. HE MAY MERGE TWO EXISTING COMPANIES- IF PLAYER"
8470 PRINT "SELECTS A SPACE ADJACENT TO TWO EXISTING SHIPPING"
8480 PRINT "LANES, A MERGER OCCURS. THE LARGER COMPANY TAKES OVER"
8490 PRINT "THE SMALLER COMPANY, THE STOCK OF THE LARGER COMPANY IS"
8500 PRINT "INCREASED IN VALUE ACCORDING TO THE NUMBER OF SPACES AND"
8510 PRINT "STARS ADDED TO ITS LANE, EACH PLAYER'S STOCK IN THE"
8520 PRINT "SMALLER COMPANY IS EXCHANGED FOR SHARES IN THE LARGER"
8530 PRINT "ON A RATIO OF 2 SHARES OF THE SMALLER = 1 SHARE OF THE"
8540 PRINT "LARGER. ALSO, EACH PLAYER IS PAID A CASH BONUS PROPORTIONAL"
8550 PRINT "TO THE PERCENTAGE OF OUTSTANDING STOCK HE HELD IN THE"
8560 PRINT "SMALLER COMPANY. NOTE: AFTER A COMPANY BECOMES DEFUNCT"
8570 PRINT "THROUGH THIS MERGER PROCESS, IT CAN REAPPEAR ELSEWHERE"
8580 PRINT "ON THE BOARD IF A NEW COMPANY IS ESTABLISHED (SEE #3 ABOVE)"
8590 PRINT: PRINT "   NEXT THE COMPUTER ADDS STOCK DIVIDENDS TO THE"
8600 PRINT "PLAYER'S CASH ON HAND (5% OF THE MARKET VALUE OF THE "
8610 PRINT "STOCK IN HIS POSSESSION), AND OFFERS HIM THE OPPORTUNITY TO"
8620 PRINT "PURCHASE STOCK IN ANY OF THE ACTIVE COMPANIES ON THE"
8630 PRINT "BOARD. STOCK MAY NOT BE SOLD, BUT THE MARKET VALUES OF"
8640 PRINT "EACH PLAYER'S STOCK IS TAKEN INTO ACCOUNT AT THE END"
8650 PRINT "OF THE GAME TO DETERMINE THE WINNER. IF THE MARKET VALUE"
8660 PRINT "OF A GIVEN STOCK EXCEEDS $3000 AT ANY TIME DURING THE "
8670 PRINT "GAME, THAT STOCK SPLITS TWO FOR ONE. THE PRICE IS CUT"
8680 PRINT "IN HALF, AND THE NUMBER OF SHARES OWNED BY EACH PLAYER"
8690 PRINT "IS DOUBLED.": PRINT
8700 PRINT "NOTE: THE PLAYER MAY LOOK AT HIS PORTFOLIO AT ANY TIME"
8710 PRINT "DURING THE COURSE OF HIS TURN BY RESPONDING WITH 'STOCK'"
8720 PRINT "TO AN INPUT STATEMENT. LIKEWISE, HE CAN REVIEW THE MAP"
8730 PRINT "OF THE GALAXY BY TYPING 'MAP' TO AN INPUT STATEMENT."
8740 PRINT: PRINT"GAME ENDS AFTER 48 MOVES. PLAYER WITH THE GREATEST"
8750 PRINT "NET WORTH AT THAT POINT IS THE WINNER.": PRINT: PRINT
8760 RETURN

REM Routine: Game over

9500 GOSUB 7900: PRINT "THE GAME IS OVER - HERE ARE THE FINAL STANDINGS"
9505 PRINT
9510 PRINT "PLAYER";TAB(10)"CASH VALUE OF STOCK";TAB(33)"CASH ON HAND";
9520 PRINT TAB(50)"NET WORTH":PRINT

REM For each player, compute their stock value as the sum of all company
REM share values multiplied by their holdings.

9530 FOR I=1 TO P1: FORJ = 1 TO 5: D1(I) = D1(I) + (S1(J)*S(J,I)): NEXT J,I

REM For each player, print out stock value, cash, and net worth (stock
REM value plus cash).

9640 FOR I=1 TO P1: PRINT P$(I);TAB(10)"$";D1(I);TAB(33)"$";B(I);
9550 PRINT TAB(50)"$";D1(I) + B(I): NEXT I

REM Play again?

9560 INPUT "ANOTHER GAME";R$: IF LEFT$(R$,1) = "Y" THEN 70

REM End

