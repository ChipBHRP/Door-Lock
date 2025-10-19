Config = {}

-- Use the in-game /checkdoor command to find the model hash of any door you want to add.
-- The number is the "model hash" (signed integer), and the 'true' just means it's on the list.
Config.DoorModels = {

    -- 👇 YOUR NEWLY FOUND HASH (1804626822) 👇
    [1804626822] = true, 

    -- == Original Hashes (Cleaned up) ==
    [-113884201] 	= true, 	-- Generic House Door
    [-879853347] 	= true, 	-- Another common house door
    [-1653372102] 	= true, 	-- Bank Vault Door
    [-1582042398] 	= true, 	-- Office Door
    [-247549685] 	= true, 	-- Metal door
    [-1224215231] 	= true, 	-- Another industrial/metal door

    -- == Commercial / Bank Doors ==
    [110411286] 	= true, 	-- Pacific Standard Bank Main Door (L/R)
    [1956494919] 	= true, 	-- Pacific Standard Bank Upstairs Door
    [9467943] 		= true, 	-- Jewel Store Door
    [-1116041313] 	= true, 	-- Vanilla Unicorn Front Door
    [-1652821467] 	= true, 	-- Generic Garage Door 1 (prop_gar_door_01)
    [-822900180] 	= true, 	-- Los Santos Customs Garage Door
    [-550347177] 	= true, 	-- Los Santos Customs Office Door
    [-8873588] 		= true, 	-- Ammu-Nation Door Right
    [97297972] 		= true, 	-- Ammu-Nation Door Left
    [452874391] 	= true, 	-- Ammu-Nation Shooting Range Door
    [270330101] 	= true, 	-- Los Santos Customs Popular Street Door

    -- == Emergency Services / PD / Hospital Doors ==
    [2988892982] 	= true, 	-- Generic single glass door (prop_motel_door_09)
    [-1867159867] 	= true, 	-- Police Station door 1 (prop_ss1_mpint_door_l)
    [-405152626] 	= true, 	-- Industrial Freight Door Right (prop_cs_freightdoor_r1)
    [1107966991] 	= true, 	-- Industrial Freight Door Left (prop_cs_freightdoor_l1)
    [-872784146] 	= true, 	-- Metal Mine Door (prop_mine_doorng_r)
    [-1473210343] 	= true, 	-- Generic Metal Door 1
    [1252118318] 	= true, 	-- Generic Metal Door 2

    -- == Common Residential / Interior Doors ==
    [-1306074314] 	= true, 	-- Apartment/Motel Door
    [-1212275031] 	= true, 	-- Standard Wooden Door (prop_gar_door_03)
    [-502195954] 	= true, 	-- Standard House Door (prop_map_door_01)
    [1308911070] 	= true, 	-- Hotel Door (prop_bhhotel_door_r)

    -- == Gates / Shutters ==
    [-577103870] 	= true, 	-- Security Gate 1 (prop_sec_gate_01c)
    [628598716] 	= true, 	-- Security Gate 2 (prop_sec_gate_01b)
    [-550386901] 	= true, 	-- Burton Gate (prop_burto_gate_01)
    [-627681782] 	= true, 	-- Garage Door/Shutter (prop_sm1_11_garaged)
    [-1148826190] 	= true, 	-- Discount Store South Right Door
    [868499217] 	= true, 	-- Discount Store South Left Door
}