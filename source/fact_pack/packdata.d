module fact_pack.packdata;

import std.stdio;
import std.file;
import std.conv;
import std.json;
import std.path;
import std.string;
import std.algorithm : canFind, sort;

import dini;
import jsonizer;
import fact_pack.all_types;
import fact_pack.category_data;

public const static string[] ALTERNATE_ITEM_TYPES = [
    "ammo", "armor", "blueprint", "capsule", "car", "cargo-wagon",
    "locomotive", "deconstruction-item", "fluid", "gun", "item", "mining-tool",
    "module", "repair-tool", "tool", "rail-planner", "blueprint-book"
];

class ModInfo
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize string name;
    @jsonize("version") string version_str;
    @jsonize string description;
    @jsonize string title;
}

class PackMetadata
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize ModInfo[] mods;
    @jsonize string name;
    @jsonize string description;
    @jsonize string title;
}

class Packdata
{
    mixin EnumerateCategoryData;

    Recipe[string] recipes;
    Item[string] items;
    Fluid[string] fluids;
    ItemSubgroup[string] item_subgroups;
    Resource[string] resources;
    SteamBoiler[string] steamBoilers;
    Generator[string] generators;
    SolarPanel[string] solarPanels;
    Technology[string] technology;
    Furnace[string] furnaces;
    MiningDrill[string] miningDrills;
    Accumulator[string] accumulators;
    AssemblingMachine[string] assemblingMachines;
    PackMetadata meta;
    Craftable[string][string] all_items;
    AssemblingMachine*[][string] craftCategoryMap;
    string path;
    string[] sorted_tech;
    // JSONValue mem;
    protected Ini locale;

    void load_craftable(T)(ref T[string] store, ref JSONValue category)
    {
        foreach (string key, ref JSONValue val; category)
        {
            T foo = val.fromJSON!T;
            store[foo.name] = foo;

            foo.title = this.resolve_locale_name(foo);
            foo.description = this.resolve_description(foo.name);
            foo.uses = this.find_recipes_using(foo.type, foo.name);
            foo.recipes = this.find_recipes_producing(foo.type, foo.name);
        }
    }

    void load_json(T)(ref T[string] store, ref JSONValue mem, string cat)
    {
        if (cat !in mem) {
            writeln("Pack '", meta.name, "' missing '", cat, "' category!");
            return;
        }

        JSONValue category = mem[cat];
        foreach (string key, ref JSONValue val; category)
        {
            T foo = val.fromJSON!T;
            store[foo.name] = foo;

            foo.title = this.resolve_locale_name(foo);
            foo.description = this.resolve_description(foo.name);
        }
    }

    this(const string packpath)
    {
        this.path = packpath;
        this.meta = fromJSONString!PackMetadata(cast(string) read(buildPath(packpath, "info.json")));

        auto raw_json = cast(char[]) read(buildPath(packpath, "out"));
        JSONValue mem = parseJSON(raw_json);

        locale = Ini();
        locale.parse(buildPath(packpath, "localedump.cfg"), false);

        load_json(this.recipes, mem, "recipe");
        load_json(this.item_subgroups, mem, "item-subgroup");
        load_json(this.resources, mem, "resource");
        load_json(this.generators, mem, "generator");
        load_json(this.solarPanels, mem, "solar-panel");
        load_json(this.steamBoilers, mem, "boiler");
        load_json(this.accumulators, mem, "accumulator");
        load_json(this.furnaces, mem, "furnace");
        load_json(this.miningDrills, mem, "mining-drill");
        load_json(this.assemblingMachines, mem, "assembling-machine");

        foreach (string key, ref JSONValue val; mem["technology"])
        {
            Technology foo = val.fromJSON!Technology;
            this.technology[foo.name] = foo;
            foo.title = this.resolve_locale_name(foo);
            foo.description = this.get_technology_description(foo.name);

            // annotate recipes unlocked by this technology
            foreach (string recipe_name; foo._unlocks_recipes)
            {
                Recipe* r = recipe_name in this.recipes;

                if (r)
                {
                    foo.unlocks_recipes ~= r;

                    r.unlocked_by ~= &this.technology[foo.name];
                }
            }
            // writeln(foo.name, " ", foo.title, " ", foo._unlocks_recipes, " ", foo.prerequisites, " ", foo.unit);
        }
        load_craftable(this.items, mem["item"]);
        load_craftable(this.fluids, mem["fluid"]);

        foreach (string alt_type; ALTERNATE_ITEM_TYPES)
        {
            if (alt_type in mem)
            {
                this.all_items[alt_type] = null;
                load_craftable(this.all_items[alt_type], mem[alt_type]);
            }
        }

        this.map_info_types();

        foreach (ref assem; this.assemblingMachines)
        {
            foreach (ref cat; assem.crafting_categories)
            {
                this.craftCategoryMap[cat] ~= &assem;
            }
        }
        foreach (ref catAssems; this.craftCategoryMap.keys)
        {
            sort!((a, b) => sort_order!(AssemblingMachine*)(a,b))(this.craftCategoryMap[catAssems]);
        }
        foreach (ref Technology t; this.technology)
        {
            sort!((a, b) => sort_order!(ItemAmount*)(a,b))(t.unit.ingredients);
            foreach (ref string req_name; t._prerequisites)
            {
                Technology* req_tech = req_name in this.technology;

                if (req_tech)
                {
                    t.requires_tech ~= req_tech;

                    req_tech.allows_tech ~= &this.technology[t.name];
                }
                else
                {
                    writeln("Technology '", t.name, "' requires '", req_name,
                        "' which doesn't exist!");
                }
            }
        }

        this.sorted_tech = this.technology.keys.dup;
        sort!((a, b) => sort_order!(Technology)(this.technology[a], this.technology[b]))(this.sorted_tech);
    }

    private void map_info_types()
    {
        foreach (string key, ref Recipe r; this.recipes)
        {
            foreach (ref ItemAmount* amt; r.ingredients)
            {
                const Craftable* cft = this.find_craftable(amt.type, amt.name);
                amt.info_type = cft ? cft.type : amt.type;
            }

            foreach (ItemAmount* amt; r.results)
            {
                const Craftable* cft = this.find_craftable(amt.type, amt.name);
                amt.info_type = cft ? cft.type : amt.type;
            }
        }
        foreach (string key, ref Technology t; this.technology)
        {
            foreach (ref ItemAmount* amt; t.unit.ingredients)
            {
                const Craftable* cft = this.find_craftable(amt.type, amt.name);
                amt.info_type = cft ? cft.type : amt.type;
            }
        }
    }

    string resolve_description(const string name)
    {
        string desc;

        if ((desc = this.get_item_description(name)) != null)
        {
            return desc;
        }
        else if ((desc = this.get_entity_description(name)) != null)
        {
            return desc;
        }
        else if ((desc = this.get_technology_description(name)) != null)
        {
            return desc;
        }
        
        return null;
    }

    string get_technology_description(const string name)
    {
        if (this.locale["technology-description"].hasKey(name)) {
            return this.locale["technology-description"].getKey(name);
        }

        return null;
    }

    string get_item_description(const string name)
    {
        if (this.locale["item-description"].hasKey(name)) {
            return this.locale["item-description"].getKey(name);
        }

        return null;
    }

    string get_entity_description(const string name)
    {
        if (this.locale["entity-description"].hasKey(name)) {
            return this.locale["entity-description"].getKey(name);
        }

        return null;
    }

    string resolve_locale_name(const ref BasicEnt ent)
    {
        return this.resolve_locale_name(ent.type, ent.name);
    }

    string resolve_locale_name(const ref ItemAmount* iamt)
    {
        return this.resolve_locale_name(iamt.type, iamt.name);
    }

    protected string resolve_locale_name(const string type, const string name)
    {
        immutable string[] lookup_types = [
            type, "entity", "item", "fluid", "recipe", "technology", "equipment", "tile"
        ];
        string lookup_name = name.toLower;

        foreach (string type_name; lookup_types)
        {
            const string tn = type_name ~ "-name";
            if (this.locale.hasSection(tn) && this.locale[tn].hasKey(lookup_name))
            {
                return this.locale[tn].getKey(lookup_name);
            }
        }

        // attempt string interpolation
        string[] spl = lookup_name.split("-");

        if (spl.length > 1)
        {
            try
            {
                const int level = to!int(spl[spl.length - 1]);
                const string title = resolve_locale_name(type, spl[0 .. spl.length - 1].join("-"));
                return title ~ " " ~ to!string(level);
            }
            catch (ConvException exc)
            {
                // ignore
            }
        }

        return lookup_name;
    }

    string resolve_subgroup_image(const ref string subgroup_name)
    {
        const(ItemSubgroup*) subgroup = subgroup_name in this.item_subgroups;
        if (subgroup)
        {
            return "/pack/" ~this.meta.name ~ "/icon/item-group/" ~ subgroup.group ~ ".png";
        }
        return null;
    }

    Recipe* get_first_recipe_with_ingredients(const Craftable* item)
    {
        // pick the first recipe that requires ingredients
        foreach (const Recipe* r; item.recipes)
        {
            if (r.ingredients.length)
            {
                return cast(Recipe*) r;
            }
        }

        return null;
    }

    Craftable*[] search_craftable(string name, const int limit_results = 25,
        const bool include_title = true)
    {
        name = name.toLower;
        Craftable*[] ret;

        foreach (ref string cat; this.all_items.keys)
        {
            foreach (item; this.all_items[cat])
            {
                if (item.name.toLower.indexOf(name) >= 0 || (include_title
                        && item.title.toLower.indexOf(name) >= 0))
                {
                    ret ~= &this.all_items[cat][item.name];

                    if (ret.length == limit_results)
                    {
                        return ret;
                    }
                }
            }
        }

        return ret;
    }

    Craftable* resolve_craftable(const ref string type, const ref string name)
    {
        if (name in this.items)
        {
            return cast(Craftable*)(name in this.items);
        }
        else if (name in this.fluids)
        {
            return cast(Craftable*)(name in this.fluids);
        }
        else if (type in this.all_items && name in this.all_items[type])
        {
            return name in this.all_items[type];
        }

        return null;
    }

    protected Craftable* find_craftable(const ref string type, const ref string name)
    {
        if (type == "fluid")
        {
            if (name in this.fluids)
            {
                return cast(Craftable*)&this.fluids[name];
            }
        }
        else if (type == "item")
        {
            if (name in this.items)
            {
                return cast(Craftable*)&this.items[name];
            }
        }

        foreach (string category, ref catmap; this.all_items)
        {
            foreach (string key, ref Craftable cft; catmap)
            {
                if (key == name)
                {
                    return &cft;
                }
            }
        }

        return null;
    }

    protected Recipe*[] find_recipes_producing(const ref string type, const ref string name)
    {
        Recipe*[] ret;

        foreach (string rcp_name, ref recipe; this.recipes)
        {
            foreach (ref rslt; recipe.results)
            {
                if ((type != "fluid" || rslt.type == type) && rslt.name == name)
                {
                    ret ~= &this.recipes[rcp_name];
                    break;
                }
            }
        }

        sort!((a, b) => sort_order!(Recipe*)(a, b))(ret);
        return ret;
    }

    protected Recipe*[] find_recipes_using(const ref string type, const ref string name)
    {
        Recipe*[] ret;

        foreach (string rcp_name, ref recipe; this.recipes)
        {
            foreach (ref ingd; recipe.ingredients)
            {
                if ((type != "fluid" || ingd.type == type) && ingd.name == name)
                {
                    ret ~= &this.recipes[rcp_name];
                    break;
                }
            }
        }

        sort!((a, b) => sort_order!(Recipe*)(a, b))(ret);
        return ret;
    }

    public bool sort_order(T)(const(T) a, const(T) b)
    {
        static if (is(T : ItemAmount*)) {
            Craftable* newA = find_craftable(a.info_type, a.name);
            Craftable* newB = find_craftable(b.info_type, b.name);
            return this.sort_order!(Craftable*)(newA, newB);
        }

        static if (__traits(compiles, a.category))
        {
            if (a.category != b.category)
            {
                return a.category < b.category;
            }
        }
        static if (__traits(compiles, a.subgroup))
        {
            if (a.subgroup != b.subgroup)
            {
                return a.subgroup < b.subgroup;
            }
        }
        static if (__traits(compiles, a.order))
        {
            if (a.order != b.order)
            {
                return a.order < b.order;
            }
        }
        static if (__traits(compiles, a.title))
        {
            return a.title < b.title;
        }
    }
}
