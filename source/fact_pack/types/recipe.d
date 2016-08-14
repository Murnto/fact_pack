module fact_pack.types.recipe;

import std.json;
import std.conv : to;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

class Recipe : BasicEnt
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    // required
    ItemAmount*[] ingredients;
    ItemAmount*[] results;

    // optional
    float energy_required = 0.5;
    bool enabled = true;
    string category;

    string subgroup;
    string icon;
    // string main_product;
    bool hidden = false;

    // annotated
    Technology*[] unlocked_by;

    @jsonize this(string name, JSONValue ingredients, string type, string order = null,
            string subgroup = null, string icon = null, JSONValue results = null, string main_product = null,
            float energy_required = 0.5, string result = null, string category = null,
            float result_count = 1, JSONValue enabled = null, JSONValue hidden = null)
    {
        assert(!ingredients.isNull);
        assert(name.length);
        assert(type.length);

        this.name = name;
        this.type = type;
        this.energy_required = energy_required;
        this.enabled = json_asbool(enabled, true);
        this.category = category;

        this.order = order;
        this.subgroup = subgroup;
        this.icon = icon;
        // this.main_product = main_product; // ???
        this.hidden = json_asbool(hidden);

        if (!results.isNull)
        {
            this.results.length = results.object.length;
            int zero_based = "0" in ingredients.object ? 0 : 1;
            foreach (string idx, ref JSONValue jv; results)
            {
                this.results[to!int(idx) - zero_based] = new ItemAmount(jv);
            }
        }
        else
        {
            assert(result != null);
            this.results.length = 1;
            this.results[0] = new ItemAmount;
            this.results[0].name = result;
            this.results[0].amount = result_count;
        }

        this.ingredients.length = ingredients.object.length;
        int zero_based = "0" in ingredients.object ? 0 : 1;
        foreach (string idx, ref JSONValue jv; ingredients)
        {
            this.ingredients[to!int(idx) - zero_based] = new ItemAmount(jv);
        }
    }

}