<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>

    <!--
            This is the transform from ELAN eaf format into EXMARaLDA exb, tuned for Nganasan project.
            This version is intended for Toolbox-originating files. See interlinear-flexeaf2exmaralda.xsl for conversion from SIL FLEx.
            (c) Alexandre Arkhipov, MSU, 2015

            This is the batch version intended for transforming multiple files at once.

            v1.11: processes all eaf files in the folder specified as parameter
            =======
            v1.10: add so tier; if ft present in source, import it as fe
            v1.09: set tier types: 't' for tx, 'd' for ts
            v1.08: added tiers no,nv,na, also fe if exists. 
                   fixed cleanup-gloss to handle multiple replaces in one string.
            v1.07: renaming md,mb is only performed if not yet done in source (checks if exists 'mp' tier); 
                   supports tier ids with and without @speakername; 
                   rearranged tierformat-table.
            v1.06: insert the tierformat-table (copied a formatting template).
            v1.05: replacing brackets [[ ]] with (( )) in all cleanups;
                   in tx,mb (=renamed old md) only, strip "deep consonant" and "deep glottal stop".
            v1.04: fixed tier order; adding empty word-level tiers # and IST, sentence-level fe.
            v1.03: Rename md>mb, mb>mp; set tier attributes.
            v1.02: no gaps between sentences.
            v1.01: If two time slots have identical values, choose always the first one. The second one should be dropped in common-timeline.
            v1.00: Basic transform, with specific tier text cleanups.

    -->
    <xsl:param name="folder" select="'file:///D:/L-DIGITIZING/EXMARALDA-HAMBURG/todo3/'"/>
    <xsl:param name="filemask" select="'?select=*.eaf'"/>
    <xsl:variable name="sourcecollection" select="collection(concat($folder,$filemask))"/>
    
    <xsl:variable name="tiers-sent">st so ref ts fr fe ft nt no nv na</xsl:variable>
    <xsl:variable name="tiers-word">tx</xsl:variable>
    <xsl:variable name="tiers-morph-top">md mb mp</xsl:variable>
    <xsl:variable name="tiers-morph-ref">gr ge go ps</xsl:variable>

    <xsl:key name="annot" match="ANNOTATION" use="string(*/@ANNOTATION_ID)"/>
    <xsl:key name="timeslot" match="TIME_SLOT" use="./@TIME_SLOT_ID"/>
    <xsl:key name="timevalue" match="TIME_SLOT" use="./@TIME_VALUE"/>
    
    <xsl:template name="main">
        <xsl:for-each select="$sourcecollection">
            <xsl:variable name="filename" select="substring-before(replace(document-uri(current()),'^.+/',''),'.')"/>
            <xsl:result-document method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no" href="{concat($folder,$filename,'.exb')}">
                <basic-transcription>
                    <head>
                        <meta-information>
                            <project-name>Nganasan</project-name>
                            <transcription-name>
                                <xsl:value-of select="$filename"/>
                            </transcription-name>
                            <referenced-file url="{concat($filename,'.wav')}"/>
                            <ud-meta-information/>
                            <comment/>
                            <transcription-convention/>
                        </meta-information>
                        <speakertable>
                            <speaker id="SPK_unknown">
                                <abbreviation>SPK</abbreviation>
                                <sex value="m"/>
                                <languages-used/>
                                <l1/>
                                <l2/>
                                <ud-speaker-information> </ud-speaker-information>
                                <comment/>
                            </speaker>
                        </speakertable>
                    </head>
                    <basic-body>
                        <common-timeline>
                            <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIME_ORDER"/>
                            <!-- here go the time slots -->
                        </common-timeline>
                        
                        <!-- Here go the tiers. The output order is fixed. -->
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'ref')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'st')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'so')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'ts')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'tx')]"/>
                        
                        <!-- v1.07: renaming md,mb is only performed if not yet done in source (checks if exists 'mp' tier) -->
                        <xsl:choose>
                            <xsl:when test="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'mp')]">
                                <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'mb')]"/>
                                <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'mp')]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'md')]">
                                    <xsl:with-param name="rename" select="'yes'"/>
                                </xsl:apply-templates>
                                <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'mb')]">
                                    <xsl:with-param name="rename" select="'yes'"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'gr')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'ge')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'go')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'ps')]">
                            <!-- v1.04: adding empty word-level tiers # and IST -->
                            <xsl:with-param name="addtier" select="'# IST'"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'fr')]">
                            <xsl:with-param name="addtier"
                                select="if(/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'fe') or starts-with(@TIER_ID,'ft')]) then '' else 'fe'"/>
                            <!-- v1.04: adding empty copy for English translation -->
                            <!-- v1.08-1.09: ...only if fe or ft not present in the source -->
                        </xsl:apply-templates>
                        <!-- v1.08: added fe -->
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'fe')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'ft')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'nt')]"/>
                        <!-- v1.08: added no, nv, na -->
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'no')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'nv')]"/>
                        <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER[starts-with(@TIER_ID,'na')]"/>
                    </basic-body>
                    <!-- v1.06: insert the tierformat-table (copied a formatting template) -->
                    <xsl:copy-of select="$format-table"/>
                </basic-transcription>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>


    <xsl:template
        match="TIER[contains($tiers-sent,if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID)]">
        <!-- sentence-level tiers -->
        <!-- type "d" (v1.09: for all); start/end as is -->
        <!-- v1.04: adding empty copy of fr for English translation -->
        <xsl:param name="addtier" select="''"/>
        <xsl:variable name="tiername">
            <!-- v1.10: always rename ft to fe -->
            <xsl:variable name="origtiername"
                select="if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID"/>
            <xsl:value-of select="if ($origtiername = 'ft') then 'fe' else $origtiername"/>
        </xsl:variable>
        <xsl:variable name="maintier">
            <tier id="{$tiername}" speaker="SPK_unknown" category="{$tiername}" type="d" display-name="{$tiername}">
                <xsl:for-each select="*">
                    <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/>
                    <xsl:variable name="ts-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                    <xsl:variable name="ts-end">
                        <xsl:value-of
                            select="if ($aligned-ann/following-sibling::*[1]) then $aligned-ann/following-sibling::*[1]/*/@TIME_SLOT_REF1 else $aligned-ann/*/@TIME_SLOT_REF2"/>
                        <!-- v1.02: sentence must end where next sentence starts (not earlier) -->
                    </xsl:variable>
                    <xsl:variable name="ts-start-first"
                        select="key('timevalue',key('timeslot',$ts-start)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                    <xsl:variable name="ts-end-first"
                        select="key('timevalue',key('timeslot',$ts-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                    <!-- v1.01: If two time slots have identical values, choose always the first one. The second one should be dropped in common-timeline. -->
                    <!-- Otherwise EXMARALDA complains there are overlapping intervals -->

                    <event start="{$ts-start-first}" end="{$ts-end-first}">
                        <ud-information attribute-name="ELAN-ID">
                            <xsl:value-of select="./*/@ANNOTATION_ID"/>
                        </ud-information>
                        <ud-information attribute-name="ELAN-REF">
                            <xsl:value-of select="./*/@ANNOTATION_REF"/>
                        </ud-information>
                        <ud-information attribute-name="ELAN-PREV">
                            <xsl:value-of select="./*/@PREVIOUS_ANNOTATION"/>
                        </ud-information>
                        <xsl:value-of select="my:cleanup-ts(./*/ANNOTATION_VALUE)"/>
                    </event>
                </xsl:for-each>
            </tier>
        </xsl:variable>
        <xsl:copy-of select="$maintier"/>

        <!-- v1.04: adding empty copy of fr for English translation -->
        <xsl:if test="$addtier != ''">
            <tier id="{$addtier}" speaker="SPK_unknown" category="{$addtier}" type="d" display-name="{$addtier}">
                <xsl:for-each select="$maintier/tier/*">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                    </xsl:copy>
                </xsl:for-each>
            </tier>
        </xsl:if>
    </xsl:template>


    <xsl:template
        match="TIER[contains($tiers-word,if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID)]">
        <!-- word-level tiers (normally only tx) -->
        <!-- type "t" (v1.09), INSERT NEW start/end -->
        <xsl:variable name="tiername"
            select="if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID"/>
        <tier id="{$tiername}" speaker="SPK_unknown" category="{$tiername}" type="t" display-name="{$tiername}">
            <xsl:for-each-group select="*" group-by="./*/@ANNOTATION_REF">
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/>
                <!-- The aligned annotation which dominates the current one  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                <!-- start/end time slot ids -->
                <xsl:variable name="sent-end">
                    <xsl:value-of
                        select="if ($aligned-ann/following-sibling::*[1]) then $aligned-ann/following-sibling::*[1]/*/@TIME_SLOT_REF1 else $aligned-ann/*/@TIME_SLOT_REF2"/>
                    <!-- v1.02: sentence must end where next sentence starts (not earlier) -->
                </xsl:variable>
                <xsl:variable name="sent-start-first"
                    select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <xsl:variable name="sent-end-first"
                    select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical values, FIX 1.01: choose always the first one. The second one should be dropped in common-timeline. -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                <xsl:variable name="tsnumber" select="count(./preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->

                <xsl:for-each select="current-group()">
                    <xsl:variable name="word-start">
                        <xsl:value-of
                            select="if (position()=1) then $sent-start-first else concat('T',$tsnumber+position()-1)"/>
                    </xsl:variable>
                    <xsl:variable name="word-end">
                        <xsl:value-of
                            select="if (position()=last()) then $sent-end-first else concat('T',$tsnumber+position())"/>
                    </xsl:variable>
                    <event start="{$word-start}" end="{$word-end}">
                        <xsl:value-of select="my:cleanup-tx(./*/ANNOTATION_VALUE)"/>
                    </event>
                </xsl:for-each>
            </xsl:for-each-group>
        </tier>
    </xsl:template>


    <xsl:template
        match="TIER[contains($tiers-morph-top,if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID)]">
        <xsl:param name="rename" select="'no'"/>
        <!-- standalone morph-level tiers (mb, md) -->
        <!-- type "a", stick together for each word -->
        <!-- v1.03: Rename md>mb, mb>mp; set attributes -->
        <!-- v1.07: renaming md,mb is only performed if not yet done in source (checks if exists 'mp' tier) -->
        <xsl:variable name="tiername"
            select="if ($rename='no') then (if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID) else if (starts-with(./@TIER_ID,'md')) then 'mb' else 'mp'"/>
        <tier id="{$tiername}" speaker="SPK_unknown" category="v" type="a" display-name="{$tiername}">
            <xsl:for-each-group select="*" group-by="key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF">
                <!-- should result in grouping by sentence -->
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/>
                <!-- The aligned annotation which dominates the current one  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                <!-- start/end time slot ids -->
                <xsl:variable name="sent-end">
                    <xsl:value-of
                        select="if ($aligned-ann/following-sibling::*[1]) then $aligned-ann/following-sibling::*[1]/*/@TIME_SLOT_REF1 else $aligned-ann/*/@TIME_SLOT_REF2"/>
                    <!-- v1.02: sentence must end where next sentence starts (not earlier) -->
                </xsl:variable>
                <xsl:variable name="sent-start-first"
                    select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <xsl:variable name="sent-end-first"
                    select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical values, FIX 1.01: choose always the first one. The second one should be dropped in common-timeline. -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                <xsl:variable name="tsnumber"
                    select="count(key('annot',./*/@ANNOTATION_REF)/preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->

                <xsl:for-each-group select="current-group()" group-by="./*/@ANNOTATION_REF">
                    <!-- This is grouping by word -->
                    <xsl:variable name="word-start">
                        <xsl:value-of
                            select="if (position()=1) then $sent-start-first else concat('T',$tsnumber+position()-1)"/>
                    </xsl:variable>
                    <xsl:variable name="word-end">
                        <xsl:value-of
                            select="if (position()=last()) then $sent-end-first else concat('T',$tsnumber+position())"/>
                    </xsl:variable>
                    <event start="{$word-start}" end="{$word-end}">
                        <xsl:value-of
                            select="my:cleanup-morph(string-join(current-group()/*/ANNOTATION_VALUE,''),$tiername)"/>
                    </event>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </tier>
    </xsl:template>


    <xsl:template
        match="TIER[contains($tiers-morph-ref,if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID)]">
        <!-- referring morph-level tiers (gr, ge, go, ps) -->
        <!-- type "a", stick together for each word -->
        <!-- v1.04: adding empty word-level tiers # and IST -->
        <xsl:param name="addtier" select="''"/>
        <xsl:variable name="tiername"
            select="if (contains(@TIER_ID,'@')) then substring-before(@TIER_ID,'@') else @TIER_ID"/>
        <xsl:variable name="maintier">
            <tier id="{$tiername}" speaker="SPK_unknown"
                category="{if (starts-with(./@TIER_ID,'g')) then 'v' else $tiername}" type="a"
                display-name="{$tiername}">
                <xsl:for-each-group select="*"
                    group-by="key('annot',key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF)/*/@ANNOTATION_REF">
                    <!-- should result in grouping by sentence -->
                    <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/>
                    <!-- The aligned annotation which dominates the current one  -->
                    <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                    <!-- start/end time slot ids -->
                    <xsl:variable name="sent-end">
                        <xsl:value-of
                            select="if ($aligned-ann/following-sibling::*[1]) then $aligned-ann/following-sibling::*[1]/*/@TIME_SLOT_REF1 else $aligned-ann/*/@TIME_SLOT_REF2"/>
                        <!-- v1.02: sentence must end where next sentence starts (not earlier) -->
                    </xsl:variable>
                    <xsl:variable name="sent-start-first"
                        select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                    <xsl:variable name="sent-end-first"
                        select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                    <!-- If two time slots have identical values, FIX 1.01: choose always the first one. The second one should be dropped in common-timeline. -->
                    <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                    <xsl:variable name="tsnumber"
                        select="count(key('annot',key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF)/preceding-sibling::*)-position()"/>
                    <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->

                    <xsl:for-each-group select="current-group()"
                        group-by="key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF">
                        <!-- This is grouping by word -->
                        <xsl:variable name="word-start">
                            <xsl:value-of
                                select="if (position()=1) then $sent-start-first else concat('T',$tsnumber+position()-1)"
                            />
                        </xsl:variable>
                        <xsl:variable name="word-end">
                            <xsl:value-of
                                select="if (position()=last()) then $sent-end-first else concat('T',$tsnumber+position())"
                            />
                        </xsl:variable>
                        <event start="{$word-start}" end="{$word-end}">
                            <xsl:value-of select="my:cleanup-gloss(string-join(current-group()/*/ANNOTATION_VALUE,''))"
                            />
                        </event>
                    </xsl:for-each-group>
                </xsl:for-each-group>
            </tier>
        </xsl:variable>
        <xsl:copy-of select="$maintier"/>

        <!-- v1.04: adding empty word-level tiers # and IST -->
        <xsl:if test="$addtier !=''">
            <xsl:for-each select="tokenize($addtier,'\s+')">
                <tier id="{current()}" speaker="SPK_unknown" category="v" type="a" display-name="{current()}">
                    <xsl:for-each select="$maintier/tier/*">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                        </xsl:copy>
                    </xsl:for-each>
                </tier>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template match="TIME_ORDER">
        <xsl:variable name="ts-original">
            <xsl:for-each-group select="TIME_SLOT" group-by="./@TIME_VALUE">
                <tli id="{current-group()[1]/@TIME_SLOT_ID}" time="{my:sec2msec(current-group()[1]/@TIME_VALUE)}"
                    type="appl"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="ts-supplemental">
            <xsl:for-each-group select="/*/TIER[starts-with(@TIER_ID,'tx')]/*" group-by="REF_ANNOTATION/@ANNOTATION_REF">
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(current-group()[1]))"/>
                <!-- The aligned annotation which dominates the current one, i.e. the sentence annotation  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                <!-- sentence start/end time slot ids -->
                <xsl:variable name="sent-end">
                    <xsl:value-of
                        select="if ($aligned-ann/following-sibling::*[1]) then $aligned-ann/following-sibling::*[1]/*/@TIME_SLOT_REF1 else $aligned-ann/*/@TIME_SLOT_REF2"/>
                    <!-- v1.02: sentence must end where next sentence starts (not earlier) -->
                </xsl:variable>
                <xsl:variable name="sent-start-first"
                    select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- first/last time slots with identical values -->
                <xsl:variable name="sent-end-first"
                    select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>

                <xsl:variable name="sent-start-time" as="xs:decimal"
                    select="my:sec2msec(key('timeslot',$sent-start)/@TIME_VALUE)"/>
                <!-- actual sentence start/end time values -->
                <xsl:variable name="sent-end-time" as="xs:decimal"
                    select="my:sec2msec(key('timeslot',$sent-end)/@TIME_VALUE)"/>
                <xsl:variable name="time-step" as="xs:decimal"
                    select="($sent-end-time - $sent-start-time) div count(current-group())"/>
                <xsl:variable name="tsnumber" select="count(./preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->

                <xsl:for-each select="current-group()[position()!=last()]">
                    <tli id="{concat('T',$tsnumber+position())}" time="{$sent-start-time + $time-step * position()}"/>
                </xsl:for-each>
            </xsl:for-each-group>
        </xsl:variable>

        <xsl:perform-sort select="$ts-original/tli, $ts-supplemental/tli">
            <xsl:sort select="xs:decimal(./@time)"/>
        </xsl:perform-sort>
    </xsl:template>

    <xsl:function name="my:find-aligned-ann">
        <xsl:param name="ann"/>
        <xsl:for-each select="$ann/ancestor::ANNOTATION_DOCUMENT">
            <xsl:choose>
                <xsl:when test="$ann/*/name()='ALIGNABLE_ANNOTATION'">
                    <xsl:value-of select="$ann/*/@ANNOTATION_ID"/>
                </xsl:when>
                <xsl:when test="$ann/*/name()='REF_ANNOTATION'">
                    <xsl:variable name="parent-ann" select="key('annot',$ann/*/@ANNOTATION_REF)"/>
                    <xsl:value-of select="my:find-aligned-ann($parent-ann)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <!-- v1.05: replacing brackets [[ ]] with (( )) in all cleanups -->

    <xsl:function name="my:cleanup-ts" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="my:cleanup-brackets($in)"/>
    </xsl:function>

    <xsl:function name="my:cleanup-tx" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of
            select="concat(replace(replace(my:cleanup-brackets($in),'( +$)|[ˀ]',''),'[03]([\.,!\?;:]*)$','$1'),' ')"/>
        <!-- strip trailing space, strip final 0 and 3, attach one space -->
        <!-- v1.05: strip "deep consonant" and "deep glottal stop" -->
    </xsl:function>

    <xsl:function name="my:cleanup-morph" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:param name="tiername" as="xs:string"/>
        <xsl:variable name="bothtiers" select="replace(my:cleanup-brackets($in),'-[03]$','')"/>
        <!-- strip final -0 and -3 -->
        <xsl:value-of
            select="if ($tiername='mb') then replace(replace($bothtiers,'([ˀ]|-[ˀ]$)',''),'--','-') else $bothtiers"/>
        <!-- v1.05: in mb (=renamed old md, and it is the new name this function will get) only, strip "deep consonant" and "deep glottal stop" -->
        <!-- v1.07: also strip final '-' -->
    </xsl:function>

    <xsl:function name="my:cleanup-gloss" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(my:cleanup-brackets($in),'-(\[.+?\])','.$1')"/>
        <!-- replace - with . before [] -->
        <!-- v1.08: fixed to lazy quant. to handle multiple replaces in one string -->
    </xsl:function>

    <!-- v1.05: replacing brackets [[ ]] with (( )) for all tiers -->
    <xsl:function name="my:cleanup-brackets" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:variable name="temp" select="replace(replace($in,'\[\[', '(('), '\]\]', '))')"/>
        <!-- replace [[, ]] with ((, )) -->
        <xsl:value-of select="replace($temp,'///','((unint))')"/>
        <!-- replace /// with ((unint)) -->
    </xsl:function>

    <xsl:function name="my:sec2msec">
        <xsl:param name="time-sec"/>
        <xsl:value-of select="replace($time-sec, '([0-9]{3})$', '.$1')"/>
    </xsl:function>

    <!-- v1.06: insert the tierformat-table (copied a formatting template) -->
    <xsl:variable name="format-table">
        <tierformat-table>
            <timeline-item-format show-every-nth-numbering="1" show-every-nth-absolute="1" absolute-time-format="time"
                miliseconds-digits="1"/>
            <tier-format tierref="ref">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="st">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Bold</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="so">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Bold</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ts">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#R00G99B33</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="tx">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#R00G00Bcc</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="mb">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="md">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="mp">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="gr">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ge">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="go">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ps">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="#">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="IST">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="fr">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#RccG00B00</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="fe">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="nt">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="no">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="nv">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="na">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="COLUMN-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">blue</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="TIE3">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="TIE2">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">9</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="TIE1">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="TIE0">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="SUB-ROW-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Right</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">8</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="ROW-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Bold</property>
                <property name="font-color">blue</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="EMPTY-EDITOR">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">white</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">lightGray</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">2</property>
                <property name="font-name">Charis </property>
            </tier-format>
            <tier-format tierref="EMPTY">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">white</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">2</property>
                <property name="font-name">Charis</property>
            </tier-format>
        </tierformat-table>
    </xsl:variable>
</xsl:stylesheet>
