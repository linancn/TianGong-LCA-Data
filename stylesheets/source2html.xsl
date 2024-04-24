<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ilcd="http://lca.jrc.it/ILCD" xmlns:source="http://lca.jrc.it/ILCD/Source" xmlns:common="http://lca.jrc.it/ILCD/Common"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="common source xs">

  <xsl:import href="common.xsl"/>
  <xsl:import href="display-common.xsl"/>
  <xsl:import href="dataset-common.xsl"/>

  <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
  <xsl:param name="showFieldsMode">all</xsl:param>


  <xsl:template name="getTitle">
    <xsl:value-of select="/source:sourceDataSet/source:sourceInformation/source:dataSetInformation/common:shortName"/>
  </xsl:template>

  <xsl:template match="source:referenceToDigitalFile">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <xsl:call-template name="renderReference">
          <xsl:with-param name="linkText" select="@uri"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
