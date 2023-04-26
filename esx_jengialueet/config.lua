Config = {}
Config.Locale = 'fi'

Config.PoliceNumberRequired = 0
Config.TimerForMoneyTicks = 20 -- minutes
Config.MoneyPerTick = 666 -- tikki palkkio
Config.Valtausaika = 1000 -- Kauanko aikaa vallata
Config.ClamingCD = 1000 -- Kuinka nopeasti uusi valtaus
Config.Mitenuseinvoivallata = 0
Config.PoliisiCoolDown = 4 -- Poliisin vapauttaman alueen CD tunneissa + mitenuseinvoivallata (esim 4 + 60min)
Config.RobAnimationSeconds = 4
Config.Montakoalistetaan = 50
Config.MaxDistance    = 450 -- max distance from the robbary, going any longer away from it will to cancel the robbary
Config.GiveBlackMoney = true -- give black money? If disabled it will give cash instead.


Jobit = {
	
}
	

Areas = {
	[1] = {
		position = { x = -171.80, y = 6393.26, z = 31.67 },
		nameofarea = "Alue #1",
		nameofree = "Pohjoinen",
	},
	[2] = {
		position = { x = 1685.65, y = 3614.95, z = 35.40 },
		nameofarea = "Alue #2",
		nameofree = "Keskimaa",
	},
	[3] = {
		position = { x = 6.377, y = -1816.482, z = 25.35 },
		nameofarea = "Alue #3",
		nameofree = "Grove",
	},
	[4] = {
		position = { x = -1171.04, y = -1381.04, z = 4.96},
		nameofarea = "Alue #4",
		nameofree = "Ranta",
	},
	[5] = {
		position = { x = 1127.066, y = -471.694, z = 66.486 },
		nameofarea = "Alue #5",
		nameofree = "Mirror Park",
	},
	[6] = {
		position = { x = -174.95, y = 219.18, z = 90.02 },
		nameofarea = "Alue #6",
		nameofree = "Pohjois kaupunki",
	},
	[7] = {
		position = { x = 1701.13, y = 4865.62, z = 42.01 },
		nameofarea = "Alue #7",
		nameofree = "Grapeseed",
	},
	[8] = {
		position = { x = -1423.98, y = -249.04, z = 46.37 },
		nameofarea = "Alue #8",
		nameofree = "Lakitoimisto",
	},
	[9] = {
		position = { x = -966.88, y = -2610.95, z = 13.98 },
		nameofarea = "Alue #9",
		nameofree = "Lentokenttä",
	}

}