module fact_pack.types.mining_drill;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class MiningDrill : HasIcon
{
    // mixin JsonizeMe;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    real mining_speed;
    real mining_power;
    real resource_searching_radius;
    string energy_usage;
    EnergySource energy_source;
    string[] resource_categories;
    string[] module_specification;
    JSONValue _module_specification;
    long module_slots;

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
