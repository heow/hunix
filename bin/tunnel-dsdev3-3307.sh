#!/bin/bash
ssh -x -C -L 3307:localhost:3306 dsdev3 -t "figlet dsdev3 tunnel; /bin/bash -l"

