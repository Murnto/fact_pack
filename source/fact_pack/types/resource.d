module fact_pack.types.resource;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Resource : HasIcon
{
    // mixin JsonizeMe;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    string order;
    string category;
    real[3] map_color;
    JSONValue minable; // optional
    int normal; // optional
    int minimum; // optional
    bool map_grid; // optional
    bool infinite; // optional

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
}