<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>

    <xsl:variable name="tiers-sent">st ref ts fr nt</xsl:variable>
    <xsl:variable name="tiers-word">tx</xsl:variable>
    <xsl:variable name="tiers-morph-top">md mb</xsl:variable>
    <xsl:variable name="tiers-morph-ref">gr ge go ps</xsl:variable>
    
    <xsl:key name="annot" match="ANNOTATION" use="string(*/@ANNOTATION_ID)"/>
    <xsl:key name="timeslot" match="TIME_SLOT" use="./@TIME_SLOT_ID"/>    
    <xsl:key name="timevalue" match="TIME_SLOT" use="./@TIME_VALUE"/>    
    
    <xsl:template match="/">
        <basic-transcription>
            <head>
                <meta-information>
                    <project-name>Nganasan</project-name>
                    <transcription-name>21_SY-08_hibula</transcription-name>
                    <referenced-file url="21_SY-08_hibula.wav"/>
                    <ud-meta-information/>
                    <comment/>
                    <transcription-convention/>
                </meta-information>
                <speakertable>
                    <speaker id="SPK_unknown">
                        <abbreviation>SY</abbreviation>
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
                    <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIME_ORDER" />
                    <!-- here go the time slots -->
                </common-timeline>
                
                <xsl:apply-templates select="/ANNOTATION_DOCUMENT/TIER" />
                <!--
                <tier id="ref@unknown" speaker="SPK_unknown" category="ref" type="d" display-name="ref">
                    <ud-tier-information>
                        <ud-information attribute-name="ELAN-TimeAlignable">false</ud-information>
                        <ud-information attribute-name="ELAN-Constraints">Symbolic_Association</ud-information>
                        <ud-information attribute-name="ELAN-ParentRef">st@unknown</ud-information>
                        <ud-information attribute-name="ELAN-DependencyLevel">1</ud-information>
                    </ud-tier-information>
                    <event start="ts1" end="ts3"><ud-information attribute-name="ELAN-ID">ann1</ud-information><ud-information
                        attribute-name="ELAN-REF">ann0</ud-information><ud-information attribute-name="ELAN-PREV"
                        />ChNS-080302_wife.001</event>
                    -->
                    
            </basic-body>
        </basic-transcription>
    </xsl:template>
    
    <xsl:template match="TIER[contains($tiers-sent,substring-before(@TIER_ID,'@'))]">
        <!-- sentence-level tiers -->
        <!-- type "d", start/end as is -->
        <tier id="{substring-before(@TIER_ID,'@')}" speaker="{if (./@PARTICIPANT) then ./@PARTICIPANT else 'SPK'}" category="{./@LINGUISTIC_TYPE_REF}" type="d" display-name="{substring-before(@TIER_ID,'@')}">
            <xsl:for-each select="*">
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/> 
                <xsl:variable name="ts-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>
                <xsl:variable name="ts-end" select="$aligned-ann/*/@TIME_SLOT_REF2"/>
                <xsl:variable name="ts-start-right" select="key('timevalue',key('timeslot',$ts-start)/@TIME_VALUE)[last()]/@TIME_SLOT_ID"/>
                <xsl:variable name="ts-end-left" select="key('timevalue',key('timeslot',$ts-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical values, choose always right one for start border and left one for end border -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                
                <event start="{$ts-start-right}" end="{$ts-end-left}">
                    <ud-information attribute-name="ELAN-ID"><xsl:value-of select="./*/@ANNOTATION_ID"/></ud-information>
                    <ud-information attribute-name="ELAN-REF"><xsl:value-of select="./*/@ANNOTATION_REF"/></ud-information>
                    <ud-information attribute-name="ELAN-PREV"><xsl:value-of select="./*/@PREVIOUS_ANNOTATION"/></ud-information><xsl:value-of select="./*/ANNOTATION_VALUE"/></event>
            </xsl:for-each>
        </tier>
    </xsl:template>


    <xsl:template match="TIER[contains($tiers-word,substring-before(@TIER_ID,'@'))]">
        <!-- word-level tiers (normally only tx) -->
        <!-- type "t", INSERT NEW start/end -->
        <tier id="{substring-before(@TIER_ID,'@')}" speaker="{if (./@PARTICIPANT) then ./@PARTICIPANT else 'SPK'}" category="{./@LINGUISTIC_TYPE_REF}" type="t" display-name="{substring-before(@TIER_ID,'@')}">
            <xsl:for-each-group select="*" group-by="./*/@ANNOTATION_REF">
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/> <!-- The aligned annotation which dominates the current one  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>   <!-- start/end time slot ids -->
                <xsl:variable name="sent-end" select="$aligned-ann/*/@TIME_SLOT_REF2"/>     <!-- start/end time slot ids -->
                <xsl:variable name="sent-start-right" select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[last()]/@TIME_SLOT_ID"/>
                <xsl:variable name="sent-end-left" select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical time values, choose always right one for start border and left one for end border -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                <xsl:variable name="tsnumber" select="count(./preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->
                
                <xsl:for-each select="current-group()">
                    <xsl:variable name="word-start"><xsl:value-of select="if (position()=1) then $sent-start-right else concat('T',$tsnumber+position()-1)"/></xsl:variable>
                    <xsl:variable name="word-end"><xsl:value-of select="if (position()=last()) then $sent-end-left else concat('T',$tsnumber+position())"/></xsl:variable>
                    <event start="{$word-start}" end="{$word-end}"><xsl:value-of select="my:cleanup-tx(./*/ANNOTATION_VALUE)"/> </event>
                </xsl:for-each>
            </xsl:for-each-group>
        </tier>
    </xsl:template>
    

    <xsl:template match="TIER[contains($tiers-morph-top,substring-before(@TIER_ID,'@'))]">
        <!-- standalone morph-level tiers (mb, md) -->
        <!-- type "a", stick together for each word -->
        <tier id="{substring-before(@TIER_ID,'@')}" speaker="{if (./@PARTICIPANT) then ./@PARTICIPANT else 'SPK'}" category="{./@LINGUISTIC_TYPE_REF}" type="a" display-name="{substring-before(@TIER_ID,'@')}">
            <xsl:for-each-group select="*" group-by="key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF"> <!-- should result in grouping by sentence -->
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/> <!-- The aligned annotation which dominates the current one  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>   <!-- start/end time slot ids -->
                <xsl:variable name="sent-end" select="$aligned-ann/*/@TIME_SLOT_REF2"/>     <!-- start/end time slot ids -->
                <xsl:variable name="sent-start-right" select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[last()]/@TIME_SLOT_ID"/>
                <xsl:variable name="sent-end-left" select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical time values, choose always right one for start border and left one for end border -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                <xsl:variable name="tsnumber" select="count(key('annot',./*/@ANNOTATION_REF)/preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->
                
                <xsl:for-each-group select="current-group()" group-by="./*/@ANNOTATION_REF"> <!-- This is grouping by word -->
                    <xsl:variable name="word-start"><xsl:value-of select="if (position()=1) then $sent-start-right else concat('T',$tsnumber+position()-1)"/></xsl:variable>
                    <xsl:variable name="word-end"><xsl:value-of select="if (position()=last()) then $sent-end-left else concat('T',$tsnumber+position())"/></xsl:variable>
                    <event start="{$word-start}" end="{$word-end}"><xsl:value-of select="my:cleanup-morph(string-join(current-group()/*/ANNOTATION_VALUE,''))"/> </event>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </tier>
    </xsl:template>
    
    
    <xsl:template match="TIER[contains($tiers-morph-ref,substring-before(@TIER_ID,'@'))]">
        <!-- referring morph-level tiers (gr, ge, go, ps) -->
        <!-- type "a", stick together for each word -->
        <tier id="{substring-before(@TIER_ID,'@')}" speaker="{if (./@PARTICIPANT) then ./@PARTICIPANT else 'SPK'}" category="{./@LINGUISTIC_TYPE_REF}" type="a" display-name="{substring-before(@TIER_ID,'@')}">
            <xsl:for-each-group select="*" group-by="key('annot',key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF)/*/@ANNOTATION_REF"> <!-- should result in grouping by sentence -->
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(.))"/> <!-- The aligned annotation which dominates the current one  -->
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/>   <!-- start/end time slot ids -->
                <xsl:variable name="sent-end" select="$aligned-ann/*/@TIME_SLOT_REF2"/>     <!-- start/end time slot ids -->
                <xsl:variable name="sent-start-right" select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[last()]/@TIME_SLOT_ID"/>
                <xsl:variable name="sent-end-left" select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
                <!-- If two time slots have identical time values, choose always right one for start border and left one for end border -->
                <!-- Otherwise EXMARALDA complains there are overlapping intervals -->
                <xsl:variable name="tsnumber" select="count(key('annot',key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF)/preceding-sibling::*)-position()"/>
                <!-- M.Kay: "At this level, the context item is the initial item of the group being processed, and position() and last() refer to the position of this item in a list that contains the initial item of each group, in processing order." -->
                
                <xsl:for-each-group select="current-group()" group-by="key('annot',./*/@ANNOTATION_REF)/*/@ANNOTATION_REF"> <!-- This is grouping by word -->
                    <xsl:variable name="word-start"><xsl:value-of select="if (position()=1) then $sent-start-right else concat('T',$tsnumber+position()-1)"/></xsl:variable>
                    <xsl:variable name="word-end"><xsl:value-of select="if (position()=last()) then $sent-end-left else concat('T',$tsnumber+position())"/></xsl:variable>
                    <event start="{$word-start}" end="{$word-end}"><xsl:value-of select="my:cleanup-gloss(string-join(current-group()/*/ANNOTATION_VALUE,''))"/> </event>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </tier>
    </xsl:template>
    
    
    <xsl:template match="TIME_ORDER">
        <xsl:variable name="ts-original">
            <xsl:for-each select="TIME_SLOT">
                <tli id="{./@TIME_SLOT_ID}" time="{my:sec2msec(./@TIME_VALUE)}" type="appl"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="ts-supplemental">
            <xsl:for-each-group select="/*/TIER[substring-before(@TIER_ID,'@')='tx']/*" group-by="REF_ANNOTATION/@ANNOTATION_REF">
                <xsl:variable name="aligned-ann" select="key('annot',my:find-aligned-ann(current-group()[1]))"/>  <!-- The aligned annotation which dominates the current one, i.e. the sentence annotation  --> 
                <xsl:variable name="sent-start" select="$aligned-ann/*/@TIME_SLOT_REF1"/> <!-- sentence start/end time slot ids -->
                <xsl:variable name="sent-end" select="$aligned-ann/*/@TIME_SLOT_REF2"/>
                <xsl:variable name="sent-start-right" select="key('timevalue',key('timeslot',$sent-start)/@TIME_VALUE)[last()]/@TIME_SLOT_ID"/> <!-- first/last time slots with identical values -->
                <xsl:variable name="sent-end-left" select="key('timevalue',key('timeslot',$sent-end)/@TIME_VALUE)[1]/@TIME_SLOT_ID"/>
    
                <xsl:variable name="sent-start-time" as="xs:decimal" select="my:sec2msec(key('timeslot',$sent-start)/@TIME_VALUE)"/> <!-- actual sentence start/end time values -->
                <xsl:variable name="sent-end-time" as="xs:decimal" select="my:sec2msec(key('timeslot',$sent-end)/@TIME_VALUE)"/>
                <xsl:variable name="time-step" as="xs:decimal" select="($sent-end-time - $sent-start-time) div count(current-group())"></xsl:variable>
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
                    <xsl:variable name="parent-ann" select="key('annot',$ann/*/@ANNOTATION_REF)"></xsl:variable>
                    <xsl:value-of select="my:find-aligned-ann($parent-ann)"></xsl:value-of>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="my:cleanup-tx" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="concat(replace(replace($in,' +$',''),'[03]([\.,!\?;:]*)$','$1'),' ')"/>
        <!-- strip trailing space, strip final 0 and 3, attach one space -->
    </xsl:function>

    <xsl:function name="my:cleanup-morph" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'-[03]$','')"/>
        <!-- strip final -0 and -3 -->
    </xsl:function>
    
    <xsl:function name="my:cleanup-gloss" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'-(\[.+\])','.$1')"/>
        <!-- strip trailing space, strip final 0 and 3, attach one space -->
    </xsl:function>
    
    <xsl:function name="my:sec2msec">
        <xsl:param name="time-sec"/>
        <xsl:value-of select="replace($time-sec, '([0-9]{3})$', '.$1')" />
    </xsl:function>

</xsl:stylesheet>
