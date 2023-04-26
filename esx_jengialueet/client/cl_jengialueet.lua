local holdingup = false
local store = ""
local blipclaim = nil
local omistus = nil
local hahaatable = {}
local jengissa = false
local ryostetaan = {}
ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	Citizen.Wait(5000)
	
	for i = 1, #Jobit, 1 do
		if ESX.PlayerData.job.name == Jobit[i] then
			jengissa = true
			break
		end
	end
	
	if jengissa then
		TriggerServerEvent('esx_jengialue:fetchmestat')
	end
end)

RegisterNetEvent('esx_jengialue:mestat')
AddEventHandler('esx_jengialue:mestat', function(result)
	if jengissa then
		hahaatable = result
		if blipit then
			for i = 1, #Areas do
				RemoveBlip(Areas[i].nameofarea)
			end
			blipit = false
		end
		if not blipit then
			blipit = true
			for i = 1, #Areas do
				local ve = Areas[i].position
				Areas[i].nameofarea = AddBlipForRadius(ve.x, ve.y, ve.z, Config.MaxDistance+0.0)
				SetBlipColour(Areas[i].nameofarea,69)
				if hahaatable[i].omistaja == ESX.PlayerData.job.name then
					SetBlipColour(Areas[i].nameofarea,69)
				else
					SetBlipColour(Areas[i].nameofarea,4)
				end
				SetBlipAlpha(Areas[i].nameofarea,33)
			end
		end
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	jengissa = false
	ESX.PlayerData.job = job
	for i = 1, #Jobit, 1 do
		if ESX.PlayerData.job.name == Jobit[i] then
			jengissa = true
			break
		end
	end
	if blipit then
		for i = 1, #Areas do
			RemoveBlip(Areas[i].nameofarea)
		end
		blipit = false
	end
	if jengissa then
		TriggerServerEvent('esx_jengialue:fetchmestat')
	end
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
   SetTextFont(4)
   SetTextProportional(1)
   SetTextScale(0.6, 0.6)
   SetTextColour(128, 128, 128, 255)
   SetTextDropshadow(0, 0, 0, 0, 255)
   SetTextEdge(1, 0, 0, 0, 150)
   SetTextDropshadow()
   SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)

end

RegisterNetEvent('esx_jengialue:currentlyclaiming')
AddEventHandler('esx_jengialue:currentlyclaiming', function(mesta)
	alueenperkele = mesta
	holdingup = true
end)

RegisterNetEvent('esx_jengialue:killblip')
AddEventHandler('esx_jengialue:killblip', function(kohte)
	SetBlipColour(Areas[kohte].nameofarea,69)
end)

RegisterNetEvent('esx_jengialue:setblip')
AddEventHandler('esx_jengialue:setblip', function(kohte)
	SetBlipColour(Areas[kohte].nameofarea,59)
end)

RegisterNetEvent('esx_jengialue:toofarlocal')
AddEventHandler('esx_jengialue:toofarlocal', function()
	holdingup = false
	alueenperkele = ""
end)


RegisterNetEvent('esx_jengialue:claimcomplete')
AddEventHandler('esx_jengialue:claimcomplete', function()
	holdingup = false
	if ESX.PlayerData.job.name == 'police' then
		ESX.ShowNotification('Olet vapauttanut alueen!')
		alueenperkele = ""
	else
		ESX.ShowNotification(_U('claim_complete'))
		alueenperkele = ""
	end
end)

RegisterNetEvent('esx_jengialue:valloitusilmoitus') --testi 28.5
AddEventHandler('esx_jengialue:valloitusilmoitus', function(notifikaatio)
	if not ryostetaan[notifikaatio] then
		ryostetaan[notifikaatio] = true
	else
		ryostetaan[notifikaatio] = false
	end
	while ryostetaan[notifikaatio] == true do
		local halytys = Areas[notifikaatio].position
		local sijainti = GetEntityCoords(PlayerPedId(), true)
		if Vdist(sijainti.x, sijainti.y, sijainti.z, halytys.x, halytys.y, halytys.z) < Config.MaxDistance then
			drawTxt(0.66, 1.40, 1.0,1.0,0.4, '~r~VAROITUS ~w~- ALUETTASI VALLATAAN !', 255, 255, 255, 255)
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_jengialue:starttimer')
AddEventHandler('esx_jengialue:starttimer', function()
	timer = Config.Valtausaika
	laskuri = 0
	Citizen.CreateThread(function()
		while timer > 0 do

			Citizen.Wait(1000)
			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if holdingup then
				if not poistumassa then
					if ESX.PlayerData.job.name == 'police' then
						drawTxt(0.66, 1.44, 1.0,1.0,0.4, '~w~Sinulla on ~r~'..timer..' ~w~sekuntia aikaa partioida alueella tarpeeksi. ~g~'..laskuri..' / '..Config.Montakoalistetaan, 255, 255, 255, 255)
					else
						drawTxt(0.66, 1.44, 1.0,1.0,0.4, '~w~Sinulla on ~r~'..timer..' ~w~sekuntia aikaa kovistella alueella asuvia kansalaisia. ~g~'..laskuri..' / '..Config.Montakoalistetaan, 255, 255, 255, 255)
					end
				else
					drawTxt(0.66, 1.44, 1.0,1.0,0.4, '~r~VAROITUS ~w~- OLET POISTUMASSA ALUEELTA !', 255, 255, 255, 255)
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)
end)

local fakelaskuri = 0
laskuri = 0
Citizen.CreateThread(function()
Citizen.Wait(21000) --aika hakea työpaikka 8.5
	while true do
		Citizen.Wait(5)
		local pos = GetEntityCoords(PlayerPedId(), true)
		
		if not holdingup then
			
			for i = 1, #Areas do
				local pos2 = Areas[i].position
				local area = i
				if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 3.0 then
					if hahaatable[1] ~= nil then
						if hahaatable[i].omistaja == ESX.PlayerData.job.name then
							ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ kerätäksesi suojelurahat - ~g~'..Areas[i].nameofree) -- ilmoitus paina E
						else
							ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ vallataksesi alue - ~g~'..Areas[i].nameofree) -- ilmoitus paina E
						end
					elseif ESX.PlayerData.job.name == "police" then
						ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ vapauttaaksesi alue - ~g~'..Areas[i].nameofree) -- ilmoitus paina E
					else
						ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ vallataksesi alue - ~g~'..Areas[i].nameofree) -- ilmoitus paina E
					end
					if IsControlJustReleased(0, Keys['E']) then -- käynnistä ryöstö
						if IsPedArmed(PlayerPedId(), 7) then
							if not jengissa then-- onko asetta
								if ESX.PlayerData.job.name == 'police' then
									TriggerServerEvent('esx_jengialue:poliisille', area)
									Wait(5000)
								--else
								--	ESX.ShowNotification('Et kuulu jengiin')
								end
							else
								TriggerServerEvent('esx_jengialue:claim', area)
								Wait(5000)
							end
						else
							ESX.ShowNotification(_U('no_threat')) -- ei välineitä mukana
						end
					end
				end
			end
			
		else
			if ESX.PlayerData.job.name == 'police' then
				local speed = GetEntitySpeed(PlayerPedId())*3.6
				if speed > 10 then
					fakelaskuri = fakelaskuri + 1
					if fakelaskuri > 100 then
						laskuri = laskuri + 1
						fakelaskuri = 0
					end
				end
			else
				if IsControlPressed(0, 25) then
					local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
					if aiming then
						local playerPed = GetPlayerPed(-1)
						local pCoords = GetEntityCoords(playerPed, true)
						local tCoords = GetEntityCoords(targetPed, true)
						if not IsPedInAnyVehicle(playerPed, false) and IsPedArmed(playerPed, 7) then
							if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) and not IsPedAPlayer(targetPed) and targetPed ~= oldped and not IsPedDeadOrDying(targetPed, true) and not IsPedCuffed(targetPed) then
								if IsPedInAnyVehicle(targetPed, false) then
									if GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, tCoords.x, tCoords.y, tCoords.z, true) < 25 then									
										if GetEntitySpeed(targetPed)*3.6 < 20 then
											TaskLeaveVehicle(targetPed, GetVehiclePedIsUsing(targetPed), 1)
											robbedRecently = true
											Citizen.Wait(1500)
											if not IsPedInAnyVehicle(targetPed, false) then
												TaskSmartFleePed(targetPed, GetPlayerPed(-1), 1000.0, -1, true, true)
												SetPedAsNoLongerNeeded(targetPed)
												laskuri = laskuri + 1
											end
											robbedRecently = false
										end
									end
								else
									if not robbedRecently then
										robNpc(targetPed)
									end
								end
							end
						end
					end
				end
			end

			local pos2 = Areas[alueenperkele].position
			if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > Config.MaxDistance then
--				TriggerServerEvent('esx_jengialue:toofar', alueenperkele)
				timer = 0
			end

			if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > Config.MaxDistance - 50 then
				poistumassa = true
			else
				poistumassa = false
			end

			if IsPedDeadOrDying(GetPlayerPed(-1)) then
				timer = 0
--				TriggerServerEvent('esx_jengialue:toofar', alueenperkele)
			end

			if timer == 0 then
				TriggerServerEvent('esx_jengialue:toofar', alueenperkele)
				holdingup = false
			end
			
			if laskuri == Config.Montakoalistetaan then
				TriggerServerEvent('esx_jengialue:rostoohi', alueenperkele)
				holdingup = false
				laskuri = 0
			end

			Citizen.Wait(100)
		end
		
	end
end)

function robNpc(targetPed)
    Citizen.CreateThread(function()
		robbedRecently = true
--		SetPedRelationshipGroupHash(targetPed, 'team1')
		ClearPedTasks(targetPed)
		SetEnableHandcuffs(targetPed, true)
--		TaskHandsUp(targetPed, Config.RobAnimationSeconds * 1000, GetPlayerPed(-1), 5000, 1)
--		Citizen.Wait(Config.RobAnimationSeconds * 1000)
		for xd=1, 40 do
			Citizen.Wait(100)
			TaskHandsUp(targetPed, 120, GetPlayerPed(-1), 5000, 1)
		end
		TaskSmartFleePed(targetPed, GetPlayerPed(-1), 1000.0, -1, true, true)
		SetPedAsNoLongerNeeded(targetPed)
		oldped = targetPed
        robbedRecently = false
		laskuri = laskuri + 1
    end)
end