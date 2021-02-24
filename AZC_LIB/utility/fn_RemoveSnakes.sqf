params [["_percentRemoved",1.00]];

// BI adds unrealistic amount of snakes to all maps automatically.
// I had enough when there were several crawling on the concrete of a place in Chernobyl Zone
// when in real life they tend to be rare to see at all.
while { alive player } do
{
	sleep 5;
	{
		if (floor(random(1)) < _percentRemoved) then { deleteVehicle _x; };
	} forEach (player nearEntities [["Snake_random_F"], 90]);
};
