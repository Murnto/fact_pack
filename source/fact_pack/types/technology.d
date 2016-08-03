module fact_pack.types.technology;

import std.json;

import jsonizer;

import fact_pack.all_types;
import fact_pack.json_utils;

struct TechUnit
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    int count;
    ItemAmount*[] ingredients;

    @jsonize this(int count, JSONValue ingredients)
    {
        this.count = count;

        this.ingredients.length = ingredients.object.length;
        int zero_based = "0" in ingredients.object ? 0 : 1;
        foreach (string idx, ref JSONValue jv; ingredients)
        {
            this.ingredients[to!int(idx) - zero_based] = new ItemAmount(jv);
        }
    }
}

class Technology : BasicEnt
{
    mixin JsonizeMe;
    // mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    string order;
    TechUnit unit;

    // optional
    int icon_size;
    bool upgrade;
    // JSONValue effects;
    string[] _prerequisites;
    string[] _unlocks_recipes;

    // annotated
    Recipe*[] unlocks_recipes;
    Technology*[] requires_tech;
    Technology*[] allows_tech;

    @jsonize this(string name, string type, TechUnit unit, string order = null,
            string icon = null, int icon_size = 1, JSONValue upgrade = null,
            JSONValue effects = null, JSONValue prerequisites = null)
    {
        this.name = name;
        this.type = type;
        this.order = order;
        this.unit = unit;
        this.icon = icon;
        this.icon_size = icon_size;
        this.upgrade = json_asbool(upgrade);
        // this.effects = effects;

        if (!prerequisites.isNull)
        {
            foreach (string idx, ref JSONValue jv; prerequisites)
            {
                this._prerequisites ~= jv.str;
            }
        }

        if (!effects.isNull)
        {
            int i = 0;

            foreach (string idx, ref JSONValue jv; effects)
            {
                if (jv["type"].str == "unlock-recipe")
                {
                    this._unlocks_recipes ~= jv["recipe"].str;
                }
            }
        }
    }

    override int opCmp(Object o)
    {
        Technology t = cast(Technology) o;

        return this.title > t.title;
    }
}