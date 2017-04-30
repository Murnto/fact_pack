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
    @jsonize(JsonizeIn.opt) string order;
    @CDItem("Name", "getEntAnchor(pd.meta.name)", true) string title;
    @CDItem("Icon", "getIconImg(pd.meta.name)", true) @jsonize(JsonizeIn.opt) string icon;
    string description;

    protected string getIconImg(string packName)
    {
        // TODO: this function shoudln't exist, we should use one from WebPackdata
        return "<img src=\"/pack/" ~ packName ~ "/icon/" ~this.type ~ "/" ~this.name ~ ".png\" />";
    }

    protected string getEntAnchor(string packName)
    {
        // TODO: this function shoudln't exist, we should use the popover one from WebPackdata
        return "<a href=\"/pack/" ~ packName ~ "/i/" ~this.type ~ "/" ~this.name
            ~ "\">" ~this.title ~ "</a>";
    }

    // todo figure out a nice way to automatically list all
    // category data from packdata so that we can list out
    // generic category info (ie. on itemcats/)

    bool hasCategoryData()
    {
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
        real r, g, b;
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
        @CDItem("Emissions", "round(emissions * 100) / 100") real emissions;
        @CDItem("Energy priority") string usage_priority;
        string input_priority; // what?
        string output_flow_limit;
        string buffer_capacity;
        string input_flow_limit;
        string drain;
        JSONValue smoke;
    }
}

// TODO: Nicely merge with above
class EnergySourceGenerator
{
    mixin CategoryData;
    mixin JsonizeMe;

    @CDItem("Energy type") @jsonize string type;
    @CDItem("Energy priority") @jsonize(JsonizeIn.opt) string usage_priority;
}

// TODO: Nicely merge with above
class EnergySourceProvider
{
    mixin CategoryData;
    mixin JsonizeMe;

    @jsonize
    {
        @CDItem("Energy type") string type;
    }

    @jsonize(JsonizeIn.opt)
    
    {
        @CDItem("Energy priority") string usage_priority;
        @CDItem("Output limit") string output_flow_limit;
        @CDItem("Capacity") string buffer_capacity;
        @CDItem("Input limit") string input_flow_limit;
    }
}

class Burner
{
    mixin CategoryData;
    mixin JsonizeMe;

    @jsonize(JsonizeIn.opt)
    {
        @CDItem("Effectivity") real effectivity;
        @CDItem("Emissions", "round(emissions * 100) / 100") real emissions;
        @CDItem("Fuel Inventory") int fuel_inventory_size;
    }
}
