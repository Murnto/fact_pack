module fact_pack.types.resource;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Resource : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    string order;
    @CDItem("Category")string category;
    @CDItem("Map Color", "hexMapColor()") real[3] map_color;
    JSONValue minable; // optional
    @CDItem("Normal")int normal; // optional
    @CDItem("Minimum") int minimum; // optional
    bool map_grid; // optional
    @CDItem("Infinite", "infinite ? \"Yes\" : \"No\"") bool infinite; // optional

    @jsonize this(string type, string name, string icon, string order, JSONValue map_color,
            JSONValue minable = null, string category = "basic-solid", int normal = -1,
            int minimum = -1, bool map_grid = true, bool infinite = false)
    {

        this.type = type;
        this.name = name;
        this.icon = icon;
        this.order = order;
        this.map_color = [fromJSON!real(map_color["r"]),
            fromJSON!real(map_color["g"]), fromJSON!real(map_color["b"])];
        this.minable = minable;
        this.category = category;
        this.normal = normal;
        this.minimum = minimum;
        this.map_grid = map_grid;
        this.infinite = infinite;
    }

    string hexMapColor()
    {
        import std.math : round;
        // real function(real) clamp = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);
        // string function(real) toByteStr = (x) => (to!string(round()));

        return "#000000";
    }
}