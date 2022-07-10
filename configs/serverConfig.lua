Auth = exports.plouffe_lib:Get("Auth")
Callback = exports.plouffe_lib:Get("Callback")
Utils = exports.plouffe_lib:Get("Utils")

Server = {
	ready = false,
}

Tr = {}

Tr.ptfx = {}

Tr.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0)
}

Tr.TrainModels = {
	"freight",
    "freightcar",
    "freightcar2",
    "freightcont1",
    "freightcont2",
    "freightgrain",
    "freighttrailer",
    "metrotrain",
    "s_m_m_lsmetro_01",
    "tankercar"
}

Tr.Loots = {
    hei_prop_carrier_cargo_01a = {
        {name = "WEAPON_MPX"},
        {name = "WEAPON_P90FM"},
        {name = "WEAPON_AKS74U"},
        {name = "WEAPON_SCARSC"},
        {name = "WEAPON_PMXFM"},
        {name = "WEAPON_GLOCK18C"},
        {name = "WEAPON_DRACO"},
        {name = "WEAPON_SCORPIONEVO"},
        {name = "WEAPON_GLOCK19X2"},
        {name = "WEAPON_BROWNING"},
        {name = "WEAPON_DP9"},
        {name = "WEAPON_P320B"},
        {name = "WEAPON_M45A1"}
    },

    hei_prop_carrier_cargo_05b_s = {
        {name = "WEAPON_MP9A"},
        {name = "WEAPON_GLOCK18C"},
        {name = "WEAPON_DRACO"},
        {name = "WEAPON_SCORPIONEVO"},
        {name = "WEAPON_GLOCK19X2"},
        {name = "WEAPON_BROWNING"},
        {name = "WEAPON_DP9"},
        {name = "WEAPON_P320B"},
        {name = "WEAPON_M45A1"}
    },

    hei_prop_carrier_cargo_05a = {
        {name = "WEAPON_GLOCK18C"},
        {name = "WEAPON_GLOCK18C"},
        {name = "WEAPON_SCORPIONEVO"},
        {name = "WEAPON_GLOCK19X2"},
        {name = "WEAPON_BROWNING"},
        {name = "WEAPON_DP9"},
        {name = "WEAPON_P320B"},
        {name = "WEAPON_M45A1"}
    }
}

Tr.Props = {
    carriage_3 = {
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_5 = {
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_6 = {
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 4.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 2.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 0.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -1.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -3.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -5.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_7 = {
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    }
}

Tr.Spawns = {

}