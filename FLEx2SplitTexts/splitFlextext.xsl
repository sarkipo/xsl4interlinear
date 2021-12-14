<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				version="2.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" />
  <!-- This stylesheet splits a document containing multiple interlinear texts as output by FieldWorks into multiple documents. -->

	<xsl:param name="addcounter" select="'yes'"/>
	<xsl:template match="document">
		<xsl:for-each select="interlinear-text">
			<xsl:variable name="counter">
				<xsl:choose>
					<xsl:when test="$addcounter ne 'yes'"><xsl:value-of select="''"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="concat('-',position())"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="textname">
				<xsl:choose>
					<xsl:when test="item[@type='title-abbreviation' and text()!='']"><xsl:value-of select="concat(item[@type='title-abbreviation' and text()!=''][1],$counter)"/></xsl:when>
					<xsl:when test="item[@type='title' and text()!='']"><xsl:value-of select="concat(item[@type='title' and text()!=''][1],$counter)"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="concat('text_',@guid)"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:result-document method="xml" href="{$textname}.flextext">
				<document version="2">
					<interlinear-text>
						<xsl:copy-of select="./@*" />
						<xsl:copy-of select="./*" />
					</interlinear-text>
				</document>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template> 

	</xsl:stylesheet>
