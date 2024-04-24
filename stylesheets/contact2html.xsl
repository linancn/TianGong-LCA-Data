<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:common="http://lca.jrc.it/ILCD/Common" xmlns:contact="http://lca.jrc.it/ILCD/Contact" exclude-result-prefixes="common contact xs">
	
	<xsl:import href="common.xsl"/>
	<xsl:import href="display-common.xsl"/>
	<xsl:import href="dataset-common.xsl"/>
	
	<!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
	<xsl:param name="showFieldsMode">all</xsl:param>


	<xsl:template name="getTitle">
	   <xsl:value-of select="/contact:contactDataSet/contact:contactInformation/contact:dataSetInformation/common:shortName"/>
	</xsl:template>

  <xsl:template match="contact:email">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <a href="mailto:{.}"><xsl:value-of select="."/></a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="contact:WWWAddress">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <a href="{.}" target="_blank"><xsl:value-of select="."/></a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>
