#!/bin/bash

# skel.sh
# Creates the skeleton directory structure which is used to store all of the
# data about a sudoku puzzle -- values, possibilities, and relationships

# by-cell/
#   (a-i)(1-9)/
#     val
#     poss
#     row -> to row in by-row
#     col -> to col in by-col
#     cube -> to cube in by-cube
# by-row
#   (1-9)/
#     <cell> -> to cell in by-cell
# by-col
#   (a-i)/
#     <cell> -> to cell in by-cell
# by-cube
#   (a-c)(1-3)/
#     <cell> -> to cell in by-cell

PID=$$
WORK="/tmp/sudoku.${PID}"

bail () {
  code=${1-1} # First arg, or 1
  shift
  message=${@-}

  echo $message >&2
  rm -rf $WORK
  exit $code
}

mkdir $WORK || bail 3 "Couldn't create ${WORK}"
cd $WORK

# by-cell contains a dir for each cell: (a-i)(1-9)
echo "Building cells..."
mkdir by-cell
cd by-cell
mkdir {a..i}{1..9}
cd ..

# by-row contains a dir for each row: 1-9
echo "Building rows..."
mkdir by-row
cd by-row
for row in {1..9}; do
  mkdir $row
  cd $row
  for col in {a..i}; do
    # Link from row to cell / parent -> child
    ln -s $WORK/by-cell/${col}${row}
    # Link from cell back to row / child -> parent
    ln -s $WORK/by-row/${row} ${col}${row}/row
  done
  cd ..
done
cd ..

# by-col contains a dir for each col: a-i
echo "Building columns..."
mkdir by-col
cd by-col
for col in {a..i}; do
  mkdir $col
  cd $col
  for row in {1..9}; do
    # Link from col to cell / parent -> child
    ln -s $WORK/by-cell/${col}${row}
    # Link from cell back to col / child -> parent
    ln -s $WORK/by-col/${col} ${col}${row}/col
  done
  cd ..
done
cd ..

# by-cube contains a dir for each cube: (a-c)(1-3)
echo "Building cubes..."
mkdir by-cube
cd by-cube
for cuberow in {1..3}; do
  for cubecol in {a..c}; do
    mkdir ${cubecol}${cuberow}
    cd ${cubecol}${cuberow}

    rows=""
    cols=""

    if [[ $cuberow == 1 ]]; then
      rows=$(echo {1..3})
    elif [[ $cuberow == 2 ]]; then
      rows=$(echo {4..6})
    elif [[ $cuberow == 3 ]]; then
      rows=$(echo {7..9})
    fi

    if [[ $cubecol == "a" ]]; then
      cols=$(echo {a..c})
    elif [[ $cubecol == "b" ]]; then
      cols=$(echo {d..f})
    elif [[ $cubecol == "c" ]]; then
      cols=$(echo {g..i})
    fi

    for row in $rows; do
      for col in $cols; do
        ln -s $WORK/by-cell/${col}${row}
        ln -s $WORK/by-cube/${cubecol}${cuberow} ${col}${row}/cube
      done
    done
    cd ..
  done
done
echo "Done. Root of work dir is $WORK"
