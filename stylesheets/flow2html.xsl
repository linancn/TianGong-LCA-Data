<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:flow="http://lca.jrc.it/ILCD/Flow"
  xmlns:common="http://lca.jrc.it/ILCD/Common" exclude-result-prefixes="flow common xs">

  <xsl:import href="common.xsl"/>
  <xsl:import href="display-common.xsl"/>
  <xsl:import href="dataset-common.xsl"/>

  <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
  <xsl:param name="showFieldsMode">all</xsl:param>


  <xsl:template name="getTitle">
    <xsl:value-of select="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:baseName"/>
    <xsl:if test="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:treatmentStandardsRoutes!=''">; <xsl:value-of
        select="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:treatmentStandardsRoutes"/>
    </xsl:if>
    <xsl:if test="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:mixAndLocationTypes!=''">; <xsl:value-of
        select="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:mixAndLocationTypes"/>
    </xsl:if>
    <xsl:if test="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:flowProperties!=''">; <xsl:value-of
        select="/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation/flow:name/flow:flowProperties"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="flow:name">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="applyTemplates" select="false()"/>
      <xsl:with-param name="omitIfEmpty" select="false()"/>
      <xsl:with-param name="disableDescendantCount" select="false()"/>
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <table width="100%" border="0">
          <tr valign="bottom">
            <td class="fieldname">
              <xsl:apply-templates select="*[local-name()='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage)]" mode="caption"/>
              <xsl:apply-templates select="*[local-name()!='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage)]" mode="caption"/>
            </td>
          </tr>
          <tr valign="bottom">
            <td class="data">
              <xsl:apply-templates select="*[local-name()='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage)]"/>
              <xsl:apply-templates select="*[local-name()!='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage)]"/>
            </td>
          </tr>
        </table>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="flow:name/*">
    <xsl:variable name="defaultLanguageCondition">
      <xsl:call-template name="defaultLanguageCondition"/>
    </xsl:variable>
    <xsl:variable name="alternativeLanguageCondition">
      <xsl:call-template name="alternativeLanguageCondition"/>
    </xsl:variable>

    <xsl:if test="$defaultLanguageCondition='true' or $alternativeLanguageCondition='true'">
      <xsl:if test="normalize-space(text())!=''">
        <xsl:if test="local-name()!='baseName'">
          <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:if test="$alternativeLanguageCondition='true'">
          <span class="lang">
            <xsl:value-of select="@xml:lang"/>
            <xsl:text> </xsl:text>
          </span>
        </xsl:if>
        <xsl:value-of select="text()"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="flow:name/*" mode="caption">
    <xsl:variable name="defaultLanguageCondition">
      <xsl:call-template name="defaultLanguageCondition"/>
    </xsl:variable>
    <xsl:variable name="alternativeLanguageCondition">
      <xsl:call-template name="alternativeLanguageCondition"/>
    </xsl:variable>

    <xsl:if test="$defaultLanguageCondition='true' or $alternativeLanguageCondition='true'">
      <xsl:if test="normalize-space(text())!=''">
        <xsl:variable name="fieldShortDesc">
          <xsl:call-template name="getFieldShortDesc">
            <xsl:with-param name="fieldName" select="local-name()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="comment">
          <xsl:call-template name="getComment">
            <xsl:with-param name="fieldName" select="local-name()"/>
          </xsl:call-template>
        </xsl:variable>

        <a class="info" href="javascript:void(0);">
          <xsl:if test="local-name()!='baseName'">
            <xsl:text>; </xsl:text>
          </xsl:if>
          <xsl:value-of select="$fieldShortDesc"/>
          <span>
            <xsl:value-of select="$comment"/>
          </span>
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="flow:referenceToReferenceFlowProperty">
    <xsl:variable name="id" select="number(text())"/>
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <xsl:call-template name="renderReference">
          <xsl:with-param name="linkText">
            <xsl:call-template name="getFlowPropertyAndUnitGroup">
              <xsl:with-param name="flowPropertyDatasetURI"
                select="/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$id]/flow:referenceToFlowPropertyDataSet/@uri"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="uri" select="/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$id]/flow:referenceToFlowPropertyDataSet/@uri"/>
          <xsl:with-param name="stdLinkText" select="/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$id]/flow:referenceToFlowPropertyDataSet/common:shortDescription[@xml:lang=$defaultLanguage]/text()"></xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="/flow:flowDataSet/flow:flowProperties">
    <!-- holds the elements to display in the order they are supposed to appear in -->
    <xsl:variable name="flowPropertyElements"
      select="'referenceToFlowPropertyDataSet,meanValue,minimumValue,maximumValue,uncertaintyDistributionType,relativeStandardDeviation95In,dataDerivationTypeStatus,generalComment'"/>

    <tr>
      <td class="subsection" colspan="2" style="padding-left: 20px;">
        <xsl:call-template name="getFieldShortDesc">
          <xsl:with-param name="fieldName" select="local-name()"/>
        </xsl:call-template>
      </td>
    </tr>

    <tr>
      <td colspan="2">
        <table width="100%">
          <!-- print the header -->
          <xsl:call-template name="printTableHeaderRow">
            <xsl:with-param name="headerElements" select="$flowPropertyElements"/>
          </xsl:call-template>

          <!-- now process all flow properties  -->
          <xsl:for-each select="flow:flowProperty">
            <tr>
              <!-- process the children of flowProperty  -->
              <xsl:call-template name="processFlowPropertiesData">
                <xsl:with-param name="list" select="$flowPropertyElements"/>
              </xsl:call-template>
            </tr>
          </xsl:for-each>
        </table>
      </td>
    </tr>
  </xsl:template>


  <!-- process the list of elements, invoking printFlowPropertiesData for each one -->
  <xsl:template name="processFlowPropertiesData">
    <xsl:param name="list"/>
    <xsl:choose>
      <xsl:when test="contains($list, ',')">
        <xsl:call-template name="printFlowPropertiesData">
          <xsl:with-param name="currentName" select="substring-before($list, ',')"/>
        </xsl:call-template>
        <xsl:call-template name="processFlowPropertiesData">
          <xsl:with-param name="list" select="substring-after($list, ',')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="printFlowPropertiesData">
          <xsl:with-param name="currentName" select="$list"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- fetch additional data if needed and invoke printTableData -->
  <xsl:template name="printFlowPropertiesData">
    <xsl:param name="currentName"/>
    <xsl:variable name="data">
      <xsl:choose>
        <xsl:when test="$currentName='referenceToFlowPropertyDataSet'">
          <xsl:apply-templates select="flow:referenceToFlowPropertyDataSet"/>
        </xsl:when>
        <xsl:when test="$currentName='relativeStandardDeviation95In'">
          <xsl:value-of select="flow:relativeStandardDeviation95In"/>
          <xsl:text> %</xsl:text>
        </xsl:when>
        <xsl:when test="$currentName='meanValue'">
          <xsl:value-of select="*[local-name()=$currentName]"/>
          <xsl:text> </xsl:text>
          <xsl:variable name="flowPropertyId" select="./@dataSetInternalID"></xsl:variable>
          <xsl:call-template name="getUnitGroup">
            <xsl:with-param name="flowPropertyDatasetURI"
              select="/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$flowPropertyId]/flow:referenceToFlowPropertyDataSet/@uri"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$currentName='generalComment'">
          <xsl:apply-templates select="flow:generalComment"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*[local-name()=$currentName]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="printTableData">
      <xsl:with-param name="currentName" select="$currentName"/>
      <xsl:with-param name="data">
        <xsl:copy-of select="$data"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="flow:flowProperty/flow:generalComment">
    <xsl:call-template name="printMultiLangContent"/>
  </xsl:template>
    
    
  <xsl:template match="flow:flowProperty">
    <xsl:call-template name="masterTemplate">
      <xsl:with-param name="currentName" select="''"/>
      <xsl:with-param name="fieldDescSuffix">Flow property</xsl:with-param>
      <xsl:with-param name="omitIfEmpty" select="false()"/>
      <xsl:with-param name="copy" select="true()"/>
      <xsl:with-param name="data">
        <a name="{@dataSetInternalID}"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="flow:referenceToFlowPropertyDataSet">
    <xsl:call-template name="renderReference">
      <xsl:with-param name="linkText">
        <xsl:if test="$doNotLoadExternalResources!='true'">
          <xsl:call-template name="getFlowPropertyName">
            <xsl:with-param name="flowPropertyDataset" select="document(@uri, /)"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
