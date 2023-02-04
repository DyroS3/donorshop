Config = {
  __VERSION = "1.01",
  UseConsoleCommand = true,
  ShowMarker  = true,
  ShowBlip    = true,

  InsideSpawn = vector3(-1266.979,-3013.096,-48.49),
  OutsideSpawn = vector3(-1394.815,-3265.038,13.50),
  InsideTeleport = vector3(-1267.568,-3038.146,-49.450),
  OutsideTeleport = vector3(-1394.815,-3265.038,13.50),

  InsideMarker = {
    type          = 27,
    posX          = -1267.568,
    posY          = -3038.146,
    posZ          = -49.450,
    scaleX        = 2.0,
    scaleY        = 2.0,
    scaleZ        = 2.0,
    red           = 255,
    green         = 000,
    blue          = 000,
    alpha         = 155, 
    bobUpAndDown  = false,   
    faceCamera    = true,
  },

  OutsideMarker = {
    type          = 27,
    posX          = -1394.815,
    posY          = -3265.038,
    posZ          = 13.000,
    scaleX        = 2.0,
    scaleY        = 2.0,
    scaleZ        = 2.0,
    red           = 255,
    green         = 000,
    blue          = 000,
    alpha         = 155, 
    bobUpAndDown  = false,   
    faceCamera    = true,
  },

  Blip = {
    posX          = -1394.815,
    posY          = -3265.038,
    posZ          =  13.944,
    sprite        = 403,
    color         = 0,
    display       = 4,
    scale         = 0.5,
    shortRange    = true,
    highDetail    = true,
    text          = "赞助车商店",
  },
}

DonorTiers = {
  [1] = {
    vehicles = {
      {
        model = 'police',
        price = 10,
      },
    },
  },
  [2] = {
    vehicles = {
      {
        model = 'fordh',
        price = 10,
      },
      {
        model = '14r8',
        price = 10,
      },
      {
        model = 'fgt',
        price = 15,
      },
      {
        model = 'mgt',
        price = 10,
      },
      {
        model = 'ast',
        price = 15,
      },
      {
        model = 'm5f90',
        price = 20,
      },

      {
        model = 'm3e30',
        price = 10,
      },
      {
        model = '918s',
        price = 20,
      },
      {
        model = 'cayenne',
        price = 15,
      },
      {
        model = 'f1',
        price = 20,
      },

      {
        model = 'sls',
        price = 20,
      },
      {
        model = 'eleanor',
        price = 20,
      },
      {
        model = '19gt500',
        price = 15,
      },
      {
        model = 'bugatti',
        price = 20,
      },
    },
  },
  [3] = {
    vehicles = {
      {
        model = 'rmodm4gts',
        price = 20,
      },
      {
        model = 'rmodx6',
        price = 20,
      },
      {
        model = 'lhgt3',
        price = 20,
      },
      {
        model = 'zondar',
        price = 20,
      },
      {
        model = 'rmodmustang',
        price = 20,
      },
      {
        model = 'rmodgtr',
        price = 20,
      },

      {
        model = 'rmodsupra',
        price = 20,
      },
      {
        model = 'rmodmk7',
        price = 20,
      },
      {
        model = 'fxxk',
        price = 20,
      },
      {
        model = 'rmodmi8',
        price = 20,
      },

      {
        model = 'rmodm3e36',
        price = 20,
      },
      {
        model = 'rmodgt63',
        price = 20,
      },
      {
        model = 'c7r',
        price = 20,
      },
      {
        model = 'rmodrs7',
        price = 20,
      },
	  {
        model = 'apollos',
        price = 20,
      },
	  {
        model = 'rmodp1gtr',
        price = 20,
      },
	  {
        model = '911gt3r',
        price = 20,
      },
	  {
        model = 'benzsl63',
        price = 20,
      },
	  {
        model = 'acuransx',
        price = 20,
      },
    },
  },
}

mLibs = exports["meta_libs"]