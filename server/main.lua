local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('safe_holdup:toofar')
AddEventHandler('safe_holdup:toofar', function(robb)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Stores[robb].nameofstore))
			TriggerClientEvent('safe_holdup:killblip', xPlayers[i])
		end
	end
	if robbers[_source] then
		TriggerClientEvent('safe_holdup:toofarlocal', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', Stores[robb].nameofstore))
	end
end)

RegisterServerEvent('safe_holdup:rob')
AddEventHandler('safe_holdup:rob', function(robb)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if Stores[robb] then
		local store = Stores[robb]

		if (os.time() - store.lastrobbed) < Config.TimerBeforeNewRob and store.lastrobbed ~= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('recently_robbed', Config.TimerBeforeNewRob - (os.time() - store.lastrobbed)))
			return
		end

		local cops = 0
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end

		if rob == false then
			if cops >= Config.PoliceNumberRequired then
				rob = true
				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' then
						TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog', store.nameofstore))
						TriggerClientEvent('safe_holdup:setblip', xPlayers[i], Stores[robb].position)
					end
				end

				TriggerClientEvent('esx:showNotification', _source, _U('started_to_rob', store.nameofstore))
				TriggerClientEvent('esx:showNotification', _source, _U('alarm_triggered'))
				
				TriggerClientEvent('safe_holdup:currentlyrobbing', _source, robb)
				TriggerClientEvent('safe_holdup:starttimer', _source)
				
				Stores[robb].lastrobbed = os.time()
				robbers[_source] = robb
				local savedSource = _source
				SetTimeout(store.secondsRemaining * 1000, function()

					if robbers[savedSource] then
						rob = false
						if xPlayer then
							local award = store.reward
							TriggerClientEvent('safe_holdup:robberycomplete', savedSource, award)
							xPlayer.addAccountMoney('black_money', award)
							
							local xPlayers = ESX.GetPlayers()
							for i=1, #xPlayers, 1 do
								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
								if xPlayer.job.name == 'police' then
									TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', store.nameofstore))
									TriggerClientEvent('safe_holdup:killblip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
