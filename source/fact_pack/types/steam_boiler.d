module fact_pack.types.steam_boiler;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class SteamBoiler : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe;

    @CDItem("Energy Consumption") @jsonize string energy_consumption;
    @CDItem("Burning CD") @jsonize real burning_cooldown;
    @CDItem @jsonize Burner burner;
}
