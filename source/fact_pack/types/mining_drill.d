module fact_pack.types.mining_drill;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class MiningDrill : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @CDItem("Radius") real resource_searching_radius;
    @CDItem("Resource Categories", "join(resource_categories, \", \")") string[] resource_categories;
    @CDItem("Module slots") long module_slots;
    @CDItem("Mining speed") real mining_speed;
    @CDItem("Mining power") real mining_power;
    @CDItem("Energy usage") string energy_usage;
    @CDItem EnergySource energy_source;
    string[] module_specification;
    JSONValue _module_specification;

    @jsonize this(string name, string icon, string type, real mining_power,
            real mining_speed, real resource_searching_radius,
            string energy_usage, JSONValue energy_source,
            JSONValue resource_categories, JSONValue module_specification = null)
    {
        this.name = name;
        this.icon = icon;
        this.type = type;
        this.mining_speed = mining_speed;
        this.mining_power = mining_power;
        this.resource_searching_radius = resource_searching_radius;
        this.energy_usage = energy_usage;
        this.energy_source = energy_source.fromJSON!EnergySource;

        foreach (string idx, ref JSONValue jv; resource_categories)
        {
            this.resource_categories ~= jv.str;
        }
        if (!module_specification.isNull)
        {
            this._module_specification = module_specification;
            this.module_slots = module_specification["module_slots"].integer;
        }
    }
}
