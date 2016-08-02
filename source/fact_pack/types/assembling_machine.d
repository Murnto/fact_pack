module fact_pack.types.assembling_machine;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class AssemblingMachine : HasIcon
{
    // mixin JsonizeMe;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    real crafting_speed;
    int ingredient_count;
    string energy_usage;
    EnergySource energy_source;
    string[] crafting_categories;
    string[] allowed_effects;
    JSONValue _module_specification;
    long module_slots;

    @jsonize this(string name, string icon, string type, real crafting_speed,
            string energy_usage, JSONValue energy_source,
            int ingredient_count, JSONValue crafting_categories,
            JSONValue allowed_effects = null, JSONValue module_specification = null)
    {
        this.name = name;
        this.icon = icon;
        this.type = type;
        this.ingredient_count = ingredient_count;
        this.crafting_speed = crafting_speed;
        this.energy_usage = energy_usage;
        this.energy_source = energy_source.fromJSON!EnergySource;

        foreach (string idx, ref JSONValue jv; crafting_categories)
        {
            this.crafting_categories ~= jv.str;
        }
        if (!module_specification.isNull)
        {
            this._module_specification = module_specification;
            this.module_slots = module_specification["module_slots"].integer;
        }
        if (!allowed_effects.isNull)
        {
            foreach (string idx, ref JSONValue jv; allowed_effects)
            {
                this.allowed_effects ~= jv.str;
            }
        }
    }

}