-- Exploration government text is loaded in a dedicated late action so the
-- base Age-specific Culture and Golden Age localization cannot overwrite it.
INSERT OR REPLACE INTO LocalizedText (Language, Tag, Text) VALUES
    ("en_US", "LOC_TRADITION_MAHAKRUNG_DESCRIPTION", "[B]+10 [icon:YIELD_CULTURE] Culture, [icon:YIELD_PRODUCTION] Production, and [icon:YIELD_GOLD] Gold[/B] in your [icon:NOTIFICATION_SELECT_CAPITAL] [TIP:LOC_PEDIA_CONCEPTS_CAPITAL_TOOLTIP]Capital[/TIP], or +15 if Joyous, or +20 if Ecstatic."),
    ("en_US", "LOC_GOVERNMENT_PLUTOCRACY_PASSIVE_DESCRIPTION", "[B]+30% [icon:YIELD_PRODUCTION] Production[/B] towards Overbuilding."),
    ("en_US", "LOC_GOLDEN_AGE_PLUTOCRACY_2_DESCRIPTION", "Create a [icon:UNIT_MIGRANT] Migrant in the [icon:NOTIFICATION_SELECT_CAPITAL] [TIP:LOC_PEDIA_CONCEPTS_CAPITAL_TOOLTIP]Capital[/TIP]."),
    ("en_US", "LOC_TRADITION_TEQUITL_DESCRIPTION", "+10 [TIP:LOC_PEDIA_CONCEPTS_TRADE_RANGE_TOOLTIP]Trade Range[/TIP]. [B]+1 [icon:YIELD_SCIENCE] Science[/B] for every imported [icon:RADIAL_RESOURCES] [TIP:LOC_PEDIA_CONCEPTS_RESOURCES_TOOLTIP]Resource[/TIP]."),
    ("en_US", "LOC_GOVERNMENT_THEOCRACY_PASSIVE_DESCRIPTION", "[B]+30% [icon:YIELD_PRODUCTION] Production[/B] and [B][icon:YIELD_GOLD] Gold[/B] towards constructing or purchasing Temples and Missionaries."),
    ("en_US", "LOC_GOLDEN_AGE_THEOCRACY_2_DESCRIPTION", "Missionaries gain +1 [icon:Action_Move] Movement and ignore movement penalties from Rough and Vegetated terrain for {1_numTurns} Turn(s)."),
    ("en_US", "LOC_TRADITION_DARGAH_DESCRIPTION", "[B]+4 [icon:YIELD_FOOD] Food[/B] and [B][icon:YIELD_HAPPINESS] Happiness[/B] in [icon:YIELD_TOWNS] [TIP:LOC_PEDIA_CONCEPTS_TOWN_TOOLTIP]Towns[/TIP] following your [icon:NAR_REW_RELIGION] [TIP:LOC_PEDIA_CONCEPTS_RELIGION_TOOLTIP]Religion[/TIP]."),
    ("en_US", "LOC_TRADITION_VINAYA_DESCRIPTION", "[B]+5 [icon:YIELD_GOLD] Gold[/B] and [B]+2 [icon:YIELD_DIPLOMACY] Influence[/B] in [icon:YIELD_CITIES] [TIP:LOC_PEDIA_CONCEPTS_CITIES_TOOLTIP]Cities[/TIP] following your [icon:NAR_REW_RELIGION] [TIP:LOC_PEDIA_CONCEPTS_RELIGION_TOOLTIP]Religion[/TIP].");
