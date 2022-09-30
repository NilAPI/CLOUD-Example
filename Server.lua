local dataStoreService = game:GetService("DataStoreService");

local inStudio         = game:GetService("RunService"):IsStudio();
local profile_Template = require(script:WaitForChild("Template")) or {};
local replicaService   = _G.ReplicaService;

CLOUD = nil;

if (inStudio == true) then
	CLOUD = dataStoreService:GetDataStore("CLOUD_STUDIO_1");
else
	CLOUD = dataStoreService:GetDataStore("CLOUD_LIVE_1");
end

local function playerAdded(player)
	local data = CLOUD:GetAsync(player.UserId);
	if (data ~= nil) then
		_G.CLOUD[player] = data;
		print("player isn't new :", _G.CLOUD);
	elseif (data == nil) then
		_G.CLOUD[player] = profile_Template;
		print("player is new :", _G.CLOUD);
	end
	-- get loaded data
	data = _G.CLOUD[player];
	
	local theirReplica = replicaService.NewReplica({
		ClassToken = replicaService.NewClassToken(player.Name),
		Data = {data},
		Replication = "All",
	})
	
	if (theirReplica ~= nil) then
		_G.Replicas[player] = theirReplica;
	end
end

local function playerLeaving(player)
	if (_G.CLOUD[player] ~= nil) then
		
		local succ, err = pcall(function()
			CLOUD:SetAsync(player.UserId, _G.CLOUD[player])
			_G.CLOUD[player] = nil;
		end)
		
		if (succ) then
			print("Data saved successfully!");
		else
			warn("Failed to save data!", err);
		end
	end
end



local players = game:GetService("Players");


players.PlayerAdded:Connect(playerAdded);
players.PlayerRemoving:Connect(playerLeaving);


return "This is running the CLOUD!"
