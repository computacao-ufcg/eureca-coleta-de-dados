#!/bin/bash

cadastro=$1
cat $cadastro | grep \(GRADUADO | awk -F ";" '{ print "missing-"rand()","$3",2,"$5","$4 }' | sed -e 's,Inativo (GRADUADO ,,' | sed -e 's,)$,,' | sed -e 's.,2,[A-Z]* .,2,.'
