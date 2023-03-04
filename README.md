## CMBR - Chess move binary representation

---
## Chapter list
- [How does it work?](#how-does-it-work)
- [Building](#building)
- [Legal stuff](#license)
- [Feedback](#feedback)
- [Authors](#authors)
---
## How does it work

CMBR represents a chess move with a 16 bit integer hence the name "Chess move binary representation".

---

### The move it self as said uses 16 bits.

> 11 (1 1 110) 111111 011

The first 2 bits represents what the piece turned into (for promotions).

| Piece | Value |
| --- | --- |
| Knight | 00 |
| Bishop | 01 |
| Rook | 10 |
| Queen | 11 |

If not promoted, it would be left 00 and ignored

---
The next 6 bits represent the square from where the piece was moved.

The first bit indicates if it needs to be used or not. If it is set to `1` then it is used, if set to `0` then not.

The next one bit indicates it's a file or a column. `0` - Column, `1` - File. 

The last 3 bits of the 6 bit sequence is for representing the file. 
| Vertical | Value | Horizontal | Value |
| --- | --- | ---: | ---: |
| A | 1 | 1 | 1
| B | 2 | 2 | 2
| C | 3 | 3 | 3
| .... | | ... |
| H | 8 | 8 | 8 |
---

The next 6 bits represent to where the piece moved to.

This is represented with a 6 bit integer where each square is given a number 0-63

The square H8 would be 
```py
# (H-1) << 3 | 7

7 << 3 | 7
# that equals
56 | 7 # 63
```

---

The final last 3 bits are for the piece that the move was made with

| Piece name | Value |
| --- | ----------- |
| Pawn | 000 |
| Knight | 001 |
| Bishop | 010 |
| Rook | 011 |
| Queen | 100 |
| King | 101 |
| Short catles (not really a piece) | 110 |
| Long castles | 111 |

---
<br>

## Building

Clone the project

```shell
$ git clone https://github.com/datawater/cmbr
```

Go to the project directory

```shell
$ cd cmbr
```

Build the project

```shell
# For the release build
$ make release

# For the development build (not optimized, with debug info)
$ make
```
---
## License

See the license in the `LICENSE` File

[LICENSE](/LICENSE)

---

## Feedback

If you have any feedback, please reach out to me at
[datawater1@gmail.com](mailto:datawater1@gmail.com&subject=Feedback%20For%20cmbr)


Or open an issue at [https://github.com/datawater/cmbr/issues](https://github.com/datawater/cmbr/issues)

---

## Authors

- [@datawater](https://www.github.com/datawater)