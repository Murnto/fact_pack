module fact_pack.types.accumulator;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Accumulator : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe;

    @CDItem @jsonize EnergySourceProvider energy_source;
    @CDItem("Charge CD") @jsonize real charge_cooldown;
    @CDItem("Discharge CD") @jsonize real discharge_cooldown;
}
