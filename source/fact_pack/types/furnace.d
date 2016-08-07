module fact_pack.types.furnace;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Furnace : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @CDItem("Module slots") long module_slots;
    @CDItem("Energy usage") string energy_usage;
    @CDItem EnergySource energy_source;
    string[] module_specification;
    string[] allowed_effects;
    JSONValue _module_specification;
    @CDItem("Crafting speed") real crafting_speed;
    @CDItem("Crafting categories", "join(crafting_categories, \", \")") string[] crafting_categories;

    @jsonize this(string name, string icon, string type, real crafting_speed,
            string energy_usage, JSONValue energy_source,
            JSONValue crafting_categories, JSONValue module_specification = null,
            JSONValue allowed_effects = null)
    {
        this.name = name;
        this.icon = icon;
        this.type = type;
        this.crafting_speed = crafting_speed;
        this.energy_usage = energy_usage;
        this.energy_source = energy_source.fromJSON!EnergySource;

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
        if (crafting_categories.type() == JSON_TYPE.STRING)
        {
            // 5dim-f11 specifies 'locomotive-furnace-moving-trans' like this
            this.crafting_categories ~= crafting_categories.str;
        }
        else
        {
            foreach (string idx, ref JSONValue jv; crafting_categories)
            {
                this.crafting_categories ~= jv.str;
            }
        }
    }
}