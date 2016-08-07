module fact_pack.types.generator;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Generator : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe;

    @CDItem("Min Perceived Performance") @jsonize(JsonizeIn.opt) real min_perceived_performance;
    @CDItem("Fluid Usage per Tick") @jsonize real fluid_usage_per_tick;
    @CDItem @jsonize EnergySourceGenerator energy_source;
    @CDItem("Effectivity") @jsonize real effectivity;
}
