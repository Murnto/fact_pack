module fact_pack.types.item_subgroup;

import jsonizer;

import fact_pack.all_types;

class ItemSubgroup : BasicEnt
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize
    {
        string group;
    }
}