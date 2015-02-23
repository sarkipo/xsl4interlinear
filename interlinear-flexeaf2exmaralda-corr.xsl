<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>

    <xsl:param name="timestart" as="xs:decimal" select="4.0"/> <!-- Time offset for first word -->
    <xsl:param name="timestep" as="xs:decimal" select="0.5"/> <!-- Mean word length in sec -->
    
    <xsl:template match="/">
        <basic-transcription>
            <head>
                <meta-information>
                    <project-name>Nganasan</project-name>
                    <transcription-name><xsl:value-of select="/*/*/item[@type='title'][1]"/></transcription-name>
                    <referenced-file url="{concat(/*/*/item[@type='title'][1],'.wav')}"/>
                    <ud-meta-information/>
                    <comment><xsl:value-of select="/*/*/item[@type='comment']"/></comment>
                    <transcription-convention/>
                </meta-information>
                <speakertable>
                    <speaker id="SPK_unknown">
                        <abbreviation>SPK</abbreviation>
                        <sex value="m"/>
                        <languages-used/>
                        <l1/>
                        <l2/>
                        <ud-speaker-information><xsl:text> </xsl:text></ud-speaker-information>
                        <comment/>
                    </speaker>
                </speakertable>
            </head>
            <basic-body>
                <common-timeline>
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="tsnumber" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <tli id="{concat('T',$tsnumber)}" time="{format-number($timestart + $timestep*$tsnumber, '#0.0##')}" type="appl"/>
                        <xsl:for-each select="current()//word[item/@type!='punct']">
                            <tli id="{concat('T',$tsnumber+position())}" time="{format-number($timestart + $timestep*($tsnumber+position()),'#0.0##')}" type="appl"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </common-timeline>
                
                <!-- SEGNUM - PHRASE NUMBERS -->
                <tier  id="segnum-en" speaker="SPK_unknown" category="ref" type="d" display-name="ref">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='segnum' and @lang='en']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- FULL SENTENCE TEXT in LATIN transcription -->
                <tier id="phrase-txt-nio-lat" speaker="SPK_unknown" category="txt" type="t" display-name="txt-nio-lat">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='lit' and @lang='nio-x-lat']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- FULL SENTENCE TEXT in CYRILLIC transcription -->
                <tier id="phrase-txt-nio-cyr" speaker="SPK_unknown" category="txt" type="t" display-name="txt-nio-cyr">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='lit' and @lang='nio-x-cyr']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- SENTENCE FREE TRANSLATION in ENGLISH -->
                <tier id="phrase-ft-en" speaker="SPK_unknown" category="ft" type="d" display-name="ft-en">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='gls' and @lang='en']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- SENTENCE FREE TRANSLATION in RUSSIAN -->
                <tier id="phrase-ft-ru" speaker="SPK_unknown" category="ft" type="d" display-name="ft-ru">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='gls' and @lang='ru']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- SENTENCE NOTES -->
                <tier id="phrase-note" speaker="SPK_unknown" category="nt" type="d" display-name="nt">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <xsl:if test="./item[@type='note']">
                            <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                                <xsl:value-of select="./item[@type='note']" separator=" || "></xsl:value-of>
                            </event>
                        </xsl:if>
                    </xsl:for-each>
                </tier>
                
                <!-- NOW WORD-LEVEL -->                
                <!-- WORD TRANSCRIPTION (~TX) -->
                <tier id="word-txt" speaker="SPK_unknown" category="txt" type="t" display-name="tx">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()/item[@type='txt' or @type='punct']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-tx($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                <!-- FIRST MORPH-LEVEL -->                
                <!-- MORPH SURFACE FORM (~MD) -->
                <tier id="morph-txt" speaker="SPK_unknown" category="txt" type="a" display-name="md">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='txt']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                <!-- OTHER MORPH-LEVELS -->                
                <!-- MORPH UNDERLYING FORM (~MB) -->
                <tier id="morph-cf" speaker="SPK_unknown" category="txt" type="a" display-name="mb">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='cf']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                
                <!-- GLOSS in ENGLISH (~GE) -->
                <tier id="gloss-en" speaker="SPK_unknown" category="gls" type="a" display-name="gls-en">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='gls' and @lang='en']" separator="-"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-gloss($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                
                <!-- GLOSS in RUSSIAN (~GR) -->
                <tier id="gloss-ru" speaker="SPK_unknown" category="gls" type="a" display-name="gls-ru">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='gls' and @lang='ru']" separator="-"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-gloss($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                
                <!-- GLOSS in RUSSIAN (other style) (~GO) -->
                <tier id="gloss-ru-O" speaker="SPK_unknown" category="gls" type="a" display-name="gls-ru-O">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='gls' and @lang='ru-Qaaa-x-Ourg']" separator="-"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-gloss($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                
                
                <!-- CATEGORIES (POS) (~PS) -->
                <tier id="pos" speaker="SPK_unknown" category="ps" type="a" display-name="ps">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morph/item[@type='gls' and @lang='ru-Qaaa-x-Ourg']" separator="|"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-gloss($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
            </basic-body>
        </basic-transcription>
    </xsl:template>
    
    
    <xsl:function name="my:cleanup-tx" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="concat($in,' ')"/>
        <!-- attach one space -->
    </xsl:function>

    <xsl:function name="my:cleanup-morph" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'-\^0$','')"/>
        <!-- strip final -^0 -->
    </xsl:function>
    
    <xsl:function name="my:cleanup-gloss" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'-(\[.+\])','.$1')"/>
        <!-- put . instead of - before [...] -->
    </xsl:function>
    
</xsl:stylesheet>
