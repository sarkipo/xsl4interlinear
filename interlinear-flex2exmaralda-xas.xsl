<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml" exclude-result-prefixes="#all" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>

    <!--
            This is the transform from SIL FLEx flextext format into EXMARaLDA exb, tuned for Kamas project (Donner's texts).
            See interlinear-eaf2exmaralda.xsl for conversion from ELAN.
            (c) Alexandre Arkhipov, 2015-2016.

            This transform is for single files. 
            Based on transform for Nganasan.
            Based on the batch version based on interlinear-eaf2exmaralda.xsl v1.11.
            v1.20: Transform for single files.
            v1.21: ... is replaced with … and both are counted as a (punctuation) word. (27.02.2016)
    -->
    
    <xsl:variable name="filename" select="replace(replace(base-uri(),'^.*/',''),'.flextext','')"/>

    <xsl:variable name="tiers-sent">ref fe fo nt</xsl:variable>
    <xsl:variable name="tiers-word">tx ps SeR SyF IST</xsl:variable>
    <xsl:variable name="tiers-morph">mb mp</xsl:variable>
    <xsl:variable name="tiers-gloss">ge mc hn</xsl:variable>
    
    <!--<xsl:variable name="speaker" select="substring-before($filename,'_')"/>-->
    <xsl:variable name="speaker" select="if(substring-before($filename,'_') = '') then 'SPK' else substring-before($filename,'_')"/>
    
    <xsl:param name="timestart" as="xs:decimal" select="4.0"/>
    <!-- Time offset for first word -->
    <xsl:param name="timestep" as="xs:decimal" select="0.5"/>
    <!-- Mean word length in sec -->

    <xsl:template match="/">
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
                    <speaker id="{$speaker}">
                        <abbreviation><xsl:value-of select="$speaker"/></abbreviation>
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
                    <!-- here go the time slots -->
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="tsnumber" select="count(./preceding::word[my:word(.)])"/>
                        <!-- +position()-1 -->
                        <tli id="{concat('T',$tsnumber)}"
                            time="{format-number($timestart + $timestep*$tsnumber, '#0.0##')}" type="appl"/>
                        <xsl:for-each select="current()//word[my:word(.)]">
                            <tli id="{concat('T',$tsnumber+position())}"
                                time="{format-number($timestart + $timestep*($tsnumber+position()),'#0.0##')}"
                                type="appl"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </common-timeline>

                <!-- Here go the tiers. The output order is fixed. -->
                <xsl:call-template name="tier-sent">
                    <!-- ref -->
                    <xsl:with-param name="itemtype" select="'segnum'"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="cat" select="'ref'"/>
                    <xsl:with-param name="display" select="'ref'"/>
                    <xsl:with-param name="prefix" select="concat($filename,'.')"/>
                </xsl:call-template>
               <!-- <xsl:call-template name="tier-sent">
                    <-\- st -\->
                    <xsl:with-param name="itemtype" select="'lit'"/>
                    <xsl:with-param name="lang" select="'nio-x-cyr'"/>
                    <xsl:with-param name="display" select="'st'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-sent">
                    <-\- ts -\->
                    <xsl:with-param name="itemtype" select="'lit'"/>
                    <xsl:with-param name="lang" select="'nio-x-lat'"/>
                    <xsl:with-param name="display" select="'ts'"/>
                </xsl:call-template>-->


                <xsl:call-template name="tier-tx"/>


                <xsl:call-template name="tier-morph">
                    <!-- mb -->
                    <xsl:with-param name="itemtype" select="'txt'"/>
                    <xsl:with-param name="lang" select="'xas'"/>
                    <xsl:with-param name="cat" select="'mb'"/>
                    <xsl:with-param name="display" select="'mb'"/>
                    <xsl:with-param name="sep" select="''"/>
                </xsl:call-template>
                <xsl:call-template name="tier-morph">
                    <!-- mp -->
                    <xsl:with-param name="itemtype" select="'cf'"/>
                    <xsl:with-param name="lang" select="'xas'"/>
                    <xsl:with-param name="cat" select="'mp'"/>
                    <xsl:with-param name="display" select="'mp'"/>
                    <xsl:with-param name="sep" select="''"/>
                </xsl:call-template>
                <!--<xsl:call-template name="tier-morph">
                    <-\- gr -\->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'ru'"/>
                    <xsl:with-param name="cat" select="'gr'"/>
                    <xsl:with-param name="display" select="'gr'"/>
                </xsl:call-template>-->
                <xsl:call-template name="tier-morph">
                    <!-- ge -->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="cat" select="'ge'"/>
                    <xsl:with-param name="display" select="'ge'"/>
                </xsl:call-template>
                <!--<xsl:call-template name="tier-morph">
                    <-\- go -\->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'ru-Qaaa-x-Ourg'"/>
                    <xsl:with-param name="cat" select="'go'"/>
                    <xsl:with-param name="display" select="'go'"/>
                </xsl:call-template>-->
                <xsl:call-template name="tier-morph">
                    <!-- hn -->
                    <xsl:with-param name="itemtype" select="'hn'"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="cat" select="'hn'"/>
                    <xsl:with-param name="display" select="'hn'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-morph">
                    <!-- mc -->
                    <xsl:with-param name="itemtype" select="'msa'"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="cat" select="'mc'"/>
                    <xsl:with-param name="display" select="'mc'"/>
                </xsl:call-template>


                <xsl:call-template name="tier-word-new">
                    <!-- ps -->
                    <xsl:with-param name="cat" select="'ps'"/>
                    <xsl:with-param name="display" select="'ps'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-word-new">
                    <!-- SeR -->
                    <xsl:with-param name="cat" select="'SeR'"/>
                    <xsl:with-param name="display" select="'SeR'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-word-new">
                    <!-- SyF -->
                    <xsl:with-param name="cat" select="'SyF'"/>
                    <xsl:with-param name="display" select="'SyF'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-word-new">
                    <!-- IST -->
                    <xsl:with-param name="cat" select="'IST'"/>
                    <xsl:with-param name="display" select="'IST'"/>
                </xsl:call-template>


               <!-- <xsl:call-template name="tier-sent">
                    <-\- fr -\->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'ru'"/>
                    <xsl:with-param name="cat" select="'fr'"/>
                    <xsl:with-param name="display" select="'fr'"/>
                </xsl:call-template>-->
                <xsl:call-template name="tier-sent">
                    <!-- fe -->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="cat" select="'fe'"/>
                    <xsl:with-param name="display" select="'fe'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-sent">
                    <!-- fo -->
                    <xsl:with-param name="itemtype" select="'gls'"/>
                    <xsl:with-param name="lang" select="'qaa-x-don'"/>
                    <xsl:with-param name="cat" select="'fo'"/>
                    <xsl:with-param name="display" select="'fo'"/>
                </xsl:call-template>
                <xsl:call-template name="tier-sent">
                    <!-- nt -->
                    <xsl:with-param name="itemtype" select="'note'"/>
                    <xsl:with-param name="cat" select="'nt'"/>
                    <xsl:with-param name="display" select="'nt'"/>
                </xsl:call-template>
            </basic-body>
            <!-- insert the tierformat-table (copied a formatting template) -->
            <xsl:copy-of select="$format-table"/>
        </basic-transcription>
    </xsl:template>


    <xsl:template name="tier-sent">
        <!-- from flextext -->
        <xsl:param name="itemtype"/>
        <xsl:param name="lang" select="''"/>
        <!-- for exmaralda -->
        <xsl:param name="cat" select="'v'"/>
        <xsl:param name="type" select="'d'"/>
        <xsl:param name="display"/>
        <!-- to append filename in ref tier -->
        <xsl:param name="prefix" select="''"/>
        <tier id="{$display}" speaker="{$speaker}" category="{$cat}" type="{$type}" display-name="{$display}">
            <xsl:for-each select="//phrase">
                <xsl:variable name="ts-start" select="count(./preceding::word[my:word(.)])"/><!-- ./preceding::word[item/@type!='punct'] -->
                <!-- +position()-1 -->
                <xsl:variable name="ts-end" select="$ts-start+count(.//word[my:word(.)])"/>
                <xsl:variable name="value">
                    <xsl:value-of select="./item[@type=$itemtype and (if ($lang eq '') then true() else @lang=$lang)]"
                        separator=" || "/>
                </xsl:variable>
                <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                    <xsl:value-of select="concat($prefix, my:cleanup-brackets(my:sent-renum($value,$display)))"/>
                </event>
            </xsl:for-each>
        </tier>
    </xsl:template>


    <!-- WORD-LEVEL TIERS -->
    <!-- WORD TRANSCRIPTION (~TX) -->
    <xsl:template name="tier-tx">
        <tier id="tx" speaker="{$speaker}" category="tx" type="t" display-name="tx">
            <xsl:for-each select="//phrase">
                <xsl:variable name="ts-start" select="count(./preceding::word[my:word(.)])"/>
                <xsl:for-each-group select=".//word"
                    group-starting-with="word[my:startwordgroup(.)]">
                    <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                    <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                        <xsl:variable name="value">
                            <xsl:value-of select="current-group()/item[@type='txt' or @type='punct']" separator=""/>
                        </xsl:variable>
                        <xsl:value-of select="my:cleanup-tx($value)"/>
                    </event>
                </xsl:for-each-group>
            </xsl:for-each>
        </tier>
    </xsl:template>

    <!-- NEW EMPTY WORD-LEVEL TIERS (PS, SeR, SyF, IST) -->
    <xsl:template name="tier-word-new">
        <!-- for exmaralda -->
        <xsl:param name="cat" select="'v'"/>
        <xsl:param name="type" select="'a'"/>
        <xsl:param name="display"/>
        <tier id="{$display}" speaker="{$speaker}" category="{$cat}" type="{$type}" display-name="{$display}">
            <xsl:for-each select="//phrase">
                <xsl:variable name="ts-start" select="count(./preceding::word[my:word(.)])"/>
                <!-- +position()-1 -->
                <xsl:for-each-group select=".//word"
                    group-starting-with="word[my:startwordgroup(.)]">
                    <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                    <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}"/>
                </xsl:for-each-group>
            </xsl:for-each>
        </tier>
    </xsl:template>


    <!-- MORPH/GLOSS LEVELS -->
    <xsl:template name="tier-morph">
        <!-- from flextext -->
        <xsl:param name="itemtype"/>
        <xsl:param name="lang" select="''"/>
        <!-- for exmaralda -->
        <xsl:param name="cat" select="'v'"/>
        <xsl:param name="type" select="'a'"/>
        <xsl:param name="display"/>
        <!-- separator -->
        <xsl:param name="sep" select="'-'"/>
        <tier id="{$display}" speaker="{$speaker}" category="{$cat}" type="{$type}" display-name="{$display}">
            <xsl:for-each select="//phrase">
                <xsl:variable name="ts-start" select="count(./preceding::word[my:word(.)])"/>
                <!-- +position()-1 -->
                <xsl:for-each-group select=".//word"
                    group-starting-with="word[my:startwordgroup(.)]">
                    <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                    <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                        <xsl:variable name="value">
                            <xsl:value-of select="current-group()//morph/item[@type=$itemtype and @lang=$lang]"
                                separator="{$sep}"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($tiers-morph,$display)">
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </xsl:when>
                            <xsl:when test="contains($tiers-gloss,$display)">
                                <xsl:value-of select="my:cleanup-gloss($value)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="my:cleanup-brackets($value)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </event>
                </xsl:for-each-group>
            </xsl:for-each>
        </tier>
    </xsl:template>


    <xsl:function name="my:cleanup-tx" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of
            select="concat(replace(replace(my:cleanup-brackets($in),'( +$)|[ˀ]',''),'[03]([\.,!\?;:]*)$','$1'),' ')"/>
        <!-- strip trailing space, strip final 0 and 3, attach one space -->
        <!-- strip "deep consonant" and "deep glottal stop" -->
    </xsl:function>

    <xsl:function name="my:cleanup-morph" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(my:cleanup-brackets($in),'-\^0','')"/>
        <!-- strip -^0 -->
    </xsl:function>

    <xsl:function name="my:cleanup-gloss" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(my:cleanup-brackets(replace($in,' ','')),'-(\[.+?\])','.$1')"/>
        <!-- replace - with . before [] -->
        <!-- fixed to lazy quant. to handle multiple replaces in one string -->
        <!-- erase spaces -->
    </xsl:function>

    <!-- replacing brackets [[ ]] with (( )) for all tiers -->
    <xsl:function name="my:cleanup-brackets" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <!-- replace [[, ]] with ((, )) -->
        <xsl:variable name="temp" select="replace(replace($in,'\[\[', '(('), '\]\]', '))')"/>
        <!-- replace ... with … -->
        <xsl:variable name="temp2" select="replace($temp,'(\.\.\.)', '…')"/>
        <!-- replace /// with ((XXX)); ??? with ((unknown)) -->
        <xsl:value-of select="replace(replace($temp2,'(///)','((XXX))'),'\?\?\?','((unknown))')"/>
    </xsl:function>

    <!-- take "para.sent" number from segnum, extract second part (assuming always a single paragraph per text), -->
    <!-- convert to a number and pad with zeroes to 3 digits -->
    <xsl:function name="my:sent-renum" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:param name="tier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$tier='ref' and substring-after($in, '.')!=''">
                <xsl:value-of select="format-number(number(substring-after($in,'.')),'#000')"/>
            </xsl:when>
            <xsl:when test="$tier='ref' and substring-after($in, '.')=''">
                <xsl:value-of select="format-number(number($in),'#000')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$in"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="my:startwordgroup" as="xs:boolean">
        <xsl:param name="word" as="element(word)"/>
        <xsl:choose>
            <xsl:when test="my:lpunct($word/preceding-sibling::word[1])">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="if (my:lpunct($word) or my:word($word)) then true() else false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="my:lpunct" as="xs:boolean">
        <xsl:param name="word"/>
        <!-- as="element(word)" -->
        <xsl:choose>
            <xsl:when test="$word/item/@type='punct' and matches($word/item/text()[1],'(\(+)|(\[+)|[«“‘]')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$word/item/@type='punct' and empty($word/preceding-sibling::word)">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Tell apart real punctuation from non-baseline lang which also has @type="punct" -->
    <!-- Also treat "///" and "???" and "..." and "…" as a word -->
    <xsl:function name="my:word" as="xs:boolean">
        <xsl:param name="word"/>
        <!-- as="element(word)" -->
        <xsl:value-of select="if ($word/item/@type='punct' and $word/item/@lang='xas' and not(matches($word/item[@type='punct'],'(///)|(\?\?\?)|(…)|(\.\.\.)'))) then false() else true()"/>
    </xsl:function>
    
    <xsl:function name="my:sec2msec">
        <xsl:param name="time-sec"/>
        <xsl:value-of select="replace($time-sec, '([0-9]{3})$', '.$1')"/>
    </xsl:function>

    <!-- insert the tierformat-table (copied a formatting template) -->
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
                <property name="font-color">#R00G00B99</property>
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
            <tier-format tierref="mc">
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
            <tier-format tierref="SeR">
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
            <tier-format tierref="SyF">
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
            <tier-format tierref="fo">
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
                <property name="font-name">Charis SIL</property>
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
            <tier-format tierref="TIE4">
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
                <property name="font-name">Charis SIL</property>
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
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
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
                <property name="font-name">Charis SIL</property>
            </tier-format>
        </tierformat-table>
    </xsl:variable>
</xsl:stylesheet>
