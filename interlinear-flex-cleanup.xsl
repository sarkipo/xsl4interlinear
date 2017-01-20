<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<!-- This stylesheet creates phrase-level items of type 'txt' which contain all words and punctuation.  -->
	<!-- Edited by Sasha Arkhipov, from the itemsFirst edited by Tom Myers from an xml2Verifiable.xsl by John Thomson.  -->
	
	<xsl:param name="use_settings_file" select="'no'"/>
	<xsl:param name="settings"/>

<!--	<xsl:variable name="langs"><!-\- Used to cycle through writing systems (lang's) used in the document. -\->
		<!-\- I deliberately filter out those langs which only have 2-letter names (such as 'ru','en','fr') since the original text we want to get from word/item's will be in vernacular languages, and these normally have longer codes in FLEx. -\->
		<xsl:for-each select="//language[string-length(./@lang) &gt; 2]"><lang><xsl:value-of select="@lang" /></lang></xsl:for-each>
	</xsl:variable>
-->
	<xsl:template match="document">
		<document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:FlexInterlinear.xsd">
			<xsl:apply-templates/>
		</document>
	</xsl:template>


	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*|text()"/>
			<xsl:apply-templates select="item"/>
			<xsl:apply-templates select="*[not(self::item)]"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- This template creates a new item of type 'txt' under phrase element, containing concatenated values of item of type 'txt' under all the word's in that phrase -->
	<!-- Since there can be several writing systems used in word/item's, we cycle through them (outer for-each). -->

	<xsl:template match="morphemes[.//item[@type='txt']/text() = '-^0']">
		<xsl:copy>
			<xsl:apply-templates select="@*|text()"/>
			<xsl:for-each select="morph"> ... </xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<!-- This template replaces the lang attribute of every note with its consecutive number within the phrase -->
	<!-- I don't keep the original lang value since in our case it's not informative for notes (they're all written in Russian, the lang attribute being assigned by FLEx by the alphabet of the first character which can be a gloss or vernacular word). -->
<!--	<xsl:template match="item[@type='note']">
		<xsl:variable name="note-num" select="count(./preceding-sibling::*[@type='note'])+1" />
		<xsl:copy>
			<xsl:attribute name="lang"><xsl:value-of select="$note-num" /></xsl:attribute>
			<xsl:apply-templates select="@*[name()!='lang']|text()|comment()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>
-->

	<xsl:template match="@*|text()|comment()|processing-instruction()">
		<xsl:copy>
			<xsl:apply-templates select="@*|text()|comment()|processing-instruction()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>