#!/bin/sh
echo "http://localhost:8888"
ssh -C -N -L 8888:localhost:80 mnn-ops@216.164.83.163