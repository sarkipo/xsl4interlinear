<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>
    
    <xsl:template match="/">
        <body>
        <xsl:for-each-group select="//morph" group-by="item[@type='gls' and @lang='en']">
            <xsl:sort select="item[@type='gls' and @lang='en']"/>
            <p><xsl:value-of select="current-grouping-key()"/></p>
        </xsl:for-each-group>
        </body>
    </xsl:template>
</xsl:stylesheet>