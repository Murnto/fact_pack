module fact_pack.types.generic_types;

import std.json;

import jsonizer;

import fact_pack.all_types;

class BasicEnt
{
    mixin JsonizeMe;

    @jsonize string name;
    @jsonize string type;
    string title;

    // todo figure out a nice way to automatically list all
    // category data from packdata so that we can list out
    // generic category info (ie. on itemcats/)

    bool hasCategoryData() {
        return false;
    }
}

struct Color
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize
    {
        float r, g, b;
    }
}

class Craftable : HasIcon
{
    mixin JsonizeMe;

    Recipe*[] uses;
    Recipe*[] recipes;

    @jsonize(JsonizeIn.opt) string subgroup;
}

class HasIcon : BasicEnt
{
    mixin JsonizeMe;

    @jsonize(JsonizeIn.opt) string icon;
}

class EnergySource
{
    mixin JsonizeMe;
    // mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize
    {
        string type;
    }

    @jsonize(JsonizeIn.opt)
    {
        int fuel_inventory_size;
        int effectivity;
        float emissions;
        string usage_priority;
        string input_priority; // what?
        string output_flow_limit;
        string buffer_capacity;
        string input_flow_limit;
        string drain;
        JSONValue smoke;
    }
}
