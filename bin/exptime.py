#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
#  exptime.py
#  
#  Created by Alexander Rudy on 2013-01-16.
#  Copyright 2013 Alexander Rudy. All rights reserved.
# 
from __future__ import division

import sys
import pyfits as pf

filename = sys.argv[1]

total = 0
print "Exposure times from file %r" % filename

with open(filename,'r') as stream:
    for line in stream:
        filename = line.rstrip('\n')
        # print("Opening %r" % filename)
        header = pf.getheader(filename,ignore_missing_end=True,ext=0)
        exptime = header['ITIME'] * header['COADDS']
        
        print("%20s %10s %10s : %5.2f x %2d = %6.3fs" % (filename,header['OBJECT'],header['FILTER'],header['ITIME'],header['COADDS'],exptime))
        total += exptime
        
print ("Total: %0.3fs = %d minutes" % (total,total/60))