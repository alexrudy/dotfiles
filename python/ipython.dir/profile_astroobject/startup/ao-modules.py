#
#  ao-modules.py
#  profile_astroobject
#
#  Created by Alexander Rudy on 2012-09-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
#
import AstroObject as AO
import AstroObject.image as AImg
import AstroObject.config as ACfg
import AstroObject.spectra as ASpec
import AstroObject.spectra as AASpec
import AstroObject.util as AUtil
from AstroObject.iraftools import UseIRAFTools
ImageStack = UseIRAFTools(AImg.ImageStack)
