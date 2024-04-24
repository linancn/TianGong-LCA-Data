<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:common="http://lca.jrc.it/ILCD/Common"
  xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty" exclude-result-prefixes="common flowproperty xs">

  <xsl:import href="common.xsl"/>
  <xsl:import href="display-common.xsl"/>
  <xsl:import href="dataset-common.xsl"/>

  <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
  <xsl:param name="showFieldsMode">all</xsl:param>

  <xsl:variable name="schemaDocument" select="document('../../schemas/ILCD_FlowPropertyDataSet.xsd', /)"/>

  <xsl:template name="getTitle">
    <xsl:value-of select="/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:dataSetInformation/common:name"/>
  </xsl:template>

  <xsl:template match="flowproperty:referenceToReferenceUnitGroup">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="fieldDescSuffix"><xsl:text> (</xsl:text><xsl:value-of select="@type"/>)</xsl:with-param>
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <xsl:call-template name="renderReference">
          <xsl:with-param name="linkText">
            <xsl:if test="$doNotLoadExternalResources!='true'">
              <xsl:variable name="unitGroupName">
                <xsl:call-template name="getUnitGroupName">
                  <xsl:with-param name="unitGroupDataset" select="document(@uri, /)"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="unitGroupReferenceUnitName">
                <xsl:call-template name="getUnitGroupReferenceUnitName">
                  <xsl:with-param name="unitGroupDataset" select="document(@uri, /)"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:if test="$unitGroupName!='' or $unitGroupReferenceUnitName!=''">
                <xsl:value-of select="$unitGroupName"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$unitGroupReferenceUnitName"/>
                <xsl:text>)</xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
