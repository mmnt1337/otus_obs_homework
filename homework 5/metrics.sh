#!/bin/bash

m1=$(( $RANDOM % 100 + 1 ))
m2=$(( $RANDOM % 100 + 1 ))
m3=$(( $RANDOM % 100 + 1 ))

echo "{\"metric1\":\"$m1\",\"metric2\":\"$m2\",\"metric3\":\"$m3\"}"