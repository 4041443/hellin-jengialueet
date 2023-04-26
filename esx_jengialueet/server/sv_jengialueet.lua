local claiming = {}
local robbers = {}
ESX = nil
local onkosqlpyoritetty = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function() --tehdaan table jengialueet joka jaetaan clinuille
	onkosqlpyoritetty = true
	mysqlhaku()
end)


function mysqlhaku()
  MySQL.Async.fetchAll(
    'SELECT * FROM jengialueet',
    {},
    function(result)

      jengidatatable  = {}

      for i=1, #result, 1 do
		jengidatatable[#jengidatatable+1] = { alue=result[i].alue, valtausaika=result[i].valtausaika, omistaja=result[i].omistaja, rahaa=result[i].rahaa }
      end
    end
  )
	
	Wait(1000)
	Rahaa() -- aloitetaan rahacheckit
end

RegisterCommand('Jengialueet', function (source, args, rawCommand) --omistaja lista
    local xPlayer = ESX.GetPlayerFromId(source)
    for i,v in ipairs(Jobit) do
        if xPlayer.job.name == v then
            TriggerClientEvent('esx:showNotification', source, Areas[1].nameofree..': '..jengidatatable[1].omistaja..'\n'..Areas[2].nameofree..': '..jengidatatable[2].omistaja..'\n'..Areas[3].nameofree..': '..jengidatatable[3].omistaja..'\n'..Areas[4].nameofree..': '..jengidatatable[4].omistaja..'\n'..Areas[5].nameofree..': '..jengidatatable[5].omistaja)
			TriggerClientEvent('esx:showNotification', source, Areas[6].nameofree..': '..jengidatatable[6].omistaja..'\n'..Areas[7].nameofree..': '..jengidatatable[7].omistaja..'\n'..Areas[8].nameofree..': '..jengidatatable[8].omistaja..'\n'..Areas[9].nameofree..': '..jengidatatable[9].omistaja..'\n'..Areas[10].nameofree..': '..jengidatatable[10].omistaja)
        end
    end
end)

-- extremely useful when restarting script mid-game
Citizen.CreateThread(function()
	Citizen.Wait(2000) -- hopefully enough for connection to the SQL server
	if not onkosqlpyoritetty then
		mysqlhaku()
		onkosqlpyoritetty = true
	end
end)

function Rahaa()
	local xPlayers = ESX.GetPlayers() --haetaan kaikki pelaajat
	local cops = 0
	
	for i=1, #xPlayers, 1 do -- loopataan ja katsotaan onko poliiseita
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			cops = cops + 1
		end
	end
	if cops >= Config.PoliceNumberRequired then --kurkataan onko tarpeeksi poliiseita jotta voidaan antaa rahaa
		local rahanpaska = (math.random(70, 130) * Config.MoneyPerTick / 100)
		for i = 1, #jengidatatable, 1 do 
				jengidatatable[i].rahaa = jengidatatable[i].rahaa + rahanpaska -- annetaan rahaa jos poliiseita tarpeeksi
				if jengidatatable[i].rahaa > 50000 then
					jengidatatable[i].rahaa = 0
				end
				MySQL.Async.execute(
					'UPDATE `jengialueet` SET rahaa = @rahaa WHERE alue = @alue',
					{
					['@rahaa'] = jengidatatable[i].rahaa,
					['@alue'] = jengidatatable[i].alue
					})
		end
	end
	local Randomeri = (math.random(90,110) * Config.TimerForMoneyTicks  / 100) --tikkiväli random 90-110% conf ajasta
	Randomeri = (Randomeri * 1000 * 60) --ms -> sec | sec -> mins
	SetTimeout(Randomeri, Rahaa)
end

RegisterServerEvent('esx_jengialue:paivitys') -- paivitetaan jengidatatable ja lähetetään pelaajille
AddEventHandler('esx_jengialue:paivitys', function()
  MySQL.Async.fetchAll(
    'SELECT * FROM jengialueet',
    {},
    function(result)

      jengidatatable  = {}

      for i=1, #result, 1 do
		jengidatatable[#jengidatatable+1] = { alue=result[i].alue, valtausaika=result[i].valtausaika, omistaja=result[i].omistaja, rahaa=result[i].rahaa }
      end
    end
  )
	
	Wait(1000)

    local xPlayers = ESX.GetPlayers() -- lähetetään jokaiselle paivitetty table
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('esx_jengialue:mestat', xPlayers[i], jengidatatable)
    end
end)

RegisterServerEvent('esx_jengialue:poliisille')
AddEventHandler('esx_jengialue:poliisille', function(ryostettavaalue)
  if not claiming[ryostettavaalue] then
	if jengidatatable[ryostettavaalue].omistaja == 'vapaa' then
		TriggerClientEvent('esx:showNotification', source, 'Alue on jo vapautettu!')
	else
		local xPlayers = ESX.GetPlayers()
		TriggerClientEvent('esx:showNotification', source, 'Aloitit valtaamaan aluetta')
		TriggerClientEvent('esx_jengialue:currentlyclaiming', source, ryostettavaalue)
		TriggerClientEvent('esx_jengialue:starttimer', source)
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == jengidatatable[ryostettavaalue].omistaja then
				TriggerClientEvent('esx_jengialue:setblip', xPlayers[i], ryostettavaalue)
				TriggerClientEvent('esx:showNotification', xPlayers[i], 'POLIISIT HÄÄRÄÄVÄT ALUEELLASI!!!')
				TriggerClientEvent('esx_jengialue:valloitusilmoitus', xPlayers[i], ryostettavaalue) -- testi 28.5
			end
		end
	end
else
	TriggerClientEvent('esx:showNotification', source, 'Alueella on jo hämärää toimintaa menossa')
	end
end)

RegisterServerEvent('esx_jengialue:rahatpois') -- rahojen nosto
AddEventHandler('esx_jengialue:rahatpois', function(area)
	if jengidatatable[area].rahaa > 0 then -- tarkistetaan onko rahaa kertynyt yhtään
		local award = jengidatatable[area].rahaa -- tallennetaan annettavat rahat
		jengidatatable[area].rahaa = 0 -- databaseen nollataan rahat koska nostettu. 26.5 KORJATTU HOX oli "0" vaihdettu 0
		MySQL.Async.execute(
		'UPDATE `jengialueet` SET rahaa = @rahaa WHERE alue = @alue',
		{
		['@rahaa'] = 0,
		['@alue'] = area
		})
			
		xPlayer.addMoney(award)
		TriggerClientEvent('esx:showNotification', source, 'Sait suojelurahaa: ' .. award)
		TriggerEvent('jengialue', GetPlayerName(source).." Keräsi suojelusrahaa " ..award.."€")
	else
		TriggerClientEvent('esx:showNotification', source, 'Suojelurahaa ei ole vielä ehtinyt kertymään')
	end
end)

RegisterServerEvent('esx_jengialue:fetchmestat') --clinulle aluetiedot
AddEventHandler('esx_jengialue:fetchmestat', function()
	TriggerClientEvent('esx_jengialue:mestat', source, jengidatatable)
end)

RegisterServerEvent('esx_jengialue:toofar')
AddEventHandler('esx_jengialue:toofar', function(robb)
	local _source = source
	local testihomma = robb
	TriggerClientEvent('esx_jengialue:toofarlocal', _source)
	TriggerClientEvent('esx:showNotification', _source, 'Valtaus epäonnistui!')
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == jengidatatable[robb].omistaja then
			TriggerClientEvent('esx:showNotification', xPlayers[i], 'Aluettasi ei saatu vallattua!')
			TriggerClientEvent('esx_jengialue:killblip', xPlayers[i], robb)
			TriggerClientEvent('esx_jengialue:valloitusilmoitus', xPlayers[i], robb)
		end
	end
	Wait(1000*60*30)
	claiming[testihomma] = false
end)

RegisterServerEvent('esx_jengialue:claim')
AddEventHandler('esx_jengialue:claim', function(ryostettavaalue)
		local xPlayer = ESX.GetPlayerFromId(source)
		local cops = 0
		local valloitettavanalueenomistajat = 0
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
			if xPlayer.job.name == jengidatatable[ryostettavaalue].omistaja then
				valloitettavanalueenomistajat = valloitettavanalueenomistajat + 1
			end
		end
		
		if not claiming[ryostettavaalue] then
			if cops >= Config.PoliceNumberRequired then --and gangmembers >= Config.GangNumberReguired then
				
				local yrittaja = xPlayer.job.name
				if yrittaja == jengidatatable[ryostettavaalue].omistaja then
					if jengidatatable[ryostettavaalue].rahaa > 0 then -- tarkistetaan onko rahaa kertynyt yhtään
						local award = jengidatatable[ryostettavaalue].rahaa -- tallennetaan annettavat rahat
						MySQL.Async.execute(
						'UPDATE `jengialueet` SET rahaa = @rahaa WHERE alue = @alue',
						{
						['@rahaa'] = 0,
						['@alue'] = ryostettavaalue
						})
						xPlayer.addMoney(award)
						TriggerEvent('jengialue', GetPlayerName(source).." Keräsi suojelusrahaa " ..award.."€")
						TriggerClientEvent('esx:showNotification', source, 'Sait suojelurahaa: ' .. award)
						Wait(1000)
						TriggerEvent('esx_jengialue:paivitys')
					else
						TriggerClientEvent('esx:showNotification', source, 'Suojelurahaa ei ole vielä ehtinyt kertymään')
					end
				else
					if valloitettavanalueenomistajat > 0 or jengidatatable[ryostettavaalue].omistaja == "vapaa" then
						if (jengidatatable[ryostettavaalue].valtausaika + Config.Mitenuseinvoivallata * 60) < os.time() then
							claiming[ryostettavaalue] = true						
							TriggerClientEvent('esx:showNotification', source, 'Aloitit valtaamaan aluetta')
							TriggerClientEvent('esx_jengialue:currentlyclaiming', source, ryostettavaalue)
							TriggerClientEvent('esx_jengialue:starttimer', source)
							for i=1, #xPlayers, 1 do
								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
								if xPlayer.job.name == jengidatatable[ryostettavaalue].omistaja then
									TriggerClientEvent('esx_jengialue:setblip', xPlayers[i], ryostettavaalue)
									TriggerClientEvent('esx:showNotification', xPlayers[i], 'ALUETTASI VALLATAAN!!!')
									TriggerClientEvent('esx_jengialue:valloitusilmoitus', xPlayers[i], ryostettavaalue) -- testi 28.5
								end
							end						
						else
							TriggerClientEvent('esx:showNotification', source, 'Aluetta on yritetty valloittaa lähiaikoina - yritä myöhemmin uudelleen')
						end
					else
						TriggerClientEvent('esx:showNotification', source, 'Alueen omistajia ei ole kaupungissa joten et voi vallata aluetta!')
					end
				end
			else
				TriggerClientEvent('esx:showNotification', source, 'Kaupungissa pitää olla '..Config.PoliceNumberRequired..' poliisia')
			end
		else
			TriggerClientEvent('esx:showNotification', source, 'Joku valtaa jo aluetta')
		end
end)

RegisterServerEvent('esx_jengialue:rostoohi') --clinulle aluetiedot
AddEventHandler('esx_jengialue:rostoohi', function(ryostettavaalue)
	local xPlayer = ESX.GetPlayerFromId(source)
	claiming[ryostettavaalue] = false
	TriggerClientEvent('esx_jengialue:claimcomplete', source)
	if xPlayer.job.name == 'police' then
		local uusiomistaja = 'vapaa'
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == jengidatatable[ryostettavaalue].omistaja then
				TriggerClientEvent('esx:showNotification', xPlayers[i], 'Alueesi on vallattu!')
				TriggerClientEvent('esx_jengialue:valloitusilmoitus', xPlayers[i], ryostettavaalue)
			end
		end

		MySQL.Async.execute(
		'UPDATE `jengialueet` SET valtausaika = @valtausaika, rahaa = @rahaa, omistaja = @omistaja WHERE alue = @alue',
		{
		['@valtausaika'] = os.time(),
		['@omistaja'] = uusiomistaja,
		['@rahaa'] = 0,
		['@alue'] = ryostettavaalue
		})
		Wait(1000)
		TriggerEvent('esx_jengialue:paivitys') --lähetetään kaikille tieto uudesta omistajasta ja edellistä omistajaa infotaan että alue menetetty --valtaus onnistunut
	else
		local uusiomistaja = xPlayer.job.name
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == jengidatatable[ryostettavaalue].omistaja then
				TriggerClientEvent('esx:showNotification', xPlayers[i], 'Alueesi on vallattu!')
				TriggerClientEvent('esx_jengialue:valloitusilmoitus', xPlayers[i], ryostettavaalue)
			elseif xPlayer.job.name == uusiomistaja then
				TriggerClientEvent('esx:showNotification', xPlayers[i], 'Jengisi on vallannut alueen!')
			end
		end

		MySQL.Async.execute(
		'UPDATE `jengialueet` SET valtausaika = @valtausaika, rahaa = @rahaa, omistaja = @omistaja WHERE alue = @alue',
		{
		['@valtausaika'] = os.time(),
		['@omistaja'] = uusiomistaja,
		['@rahaa'] = 0,
		['@alue'] = ryostettavaalue
		})
		Wait(1000)
		TriggerEvent('esx_jengialue:paivitys') --lähetetään kaikille tieto uudesta omistajasta ja edellistä omistajaa infotaan että alue menetetty --valtaus onnistunut
	end
end)