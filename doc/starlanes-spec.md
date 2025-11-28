# Star Lanes specification

***Work In Progress***

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

> Pedantic note: in the original game, each row 1-9 of the map ends with
> a space character after the cell.

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

If any neighbor is a company, [grow the company](#company-growth). Jump
to [Update Map Phase 2](#6-update-map-phase-2).

If any neighbor is a star or outpost, [form a new
company](#company-formation). Jump to [Update Map Phase
2](#6-update-map-phase-2).

### 6. Update Map Phase 2

For each neighbor of the selected move that is a star, add `500` to the
new-or-growing company's stock price.

For each neighbor of the select move that is an unaffiliated outpost,
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
    YOU NOW OWN 27? 10
YOU ONLY HAVE $ 2800 - TRY AGAIN
BUY HOW MANY SHARES OF ALTAIR STARWAYS AT $ 500
    YOU NOW OWN 27? 2
YOUR CURRENT CASH= $ 1800
BUY HOW MANY SHARES OF CAPELLA FREIGHT CO. AT $ 200
    YOU NOW OWN 5? 5 
YOUR CURRENT CASH= $ 800
BUY HOW MANY SHARES OF ERIDANI EXPEDITERS AT $ 1200
    YOU NOW OWN 12? 0 
```

> It is unclear if the original game meant for you to only be able to
> trade in each company once per turn. This effectively limited you if
> you wanted to sell a company higher in the alphabet to buy from one
> lower in the alphabet. You'd have to sell C this round and buy A in a
> later round. Whereas if you wanted to sell A this round, you could
> then go on to buy C this round without an issue.

Jump to [Check Turn Counter](#1-check-turn-counter).

## Merge

TODO

## Company Formation

TODO

## Company Growth

TODO

## Stock Splits

TODO

## Game Over

TODO

## Additional Rules

If there are not enough available moves to form five candidate moves,
the original game entered an infinite loop. This is not recommended in
real life, and the game should be over at this point.

If we progress to the point where we wish to make a new company (either
by moving next to an outpost or a star), but there are no companies
available, an outpost is placed at the player's move, instead. This
should not be possible (the candidate move should have been disallowed),
but there is code in the original game to handle it.

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

## Questions

Does merging handle star and outpost bonuses?

```
.  .  .
A  x  B
.  *  .
```
