# Star Lanes specification

Star Lanes is a game of interstellar trading for 2-4 players.

> The code doesn't actually enforce this in either direction, but it
> might bomb out for more than 4 due to array overflow. And players less
> than one is likely problematic, as well.

It takes place on a grid of squares representing the galaxy. On the grid
you can see the current companies and the space they take up.

Each player takes turns, and each turn performs:

1. A move to place a new item on the map.
2. Trades to buy and sell shares of existing companies.

The game is over when the grid is mostly filled. The player with the
highest net worth wins.

## The Companies

There are five companies that can be in existence at any one time:

* Altair Starways
* Betelgeuse, Ltd.
* Capella Freight Co.
* Denebola Shippers
* Eridani Expediters

## The Map

The map is 10 rows by 13 columns.

An example rendering from the original game:

```
                     MAP OF THE GALAXY
                    *******************
            A  B  C  D  E  F  G  H  I  J  K  L
         1  .  .  .  .  .  .  .  .  .  .  .  . 
         2  .  .  .  .  .  .  +  .  E  E  +  . 
         3  +  .  .  *  .  .  .  .  *  .  .  . 
         4  .  .  .  A  .  .  .  .  .  .  .  . 
         5  .  .  A  A  .  B  B  .  +  .  .  . 
         6  .  .  .  .  *  .  B  B  .  .  .  . 
         7  .  .  .  .  .  .  .  .  .  *  .  . 
         8  .  .  .  +  .  .  .  .  .  .  .  . 
         9  .  .  .  .  .  .  .  .  .  .  .  . 
```

Each cell of the map can exist in one of eight states:

|Character|State              |
|:-------:|:------------------|
|   `.`   |Empty space        |
|   `+`   |Unattached outpost |
|   `*`   |Star               |
|   `A`   |Altair Starways    |
|   `B`   |Betelgeuse, Ltd.   |
|   `C`   |Capella Freight Co.|
|   `D`   |Denebola Shippers  |
|   `E`   |Eridani Expediters |

There are no diagonal connections on the map; every connection is
orthogonal.

### Map Initialization

At the start of the game, the map is initialized one cell at a time.

* There is a 1:20 chance that a cell will be a star.
* There is a 19:20 chance that a cell will be empty space.

## Game Initialization

* The holdings of each player in each company is set to `0`.
* The stock price of each company is set to `100`.
* The size (number of map cells) used by each company is set to `0`.
* Each player's cash is set to `6000`.
* The [map is initialized](#map-initialization).
* Player count is obtained.
* Instructions are given if requested.
* All players are asked for their names.
* The current player (to go first) is chosen randomly.
* The current turn counter is set to `0`

> At various points in the original code, unused companies (i.e. not
> currently on the map) are recognized by a stock price of `100` or a
> size of `0`.

## Gameplay

### 1. Check Turn Counter

Increment the turn counter. If it reaches `48`, the [game is
over](#game-over).

### 2. Increment Current Player

Increment the current player number—wrap around at the number of
players.

### 3. Random Candidate Moves Selected

These moves are generally randomly chosen from empty spaces across
the map, but with limitations, below.

* All five candidate moves will be distinct from one another—no repeats.

* None of the candidate moves will currently contain anything other than
  empty space.

* If the number of distinct companies on the map is five (i.e. Altair
  Starways through Eridani Expediters are all "in use"), additional
  restrictions on the candidate moves apply. (Basically, none of the
  candidate moves should allow for the formation of a new company at
  this point, since all the companies are in-use.) These additional
  rules are:

  * If any of the neighboring cells has a company in it, **allow** the
    candidate. (This merely grows the company and doesn't create a new
    one. It might also result in a merge, which also doesn't create a
    new company.)

  * If any neighboring cell is an unassigned outpost and none of the
    rest are companies, **disallow and replace** the candidate with
    another random one (that must also obey all the rules).
   
The player will be able to select from these five choices about which
move to make.

> Implementation note: the original code chooses a candidate repeatedly
> and randomly until all the required conditions are met. If five
> candidate moves could not be found, the program would loop infinitely.
> It is suggested to take a more rugged approach, e.g. use a
> deterministic method for finding moves and end the game if enough
> cannot be found.

### 4. Player Moves

Show the current player the map, print their name, and ask for their
move.

The player may choose a move directly, or also ask to see the map or
their stock holdings at this point. After viewing the map or holdings,
they'll be prompted again to move.

### 5. Update Map Phase 1

If the player's move is surrounded by empty space, it becomes an
unaffiliated outpost. Jump to [Pay Dividends](#7-pay-dividends).

If any neighbors are companies that are not the same, perform a
[merge](#merge). Jump to [Pay Dividends](#7-pay-dividends).

If any neighbor is a company, grow the company:

* Increment the size of the company by `1`.
* Increment the stock value by `100`.
* Jump to [Update Map Phase 2](#6-update-map-phase-2).

If any neighbor is a star or outpost, form a new company:

* Announce the new company.
* Award the current player `5` shares in the new company as the founder.
* Set the size of the new company to `1`
* Jump to [Update Map Phase 2](#6-update-map-phase-2).

### 6. Update Map Phase 2

For each neighbor of the selected move that is a star, add `500` to the
new-or-growing company's stock price.

For each neighbor of the selected move that is an unaffiliated outpost,
add `100` to the new-or-growing company's stock price, add `1` to its
size, and convert the outpost into the company.

If the price per share of the new-or-growing company becomes greater
than `3000`, perform a [stock split](#stock-splits).

Set the map cell at the current move to the new-or-growing company.

### 7. Pay Dividends

For each company, compute 5% of the cash value of the player's stock
holdings in that company and add the result to the player's cash
holdings.

### 8. Trade

For each company, allow the player to buy or sell stock.

The player will only be allowed to buy or sell once per company per
turn, and always in alphabetical order.

Example transcript from the original game:

```
YOUR CURRENT CASH= $ 2800 
BUY HOW MANY SHARES OF ALTAIR STARWAYS AT $ 500 
    YOU NOW OWN 27 ? 10
YOU ONLY HAVE $ 2800 - TRY AGAIN
BUY HOW MANY SHARES OF ALTAIR STARWAYS AT $ 500 
    YOU NOW OWN 27 ? 2
YOUR CURRENT CASH= $ 1800 
BUY HOW MANY SHARES OF CAPELLA FREIGHT CO. AT $ 200 
    YOU NOW OWN 5 ? 5 
YOUR CURRENT CASH= $ 800 
BUY HOW MANY SHARES OF ERIDANI EXPEDITERS AT $ 1200 
    YOU NOW OWN 12 ? 0 
```

> It is unclear if the original game meant for you to only be able to
> trade in each company once per turn. This effectively limited you if
> you wanted to sell a company higher in the alphabet to buy from one
> lower in the alphabet. You'd have to sell C this round and buy A in a
> later round. Whereas if you wanted to sell A this round, you could
> then go on to buy C this round without an issue.

Jump to [Check Turn Counter](#1-check-turn-counter).

## Merge

When the player moves into a cell that would connect two companies, a
*merge* occurs.

First, the largest neighbor company (in size, not value) is determined
in the order N,S,E,W. If there is a tie, the first largest company found
is used.

From the move cell, look around in all directions in the order N,S,E,W.
If in a particular direction you find a company that is **not** the
largest, merge it with the largest.

To do this:

* Print an announcement.

* Compute:

  * **Stock conversion:** for each player, the amount of the old stock
    in the smaller company that will be converted to stock in the
    larger.

    The conversion is 50% of the smaller stock rounded to the
    **nearest** integer.

    The converted stock is added to the player's stock for the larger
    company.

  * **Bonus:** compute the total shares outstanding for the smaller
    company by adding the total held by all players.

    For each player, compute the fraction of the total stock owned, _f_.
    And let _p_ be the smaller company price per share.

    Then that player's bonus is the following, rounded **down**:

    10 × _f_ × _p_

    The bonus is added to the player's cash holdings.

Go through the entire map and convert smaller company cells to the
larger company.

Increase the size of the larger company by that of the smaller company.

> Ideally, it would be the combined size *plus one* to account for the
> new cell from the current move, but the original game didn't do this.

Add the stock price of the smaller company onto the stock price of the
larger company.

Perform a [stock split](#stock-splits) on the combined company, if
necessary.

Set the map cell at the current move to the combined company.

## Stock Splits

A *stock split* occurs when a company's value exceeds `3000`.

The value of the company's shares is cut in half, rounding down.

Each player's number of shares in the company doubles.

## Game Over

When the turn counter reaches 48, the game is over.

Print a summary.

Player net worth is their cash plus the value of their stock holdings.

Player with the highest net worth is the winner.

Optionally play again.

## Additional Rules

If there are not enough available moves to form five candidate moves,
the original game entered an infinite loop. This is not recommended in
real life, and the game should be over at this point.

If we progress to the point where we wish to make a new company (either
by moving next to an outpost or a star), but there are no companies
available, an outpost is placed at the player's move, instead. This
should not be possible (the candidate move should have been disallowed),
but there is code in the original game to handle it.

## Example Output

Vertical and horizontal whitespace has been preserved. Newline count
includes the last line of printable characters.

### Setup

Space at the top is a form-feed followed by three newlines.

```




         * S * T * A * R ** L * A * N * E * S *
HOW MANY PLAYERS (2-4)? 2
DOES ANY PLAYER NEED INSTRUCTIONS? N
PLAYER 1 WHAT IS YOUR NAME? ALICE
PLAYER 2 WHAT IS YOUR NAME? BOB

NOW I WILL DECIDED WHO GOES FIRST...

BOB IS THE FIRST PLAYER TO MOVE.
```

### Map and Moves

Whitespace at top is a form-feed followed by one newline.

Each cell is straddled by a space on either side; as such, each row 1-9
ends in a single space.

Map ends with no newline. Legal move list starts with two newlines.

```


                     MAP OF THE GALAXY
                    *******************
            A  B  C  D  E  F  G  H  I  J  K  L
         1  .  .  .  .  .  .  .  .  .  .  *  . 
         2  .  .  .  .  .  .  .  .  .  .  .  + 
         3  .  .  .  .  .  .  .  .  .  +  .  . 
         4  *  .  .  +  .  .  .  .  .  .  .  . 
         5  .  .  .  .  .  .  +  .  .  .  *  . 
         6  .  .  .  .  .  .  .  .  .  .  .  . 
         7  A  A  .  .  .  .  .  .  .  .  .  . 
         8  .  .  .  .  .  .  .  .  .  .  .  . 
         9  .  +  .  .  *  .  .  .  .  .  .  . 

ALICE, HERE ARE YOUR LEGAL MOVES FOR THIS TURN:
 7 D / 9 G / 8 I / 6 A / 7 J /
WHAT IS YOUR MOVE?
```

### New Company

```
                     SPECIAL ANNOUNCEMENT!!

A NEW SHIPPING COMPANY HAS BEEN FORMED!
IT'S NAME IS ALTAIR STARWAYS






```

### Trading

```
YOUR CURRENT CASH= $ 6450
BUY HOW MANY SHARES OF ALTAIR STARWAYS AT $ 600
    YOU NOW OWN 5 ? -3
YOUR CURRENT CASH= $ 8250
BUY HOW MANY SHARES OF BETELGEUSE, LTD. AT $ 600
    YOU NOW OWN 0 ? 4
YOUR CURRENT CASH= $ 5850
BUY HOW MANY SHARES OF CAPELLA FREIGHT CO. AT $ 600
    YOU NOW OWN 5 ? 5
```

### Merging

```
                     SPECIAL ANNOUNCEMENT!!

BETELGEUSE, LTD. HAS JUST BEEN MERGED INTO CAPELLA FREIGHT CO.!
PLEASE NOTE THE FOLLOWING TRANSACTIONS.

   OLD STOCK = BETELGEUSE, LTD.       NEW STOCK = CAPELLA FREIGHT CO.

PLAYER   OLD STOCK   NEW STOCK   TOTAL HOLDINGS     BONUS PAID
ALICE     5           3           3                  $ 3333
BOB       4           2           12                 $ 2666





```

### Display Holdings

When you'd hit `S` during the trade phase.

Whitespace at top is a form-feed followed by two newlines.

```



STOCK                        PRICE PER SHARE     YOUR HOLDINGS
ALTAIR STARWAYS               600                 2
CAPELLA FREIGHT CO.           1400                12
```

### Stock Split

Whitespace at bottom is six newlines.

```
                     SPECIAL ANNOUNCEMENT!!

THE STOCK OF ALTAIR STARWAYS HAS SPLIT 2 FOR 1!





```

### End of Game

```
                     SPECIAL ANNOUNCEMENT!!

THE GAME IS OVER - HERE ARE THE FINAL STANDINGS

PLAYER   CASH VALUE OF STOCK    CASH ON HAND     NET WORTH

ALICE    $ 6260                 $ 2380           $ 8640
BOB      $ 10300                $ 87             $ 10387
ANOTHER GAME? 
```

### Instructions

```

   STAR LANES IS A GAME OF INTERSTELLAR TRADING.
THE OBJECT OF THE GAME IS TO AMASS THE GREATEST AMOUNT
OF MONEY. THIS IS ACCOMPLISHED BY ESTABLISHING VAST,
INTERSTELLAR SHIPPING LANES, AND PURCHASING STOCK IN
THE COMPANIES THAT CONTROL THOSE TRADE ROUTES. DURING
THE COURSE OF THE GAME, STOCK APPRECIATES IN VALUE AS
THE SHIPPING COMPANIES BECOME LARGER. ALSO, SMALLER
COMPANIES CAN BE MERGED INTO LARGER ONES, AND STOCK
IN THE SMALLER FIRM IS CONVERTED INTO STOCK IN THE 
LARGER ONE AS DESCRIBED BELOW.

   EACH TURN, THE COMPUTER WILL PRESENT THE PLAYER WITH
FIVE PROSPECTIVE SPACES TO OCCUPY ON A 9X12 MATRIX
(ROWS 1-9, COLUMNS A-L). THE PLAYER, AFTER EXAMINING
THE MAP OF THE GALAXY TO DECIDE WHICH SPACE HE WISHES
TO OCCUPY, RESPONDS WITH THE ROW AND COLUMN OF THAT
SPACE, I.E., 7E, 8A, ETC. THERE ARE FOUR POSSIBLE
MOVES A PLAYER CAN MAKE.

   1. HE CAN ESTABLISH AN UNATTACHED OUTPOST- IF HE
SELECTS A SPACE THAT IS NOT ADJACENT TO A STAR, ANOTHER
UNATTACHED OUTPOST, OR AN EXISTING SHIPPING LANE, THIS
SPACE WILL BE DESIGNATED WITH A '+'. HE WILL THEN PROCEED
WITH STOCK TRANSACTIONS, AS LISTED BELOW.

   2. HE CAN ADD TO AN EXISTING LANE- IF HE SELECTS A SPACE
WHICH IS ADJACENT TO ONE - AND ONLY ONE EXISTING SHIPPING
LANE, THE SPACE HE SELECTS WILL BE ADDED TO THAT SHIPPING
LANE, AND WILL BE DESIGNATED WITH THE FIRST LETTER OF 
THE COMPANY THAT OWNS THAT LANE. IF THERE ARE ANY STARS
OR UNATTACHED OUTPOSTS ALSO ADJACENT TO THE SELECTED SPACE,
THEY, TOO, WILL BE INCORPORATED INTO THE EXISTING LANE.
EACH NEW SQUARE ADJACENT TO A STAR ADDS $500 PER SHARE, AND
EACH NEW OUTPOST ADDS $100 PER SHARE TO THE MARKET VALUE
OF THE STOCK OF THAT SHIPPING COMPANY.

   3. HE MAY ESTABLISH A NEW SHIPPING LANE- IF THERE
ARE FIVE OR LESS EXISTING SHIPPING LANES ESTABLISHED,
THE PLAYER MAY, GIVEN THE PROPER SPACE TO PLAY, ESTABLISH
A NEW SHIPPING LANE. HE MAY DO THIS BY OCCUPYING A SPACE
ADJACENT TO A STAR OR ANOTHER UNATTACHED OUTPOST, BUT 
NOT ADJACENT TO AN EXISTING SHIPPING LANE. IF HE 
ESTABLISHES A NEW SHIPPING LANE, HE IS AUTOMATICALLY
ISSUED 5 SHARES IN THE NEW COMPANY AS A REWARD. HE
MAY THEN PROCEED TO BUY STOCK IN THAT COMPANY, OR ANY
OTHER ACTIVE COMPANY, AS DESCRIBED BELOW. THE MARKET 
VALUE OF THE NEW STOCK IS ESTABLISHED BY THE NUMBER OF
STARS AND OCCUPIED SPACES AS DESCRIBED IN #2 ABOVE.

   4. HE MAY MERGE TWO EXISTING COMPANIES- IF PLAYER
SELECTS A SPACE ADJACENT TO TWO EXISTING SHIPPING
LANES, A MERGER OCCURS. THE LARGER COMPANY TAKES OVER
THE SMALLER COMPANY, THE STOCK OF THE LARGER COMPANY IS
INCREASED IN VALUE ACCORDING TO THE NUMBER OF SPACES AND
STARS ADDED TO ITS LANE, EACH PLAYER'S STOCK IN THE
SMALLER COMPANY IS EXCHANGED FOR SHARES IN THE LARGER
ON A RATIO OF 2 SHARES OF THE SMALLER = 1 SHARE OF THE
LARGER. ALSO, EACH PLAYER IS PAID A CASH BONUS PROPORTIONAL
TO THE PERCENTAGE OF OUTSTANDING STOCK HE HELD IN THE
SMALLER COMPANY. NOTE: AFTER A COMPANY BECOMES DEFUNCT
THROUGH THIS MERGER PROCESS, IT CAN REAPPEAR ELSEWHERE
ON THE BOARD IF A NEW COMPANY IS ESTABLISHED (SEE #3 ABOVE)

   NEXT THE COMPUTER ADDS STOCK DIVIDENDS TO THE
PLAYER'S CASH ON HAND (5% OF THE MARKET VALUE OF THE 
STOCK IN HIS POSSESSION), AND OFFERS HIM THE OPPORTUNITY TO
PURCHASE STOCK IN ANY OF THE ACTIVE COMPANIES ON THE
BOARD. STOCK MAY NOT BE SOLD, BUT THE MARKET VALUES OF
EACH PLAYER'S STOCK IS TAKEN INTO ACCOUNT AT THE END
OF THE GAME TO DETERMINE THE WINNER. IF THE MARKET VALUE
OF A GIVEN STOCK EXCEEDS $3000 AT ANY TIME DURING THE 
GAME, THAT STOCK SPLITS TWO FOR ONE. THE PRICE IS CUT
IN HALF, AND THE NUMBER OF SHARES OWNED BY EACH PLAYER
IS DOUBLED.

NOTE: THE PLAYER MAY LOOK AT HIS PORTFOLIO AT ANY TIME
DURING THE COURSE OF HIS TURN BY RESPONDING WITH 'STOCK'
TO AN INPUT STATEMENT. LIKEWISE, HE CAN REVIEW THE MAP
OF THE GALAXY BY TYPING 'MAP' TO AN INPUT STATEMENT.

GAME ENDS AFTER 48 MOVES. PLAYER WITH THE GREATEST
NET WORTH AT THAT POINT IS THE WINNER.


```

## Altair BASIC Notes

Code was originally for an Altair, and was in all caps. Formfeeds were
used to "clear the screen" at various points in the code.

When printing, semicolons cause neighboring arguments to appear
immediately adjacent to one another. A semicolon at the end of a line
prevents a newline. Spaces (or no space) between arguments is just like
a semicolon.

Exception: when printing numbers, a number is **always** followed by a
space, and positive number are **always** preceded by a space.

The `TAB` function moves the cursor to the specified column (1-based)
and continues printing there.

## Modern Implementation Notes

Some potential options to the core logic:

* Solo mode
* Computer players
* Network play
* Different size maps
* Bug fix for computing the size of a company after a merge, OB1
* Allow stock trades to be done in any order, not just alphabetical
* Better candidate move logic that can't infinite loop
  * Just end the game if there's no room for all candidates
* Variable number of candidates
* Black holes that add `-500` value to a company
  * If the company falls below `0` price per share, the entire thing is
    eaten up
* End the game when a certain percentage of the map is full, not just on
  move count.

