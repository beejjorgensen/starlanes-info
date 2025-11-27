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

> At various points in the original code, unused companies (i.e. not
> currently on the map) are recognized by a stock price of `100` or a
> size of `0`.

## Game Over

TODO
