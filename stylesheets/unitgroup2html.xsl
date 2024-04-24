<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://lca.jrc.it/ILCD/Common" xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup" exclude-result-prefixes="common unitgroup">

   <xsl:import href="common.xsl"/>
   <xsl:import href="display-common.xsl"/>
   <xsl:import href="dataset-common.xsl"/>

   <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
   <xsl:param name="showFieldsMode">all</xsl:param>


   <xsl:template name="getTitle">
      <xsl:value-of select="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:dataSetInformation/common:name"/>
   </xsl:template>

   <xsl:template match="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:dataSetInformation/common:name">
      <xsl:call-template name="masterTemplate">
         <xsl:with-param name="data">
            <xsl:value-of select="text()"/>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:technology/unitgroup:applicability/text()!=''">
         <xsl:apply-templates select="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:technology/unitgroup:applicability" mode="override"/>
         <!--<xsl:call-template name="masterTemplate">
				<xsl:with-param name="currentName" select="local-name(/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:technology/unitgroup:applicability)"/>
				
				<xsl:with-param name="data">
					fo<xsl:value-of select="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:technology/unitgroup:applicability/text()"/>
				</xsl:with-param>
			</xsl:call-template>-->
      </xsl:if>
   </xsl:template>

   <xsl:template match="unitgroup:applicability"/>

   <xsl:template match="unitgroup:applicability" mode="override">
      <xsl:call-template name="masterTemplate">
         <xsl:with-param name="data">
            <xsl:value-of select="/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:technology/unitgroup:applicability/text()"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="unitgroup:referenceToReferenceUnit">
      <xsl:call-template name="masterTemplate">
         <xsl:with-param name="omitIfEmpty" select="false()"/>
         <xsl:with-param name="data">
            <xsl:variable name="ref" select="number(.)"/>
            <xsl:value-of select="/unitgroup:unitGroupDataSet/unitgroup:units/unitgroup:unit[@dataSetInternalID=$ref]/unitgroup:name"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

</xsl:stylesheet>
