Server = {
	ready = false,
}

Tr = {
    Spawns = {
        requestTrain = {
            name = "requestTrain",
            coords = vector3(773.37927246094, -2480.880859375, 20.290090560913),
            distance = 1.5,
            isZone = true,
            label = "Train",
            params = {fnc = "RequestTrainSpawn"},
            keyMap = {
                event = "plouffe_trainrobbery:onZone",
                key = "E"
            },
            ped = {
                coords = vector3(773.37927246094, -2480.880859375, 20.290090560913),
                heading = 262.33096313477,
                model = 'ig_marnie',
            }
        }
    },

    Loots = {
        hei_prop_carrier_cargo_01a = {
            {name = "weapon_smg"},
            {name = "weapon_assaultsmg"},
            {name = "weapon_compactrifle"},
            {name = "weapon_smg_mk2"},
            {name = "weapon_machinepistol"},
            {name = "weapon_appistol"},
            {name = "weapon_combatpdw"},
            {name = "weapon_minismg"},
            {name = "weapon_pistol50"},
            {name = "weapon_heavypistol"},
            {name = "weapon_revolver"},
            {name = "weapon_revolver_mk2"},
            {name = "weapon_doubleaction"}
        },

        hei_prop_carrier_cargo_05b_s = {
            {name = "weapon_microsmg"},
            {name = "weapon_appistol"},
            {name = "weapon_combatpdw"},
            {name = "weapon_minismg"},
            {name = "weapon_pistol50"},
            {name = "weapon_heavypistol"},
            {name = "weapon_revolver"},
            {name = "weapon_revolver_mk2"},
            {name = "weapon_doubleaction"}
        },

        hei_prop_carrier_cargo_05a = {
            {name = "weapon_appistol"},
            {name = "weapon_minismg"},
            {name = "weapon_pistol50"},
            {name = "weapon_heavypistol"},
            {name = "weapon_revolver"},
            {name = "weapon_revolver_mk2"},
            {name = "weapon_doubleaction"}
        }
    }
}

if GetResourceState("ooc_core") == "started" then
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
            {name = "WEAPON_SCORPIONEVO"},
            {name = "WEAPON_GLOCK19X2"},
            {name = "WEAPON_BROWNING"},
            {name = "WEAPON_DP9"},
            {name = "WEAPON_P320B"},
            {name = "WEAPON_M45A1"}
        }
    }
end