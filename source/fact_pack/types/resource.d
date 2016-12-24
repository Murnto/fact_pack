module fact_pack.types.resource;

import std.json;
import std.conv : to;
import std.math : isNaN;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Resource : BasicEnt
{
    mixin CategoryData;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @CDItem("Map Color", "hexMapColor()", true) real[3] map_color;
    bool minable; // optional
    @CDItem("Normal", "isNaN(normal) ? \"\" : to!string(normal)") real normal; // optional
    @CDItem("Minimum", "isNaN(minimum) ? \"\" : to!string(minimum)") real minimum; // optional
    @CDItem("Mining time") real mining_time; // optional
    @CDItem("Hardness") real hardness; // optional
    bool map_grid; // optional
    @CDItem("Infinite", "infinite ? \"Yes\" : \"No\"") bool infinite; // optional
    @CDItem("Category") string category;

    @jsonize this(string type, string name, string icon, string order,
        JSONValue map_color, JSONValue minable = null,
        string category = "basic-solid", real normal = real.nan,
        real minimum = real.nan, bool map_grid = true, bool infinite = false)
    {

        this.type = type;
        this.name = name;
        this.icon = icon;
        this.order = order;
        this.map_color = [fromJSON!real(map_color["r"]),
            fromJSON!real(map_color["g"]), fromJSON!real(map_color["b"])];
        this.minable = !minable.isNull;
        this.category = category;
        this.normal = normal;
        this.minimum = minimum;
        this.map_grid = map_grid;
        this.infinite = infinite;
        if (minable.type == JSON_TYPE.OBJECT)
        {
            if (!minable["hardness"].isNull)
            {
                this.hardness = fromJSON!real(minable["hardness"]);
            }
            if (!minable["mining_time"].isNull)
            {
                this.mining_time = fromJSON!real(minable["mining_time"]);
            }
        }
    }

    string hexMapColor()
    {
        import std.math : round;
        import std.format : format;

        int function(real) clamp = (x) => to!int(round((x < 0 ? 0 : x > 1 ? 1 : x) * 255));
        string hexColor = format("%02X%02X%02X", clamp(this.map_color[0]),
            clamp(this.map_color[1]), clamp(this.map_color[2]));

        return "<div class=\"cat-resource-color\" style=\"background: #" ~ hexColor ~ "\"></div>&nbsp;#" ~ hexColor;
    }
}
