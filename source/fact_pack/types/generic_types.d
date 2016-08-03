module fact_pack.types.generic_types;

import std.json;
import std.exception;

import jsonizer;

import fact_pack.all_types;

class BasicEnt
{
    mixin JsonizeMe;

    @jsonize string name;
    @jsonize string type;
    @CDItem("Name") string title;
    @CDItem("Icon", "getIconImg(pd.meta.name)", true) @jsonize(JsonizeIn.opt) string icon;

    protected string getIconImg(string packName)
    {
        // TODO: this function shoudln't exist, we should use one from WebPackdata
        return "<img src=\"/pack/" ~ packName ~ "/icon/" ~ this.type ~ "/" ~ this.name ~ ".png\" />";
    }

    // todo figure out a nice way to automatically list all
    // category data from packdata so that we can list out
    // generic category info (ie. on itemcats/)

    bool hasCategoryData() {
        return false;
    }

    string[] parse(Packdata pd)
    {
        assert(false);
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

class Craftable : BasicEnt
{
    mixin JsonizeMe;

    Recipe*[] uses;
    Recipe*[] recipes;

    @jsonize(JsonizeIn.opt) string subgroup;
}

class EnergySource
{
    mixin CategoryData;
    mixin JsonizeMe;
    // mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize
    {
        @CDItem("Energy type") string type;
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
