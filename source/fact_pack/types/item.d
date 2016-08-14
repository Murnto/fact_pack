module fact_pack.types.item;

import std.json;

import jsonizer;

import fact_pack.all_types;

class Item : Craftable
{
    mixin JsonizeMe;
    // mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize JSONValue flags;
    @jsonize int stack_size;
    @jsonize(JsonizeIn.opt) string group;
    @jsonize(JsonizeIn.opt) JSONValue place_as_tile;
    @jsonize(JsonizeIn.opt) string dark_background_icon;
    @jsonize(JsonizeIn.opt) string place_result;
    @jsonize(JsonizeIn.opt) string placed_as_equipment_result;
    @jsonize(JsonizeIn.opt) string fuel_value;
    @jsonize(JsonizeIn.opt) int trigger_radius;
    @jsonize(JsonizeIn.opt) int damage_radius;
    @jsonize(JsonizeIn.opt) int default_request_amount;
}