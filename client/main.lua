local menuOpened = false

function OpenShopMenu()
	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
		menuOpened = true
		local HasPaid = false
		menu.close()
		
		local elements = {
			{unselectable = true, icon = "fas fa-check-double", title = TranslateCap("valid_purchase")},
			{icon = "fas fa-check-circle", title = TranslateCap("yes"), value = "yes"},
			{icon = "fas fa-window-close", title = TranslateCap("no"), value = "no"},
		}

		ESX.OpenContext("right", elements, function(menu,element)
			if element.value == "yes" then
				ESX.TriggerServerCallback('esx_barbershop:checkMoney', function(hasEnoughMoney)
					if hasEnoughMoney then
						ESX.CloseContext()
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)
						HasPaid = true
						TriggerServerEvent('esx_barbershop:pay')
					else
						ESX.CloseContext()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin) 
						end)

						ESX.ShowNotification(TranslateCap('not_enough_money'))
					end
					menuOpened = false
				end)
			elseif element.value == "no" then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin) 
				end)
				ESX.CloseContext()
			end
		end, function()
			if not HasPaid then 
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin) 
				end)
			end
		end)
	end, function(data, menu)
		menu.close()
	end, {
		'beard_1',
		'beard_2',
		'beard_3',
		'beard_4',
		'hair_1',
		'hair_2',
		'hair_color_1',
		'hair_color_2',
		'eyebrows_1',
		'eyebrows_2',
		'eyebrows_3',
		'eyebrows_4',
		'makeup_1',
		'makeup_2',
		'makeup_3',
		'makeup_4',
		'lipstick_1',
		'lipstick_2',
		'lipstick_3',
		'lipstick_4',
		'ears_1',
		'ears_2',
	})
end

-- Create Interactions
CreateThread(function()
	for k,v in ipairs(Config.Shops) do
		-- blips
		local blip = AddBlipForCoord(v)

		SetBlipSprite(blip, 71)
		SetBlipScale(blip, 0.7)
		SetBlipColour(blip, 51)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('barber_blip'))
		EndTextCommandSetBlipName(blip)

		-- Markers
		ESX.CreateMarker("barber".. k, v, Config.DrawDistance, TranslateCap('press_access'), {
			drawMarker = true,
			key = 38,
			scale = Config.MarkerSize, -- Scale of the marker
			sprite = Config.MarkerType, -- type of the marker
			colour =  Config.MarkerColor -- R, G, B, A, colour system
		}, function()
			if not menuOpened then
				OpenShopMenu()
				ESX.HideUI()
			end
		end)
	end
end)