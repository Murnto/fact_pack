module fact_pack.types.solar_panel;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class SolarPanel : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe;

    @CDItem("Production") @jsonize string production;
    // @CDItem @jsonize EnergySource energy_source;
}
