<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ilcd="http://lca.jrc.it/ILCD"
    xmlns:categories="http://lca.jrc.it/ILCD/Categories" xmlns:process="http://lca.jrc.it/ILCD/Process" xmlns:flow="http://lca.jrc.it/ILCD/Flow"
    xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty" xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup" xmlns:source="http://lca.jrc.it/ILCD/Source"
    xmlns:common="http://lca.jrc.it/ILCD/Common" exclude-result-prefixes="xsl xs categories process flow flowproperty unitgroup source common">

    <xsl:import href="common.xsl"/>
    <xsl:import href="display-common.xsl"/>
    <xsl:import href="dataset-common.xsl"/>

    <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
    <xsl:param name="showFieldsMode">all</xsl:param>


    <!-- subsection datasetInformation -->
    <xsl:template match="/*/*/process:dataSetInformation" priority="10">
        <xsl:variable name="fieldShortDesc">
            <xsl:call-template name="getFieldShortDesc">
                <xsl:with-param name="fieldName" select="local-name()"/>
            </xsl:call-template>
        </xsl:variable>
        <tr>
            <td class="subsection" colspan="2" style="padding-left: 20px;">
                <xsl:value-of select="$fieldShortDesc"/>
            </td>
        </tr>
        <xsl:apply-templates select="../process:geography/process:locationOfOperationSupplyOrProduction" mode="override"/>
        <xsl:apply-templates select="../process:time/common:referenceYear" mode="override"/>
        <xsl:apply-templates select="process:name"/>
        <xsl:apply-templates select="process:identifierOfSubDataSet"/>
        <xsl:apply-templates select="../../process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:useAdviceForDataSet" mode="overrideHighlight"/>
        <xsl:apply-templates select="../process:technology/process:technologicalApplicability" mode="override"/>
        <xsl:apply-templates select="process:functionalUnitFlowProperties"/>
        <xsl:apply-templates select="common:synonyms"/>
        <xsl:apply-templates select="process:complementingProcesses"/>
        <xsl:apply-templates select="process:classificationInformation"/>
        <xsl:apply-templates select="common:generalComment"/>
        <tr>
            <td/>
            <td class="data">
                <table class="data">
                    <tr>
                        <td valign="bottom">
                            <xsl:call-template name="rowMasterTemplate">
                                <xsl:with-param name="omitIfEmpty" select="false()"/>
                                <xsl:with-param name="displayFieldName" select="false()"/>
                                <xsl:with-param name="copy" select="true()"/>
                                <xsl:with-param name="data">
                                    <xsl:apply-templates select="/process:processDataSet/process:administrativeInformation/process:publicationAndOwnership/common:copyright" mode="override"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td valign="bottom">
                            <xsl:call-template name="rowMasterTemplate">
                                <xsl:with-param name="omitIfEmpty" select="false()"/>
                                <xsl:with-param name="displayFieldName" select="false()"/>
                                <xsl:with-param name="copy" select="true()"/>
                                <xsl:with-param name="data">
                                    <xsl:apply-templates select="/process:processDataSet/process:administrativeInformation/process:publicationAndOwnership/common:referenceToOwnershipOfDataSet"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                        <td valign="bottom">
                            <xsl:call-template name="rowMasterTemplate">
                                <xsl:with-param name="omitIfEmpty" select="false()"/>
                                <xsl:with-param name="displayFieldName" select="false()"/>
                                <xsl:with-param name="copy" select="true()"/>
                                <xsl:with-param name="data">
                                    <xsl:apply-templates select="process:referenceToExternalDocumentation"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="*" mode="override" priority="10">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="applyTemplates" select="false()"/>
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="overrideHighlight" priority="10">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="cssClass" select="'highlight'"/>
            <xsl:with-param name="applyTemplates" select="true()"/>
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="common:copyright" mode="override" priority="20">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="applyTemplates" select="false()"/>
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <xsl:choose>
                    <xsl:when test=".='true' or .='1'">
                        <xsl:text>Yes</xsl:text>
                    </xsl:when>
                    <xsl:when test=".='false' or .='0'">
                        <xsl:text>No</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="process:name">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="applyTemplates" select="false()"/>
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="disableDescendantCount" select="false()"/>
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <table width="100%" border="0">
                    <tr valign="bottom">
                        <td class="fieldname">
                            <xsl:apply-templates select="*[local-name()='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage or not(@xml:lang))]" mode="caption"/>
                            <xsl:apply-templates select="*[local-name()!='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage or not(@xml:lang))]" mode="caption"/>
                        </td>
                    </tr>
                    <tr valign="bottom">
                        <td class="data">
                            <xsl:apply-templates select="*[local-name()='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage or not(@xml:lang))]" mode="override"/>
                            <xsl:apply-templates select="*[local-name()!='baseName' and (@xml:lang=$defaultLanguage or @xml:lang=$alternativeLanguage or not(@xml:lang))]" mode="override"/>
                        </td>
                    </tr>
                </table>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="process:name/*" mode="override" priority="20">
        <xsl:variable name="defaultLanguageCondition">
            <xsl:call-template name="defaultLanguageCondition"/>
        </xsl:variable>
        <xsl:variable name="alternativeLanguageCondition">
            <xsl:call-template name="alternativeLanguageCondition"/>
        </xsl:variable>

        <xsl:if test="$defaultLanguageCondition='true' or $alternativeLanguageCondition='true'">
            <xsl:variable name="displayField">
                <xsl:call-template name="decideFieldDisplay">
                    <xsl:with-param name="fieldRequirement">
                        <xsl:call-template name="getFieldRequirement">
                            <xsl:with-param name="fieldName" select="name()"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$displayField='true' and normalize-space(text())!=''">
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

    <xsl:template match="process:name/*" mode="caption" priority="20">
        <xsl:variable name="defaultLanguageCondition">
            <xsl:call-template name="defaultLanguageCondition"/>
        </xsl:variable>
        <xsl:variable name="alternativeLanguageCondition">
            <xsl:call-template name="alternativeLanguageCondition"/>
        </xsl:variable>

        <xsl:if test="$defaultLanguageCondition='true' or $alternativeLanguageCondition='true'">
            <xsl:variable name="displayField">
                <xsl:call-template name="decideFieldDisplay">
                    <xsl:with-param name="fieldRequirement">
                        <xsl:call-template name="getFieldRequirement">
                            <xsl:with-param name="fieldName" select="name()"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$displayField='true' and normalize-space(text())!=''">
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


    <xsl:template name="getTitle">
        <xsl:apply-templates mode="multiLang" select="/process:processDataSet/process:processInformation/process:dataSetInformation/process:name/process:baseName">
            <xsl:with-param name="suffix" select="'; '"/>
            <xsl:with-param name="printLanguageCode" select="false()"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="multiLang" select="/process:processDataSet/process:processInformation/process:dataSetInformation/process:name/process:treatmentStandardsRoutes">
            <xsl:with-param name="suffix" select="'; '"/>
            <xsl:with-param name="printLanguageCode" select="false()"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="multiLang" select="/process:processDataSet/process:processInformation/process:dataSetInformation/process:name/process:mixAndLocationTypes">
            <xsl:with-param name="suffix" select="'; '"/>
            <xsl:with-param name="printLanguageCode" select="false()"/>
        </xsl:apply-templates>
        <xsl:apply-templates mode="multiLang" select="/process:processDataSet/process:processInformation/process:dataSetInformation/process:name/process:functionalUnitFlowProperties">
            <xsl:with-param name="printLanguageCode" select="false()"/>
        </xsl:apply-templates>
        <xsl:if test="/process:processDataSet/@metaDataOnly='true' or /process:processDataSet/@metaDataOnly='1'">
            <xsl:text> (meta data only) </xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template name="getNonEmptyExchangeElements">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="getNonEmptyExchangeElementsDoWork">
                    <xsl:with-param name="elementName" select="substring-before($list,',')"/>
                </xsl:call-template>
                <xsl:call-template name="getNonEmptyExchangeElements">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getNonEmptyExchangeElementsDoWork">
                    <xsl:with-param name="elementName" select="$list"/>
                    <xsl:with-param name="last" select="true()"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getNonEmptyExchangeElementsDoWork">
        <xsl:param name="elementName"/>
        <xsl:param name="last" select="false()"/>
        <xsl:variable name="dataPresent">
            <xsl:for-each select="process:exchange/*[local-name()=$elementName]">
                <xsl:value-of select="text()"/>
                <xsl:if test="count(descendant::*)">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="normalize-space($dataPresent)!=''">
            <xsl:value-of select="$elementName"/>
            <xsl:if test="$last!='true'">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="getNonEmptyVariableElements">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="getNonEmptyVariableElementsDoWork">
                    <xsl:with-param name="elementName" select="substring-before($list,',')"/>
                </xsl:call-template>
                <xsl:call-template name="getNonEmptyVariableElements">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getNonEmptyVariableElementsDoWork">
                    <xsl:with-param name="elementName" select="$list"/>
                    <xsl:with-param name="last" select="true()"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getNonEmptyVariableElementsDoWork">
        <xsl:param name="elementName"/>
        <xsl:param name="last" select="false()"/>
        <xsl:variable name="dataPresent">
            <xsl:choose>
                <xsl:when test="$elementName!='variableParameter'">
                    <xsl:for-each select="//process:mathematicalRelations/process:variableParameter">
                        <xsl:value-of select="*[local-name()=$elementName]"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise> . </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($dataPresent)!=''">
            <xsl:value-of select="$elementName"/>
            <xsl:if test="$last!='true'">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="process:exchanges">
        <!-- holds the elements to display in the order they are supposed to appear in -->
        <xsl:variable name="exchangeElements"
            select="'referenceToVariable,location,referenceToFlowDataSet,resultingAmount,meanAmount,minimumAmount,maximumAmount,uncertaintyDistributionType,relativeStandardDeviation95In,allocations,functionType,dataSourceType,dataDerivationTypeStatus'"/>

        <!-- holds a list of the above elements that are non-empty -->
        <xsl:variable name="nonEmptyExchangeElements">
            <xsl:call-template name="getNonEmptyExchangeElements">
                <xsl:with-param name="list" select="$exchangeElements"/>
            </xsl:call-template>
        </xsl:variable>

        <tr>
            <td class="section" colspan="2" style="padding-left: 10px;">
                <a name="{name()}"> Inputs and Outputs</a>
            </td>
        </tr>

        <xsl:call-template name="processExchangesSubSection">
            <xsl:with-param name="direction" select="'Input'"/>
            <xsl:with-param name="nonEmptyExchangeElements" select="$nonEmptyExchangeElements"/>
        </xsl:call-template>
        <xsl:call-template name="processExchangesSubSection">
            <xsl:with-param name="direction" select="'Output'"/>
            <xsl:with-param name="nonEmptyExchangeElements" select="$nonEmptyExchangeElements"/>
        </xsl:call-template>

    </xsl:template>


    <!-- handles output of a complete exchanges subsection (inputs or outputs) -->
    <xsl:template name="processExchangesSubSection">
        <xsl:param name="direction"/>
        <xsl:param name="nonEmptyExchangeElements"/>
        <tr>
            <td class="subsection" colspan="2" style="padding-left: 20px;">
                <xsl:value-of select="$direction"/>
                <xsl:text>s</xsl:text>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table width="100%">
                    <!-- print the header -->
                    <xsl:call-template name="printExchangesTableHeaderRow">
                        <xsl:with-param name="nonEmptyExchangeElements" select="$nonEmptyExchangeElements"/>
                    </xsl:call-template>

                    <!-- now process all exchanges for the desired direction -->
                    <xsl:for-each select="process:exchange[process:exchangeDirection=$direction]">
                        <tr>
                            <!-- first column is the type, which is not in the list -->
                            <xsl:call-template name="printTableData">
                                <xsl:with-param name="currentName" select="'referenceToFlowDataSet'"/>
                                <xsl:with-param name="copy" select="true()"/>
                                <xsl:with-param name="isEnum" select="true()"/>
                                <xsl:with-param name="data">
                                    <xsl:call-template name="getFlowDatasetType">
                                        <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>

                            <!-- then comes the classification -->
                            <xsl:call-template name="printTableData">
                                <xsl:with-param name="copy" select="true()"/>
                                <xsl:with-param name="data">
                                    <xsl:call-template name="getFlowDatasetClassification">
                                        <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>

                            <!-- process the children of exchange that are in the list -->
                            <xsl:call-template name="processExchangesData">
                                <xsl:with-param name="list" select="$nonEmptyExchangeElements"/>
                                <xsl:with-param name="direction" select="$direction"/>
                            </xsl:call-template>
                        </tr>

                        <xsl:variable name="fieldRequirementReferencesToDataSource">
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="'referencesToDataSource'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="displayFieldReferencesToDataSource">
                            <xsl:call-template name="decideFieldDisplay">
                                <xsl:with-param name="fieldRequirement" select="$fieldRequirementReferencesToDataSource"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:if test="$displayFieldReferencesToDataSource='true'">
                            <xsl:if test="count(process:referencesToDataSource)>0">
                                <xsl:apply-templates select="process:referencesToDataSource"/>
                            </xsl:if>
                        </xsl:if>

                        <xsl:variable name="fieldRequirementGeneralComment">
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="'generalComment'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="displayFieldGeneralComment">
                            <xsl:call-template name="decideFieldDisplay">
                                <xsl:with-param name="fieldRequirement" select="$fieldRequirementGeneralComment"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:if test="$displayFieldGeneralComment='true'">
                            <xsl:if test="normalize-space(process:generalComment/text())!=''">
                                <xsl:variable name="comment">
                                    <xsl:call-template name="getComment">
                                        <xsl:with-param name="fieldName" select="'generalComment'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <tr>
                                    <td colspan="2" class="table_header">
                                        <a class="info" href="javascript:void(0);">General Comment<span>
                                                <xsl:value-of select="$comment"/>
                                            </span>
                                        </a>
                                    </td>
                                    <td colspan="11" class="exchanges_data">
                                        <xsl:apply-templates select="process:generalComment"/>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </table>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="process:exchanges/process:exchange/process:generalComment">
        <span class="data_neutral">
            <xsl:call-template name="printMultiLangContent"/>
        </span>
    </xsl:template>


    <!-- render the row where headers of the exchanges table are shown -->
    <xsl:template name="printExchangesTableHeaderRow">
        <xsl:param name="nonEmptyExchangeElements"/>
        <tr>
            <!-- must read comment for this field from FlowDataset schema -->
            <xsl:variable name="fieldName" select="'typeOfDataSet'"/>
            <xsl:variable name="flowSchema" select="document('../../schemas/ILCD_FlowDataSet.xsd', /)"/>
            <xsl:variable name="comment">
                <xsl:for-each select="$flowSchema">
                    <xsl:value-of select="key('schemaDocumentKey', $fieldName)//xs:documentation/text()"/>
                </xsl:for-each>
            </xsl:variable>
            <th class="table_header">
                <a class="info" href="javascript:void(0);">Type Of Flow<span>
                        <xsl:value-of select="$comment"/>
                    </span>
                </a>
            </th>
            <th class="table_header">
                <a class="info" href="javascript:void(0);">Classification</a>
            </th>
            <xsl:call-template name="processTableHeaders">
                <xsl:with-param name="list" select="$nonEmptyExchangeElements"/>
            </xsl:call-template>
        </tr>
    </xsl:template>


    <!-- process the list of elements, invoking printExchangesData for each one -->
    <xsl:template name="processExchangesData">
        <xsl:param name="list"/>
        <xsl:param name="direction"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="printExchangesData">
                    <xsl:with-param name="currentName" select="substring-before($list, ',')"/>
                </xsl:call-template>
                <xsl:call-template name="processExchangesData">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                    <xsl:with-param name="direction" select="$direction"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printExchangesData">
                    <xsl:with-param name="currentName" select="$list"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- fetch additional data if needed and invoke printTableData -->
    <xsl:template name="printExchangesData">
        <xsl:param name="currentName"/>
        <xsl:variable name="data">
            <xsl:choose>
                <xsl:when test="$currentName='referenceToFlowDataSet'">
                    <xsl:variable name="details">
                        <xsl:call-template name="getFlowDatasetDetails">
                            <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="renderReference">
                        <xsl:with-param name="linkText" select="$details"/>
                        <xsl:with-param name="uri" select="process:referenceToFlowDataSet/@uri"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='resultingAmount'">
                    <xsl:value-of select="process:resultingAmount"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getUnitGroupAndFlowProperty">
                        <xsl:with-param name="flowDatasetURI" select="process:referenceToFlowDataSet/@uri"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='relativeStandardDeviation95In'">
                    <xsl:value-of select="process:relativeStandardDeviation95In"/>
                    <xsl:text> %</xsl:text>
                </xsl:when>
                <xsl:when test="$currentName='allocations'">
                    <table>
                        <xsl:for-each select="process:allocations/process:allocation">
                            <xsl:variable name="coProduct" select="@internalReferenceToCoProduct"/>
                            <xsl:variable name="details">
                                <xsl:call-template name="getFlowDatasetDetails">
                                    <xsl:with-param name="URI" select="parent::*/parent::*/parent::*/process:exchange[@dataSetInternalID=$coProduct]/process:referenceToFlowDataSet/@uri"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <tr>
                                <td class="exchanges_data">
                                    <span class="data_neutral">
                                        <xsl:call-template name="renderReference">
                                            <xsl:with-param name="linkText" select="$details"/>
                                            <xsl:with-param name="uri" select="parent::*/parent::*/parent::*/process:exchange[@dataSetInternalID=$coProduct]/process:referenceToFlowDataSet/@uri"/>
                                        </xsl:call-template>
                                    </span>
                                </td>
                                <td class="exchanges_data">
                                    <span class="data_neutral">
                                        <xsl:value-of select="@allocatedFraction"/>
                                        <xsl:text> %</xsl:text>
                                    </span>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
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


    <!-- render referencesToDataSource cell in exchanges section -->
    <xsl:template match="process:exchange/process:referencesToDataSource">
        <xsl:variable name="comment">
            <xsl:call-template name="getComment">
                <xsl:with-param name="fieldName" select="local-name()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="process:referenceToDataSource">
            <tr>
                <td class="table_header" colspan="2">
                    <a class="info" href="javascript:void(0);">Reference to Data Source<span>
                            <xsl:value-of select="$comment"/>
                        </span>
                    </a>
                </td>
                <td class="exchanges_data" colspan="11">
                    <xsl:call-template name="renderReference"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>


    <!-- fields that will not be displayed in default mode -->
    <xsl:template match="common:UUID"/>
    <xsl:template match="common:copyright"/>
    <xsl:template match="process:useAdviceForDataSet"/>
    <xsl:template match="/process:processDataSet/process:processInformation/process:geography/process:locationOfOperationSupplyOrProduction"/>
    <xsl:template match="/process:processDataSet/process:processInformation/process:time/common:referenceYear"/>
    <xsl:template match="process:technologicalApplicability"/>

    <xsl:template match="process:variableParameter/@*">
        <td valign="bottom">
            <xsl:call-template name="rowMasterTemplate">
                <xsl:with-param name="omitIfEmpty" select="false()"/>
                <xsl:with-param name="data">
                    <xsl:value-of select="."/>
                </xsl:with-param>
            </xsl:call-template>
        </td>
    </xsl:template>


    <xsl:template match="process:mathematicalRelations">

        <!-- render information only if there are actually variables present -->
        <xsl:if test="child::*">

            <!-- show other fields -->
            <xsl:apply-templates select="*[local-name()!='variableParameter']"/>

            <!-- render variables as a table -->

            <!-- list of fields that should be rendered as table columns in the order they're supposed to appear -->
            <xsl:variable name="variableElements" select="'variableParameter,formula,meanValue,minimumValue,maximumValue,uncertaintyDistributionType,relativeStandardDeviation95In,comment'"/>

            <!-- list of the above elements that are non-empty -->
            <xsl:variable name="nonEmptyVariableElements">
                <xsl:call-template name="getNonEmptyVariableElements">
                    <xsl:with-param name="list" select="$variableElements"/>
                </xsl:call-template>
            </xsl:variable>

            <tr>
                <td class="subsection" colspan="2" style="padding-left: 20px;">
                    <xsl:call-template name="getFieldShortDesc">
                        <xsl:with-param name="fieldName" select="'variableParameter'"/>
                    </xsl:call-template>
                </td>
            </tr>

            <tr>
                <td colspan="2">
                    <table width="100%">
                        <!-- print the header -->
                        <xsl:call-template name="printTableHeaderRow">
                            <xsl:with-param name="headerElements" select="$nonEmptyVariableElements"/>
                        </xsl:call-template>

                        <!-- now process all variables  -->
                        <xsl:for-each select="process:variableParameter">
                            <tr>
                                <!-- process the children of flowProperty  -->
                                <xsl:call-template name="processVariablesData">
                                    <xsl:with-param name="list" select="$nonEmptyVariableElements"/>
                                </xsl:call-template>
                            </tr>
                        </xsl:for-each>
                    </table>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>


    <!-- process the list of elements, invoking printVariablesData for each one -->
    <xsl:template name="processVariablesData">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="printVariablesData">
                    <xsl:with-param name="currentName" select="substring-before($list, ',')"/>
                </xsl:call-template>
                <xsl:call-template name="processVariablesData">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printVariablesData">
                    <xsl:with-param name="currentName" select="$list"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- invoke printTableData -->
    <xsl:template name="printVariablesData">
        <xsl:param name="currentName"/>
        <xsl:variable name="data">
            <xsl:choose>
                <xsl:when test="$currentName!='variableParameter'">
                    <xsl:value-of select="*[local-name()=$currentName]"/>
                    <xsl:if test="$currentName='relativeStandardDeviation95In' and *[local-name()=$currentName]/text()">
                        <xsl:text> %</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
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


    <xsl:template match="process:variableParameter">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="process:locationOfOperationSupplyOrProduction" mode="override" priority="20">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="@location"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="process:descriptionOfRestrictions"/>
    </xsl:template>

    <xsl:template match="process:subLocationOfOperationSupplyOrProduction">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="@subLocation"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="process:descriptionOfRestrictions"/>
    </xsl:template>


    <xsl:template match="process:descriptionOfRestrictions">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="data">
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="process:completenessElementaryFlows">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <xsl:call-template name="printEnumData">
                    <xsl:with-param name="value" select="@type"/>
                </xsl:call-template>: <xsl:call-template name="printEnumData">
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="process:referenceToReferenceFlow">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data">
                <xsl:variable name="internalID" select="number(.)"/>
                <xsl:call-template name="getFlowDatasetDetails">
                    <xsl:with-param name="URI" select="//process:exchange[@dataSetInternalID=$internalID]/process:referenceToFlowDataSet/@uri"/>
                </xsl:call-template>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="//process:exchange[@dataSetInternalID=$internalID]/process:resultingAmount"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="getUnitGroupAndFlowProperty">
                    <xsl:with-param name="flowDatasetURI" select="//process:exchange[@dataSetInternalID=$internalID]/process:referenceToFlowDataSet/@uri"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="process:functionalUnitOrOther">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="parent::process:quantitativeReference/@type"/>: <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="process:percentageSupplyOrProductionCovered">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="."/> % </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!-- retrieves flow data information from external flowdata file -->
    <xsl:template name="getFlowDatasetDetails">
        <xsl:param name="URI"/>

        <xsl:if test="$doNotLoadExternalResources!='true'">
            <!-- retrieve flow dataset  -->
            <xsl:variable name="flowDataset" select="document($URI, /)/flow:flowDataSet/flow:flowInformation/flow:dataSetInformation"/>

            <xsl:variable name="baseName">
                <xsl:choose>
                    <xsl:when test="$flowDataset/flow:name/flow:baseName[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="$flowDataset/flow:name/flow:baseName[@xml:lang=$defaultLanguage]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$flowDataset/flow:name/flow:baseName[@xml:lang=$alternativeLanguage]/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="treatmentStandardsRoutes">
                <xsl:choose>
                    <xsl:when test="$flowDataset/flow:name/flow:treatmentStandardsRoutes[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="$flowDataset/flow:name/flow:treatmentStandardsRoutes[@xml:lang=$defaultLanguage]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$flowDataset/flow:name/flow:treatmentStandardsRoutes[@xml:lang=$alternativeLanguage]/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="mixAndLocationTypes">
                <xsl:choose>
                    <xsl:when test="$flowDataset/flow:name/flow:mixAndLocationTypes[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="$flowDataset/flow:name/flow:mixAndLocationTypes[@xml:lang=$defaultLanguage]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$flowDataset/flow:name/flow:mixAndLocationTypes[@xml:lang=$alternativeLanguage]/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="flowProperties">
                <xsl:choose>
                    <xsl:when test="$flowDataset/flow:name/flow:flowProperties[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="$flowDataset/flow:name/flow:flowProperties[@xml:lang=$defaultLanguage]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$flowDataset/flow:name/flow:flowProperties[@xml:lang=$alternativeLanguage]/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:value-of select="$baseName"/>
            <xsl:if test="$treatmentStandardsRoutes!=''">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="$treatmentStandardsRoutes"/>
            </xsl:if>
            <xsl:if test="$mixAndLocationTypes!=''">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="$mixAndLocationTypes"/>
            </xsl:if>
            <xsl:if test="$flowProperties!=''">
                <xsl:text>; </xsl:text>
                <xsl:value-of select="$flowProperties"/>
            </xsl:if>
            <xsl:if test="$flowDataset/flow:classificationInformation/common:class[@level='0']!=''">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="$flowDataset/flow:classificationInformation/common:class[@level='0']"/>
                <xsl:text>] </xsl:text>
            </xsl:if>
            <xsl:if test="$flowDataset/flow:classificationInformation/common:class[@level='1']!=''">
                <xsl:text> - [</xsl:text>
                <xsl:value-of select="$flowDataset/flow:classificationInformation/common:class[@level='1']"/>
                <xsl:text>] </xsl:text>
            </xsl:if>
            <xsl:if test="$flowDataset/flow:classificationInformation/common:class[@level='2']!=''">
                <xsl:text> - [</xsl:text>
                <xsl:value-of select="$flowDataset/flow:classificationInformation/common:class[@level='2']"/>
                <xsl:text>] </xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- retrieves type of flow from external flowdata file -->
    <xsl:template name="getFlowDatasetType">
        <xsl:param name="URI"/>
        <xsl:if test="$doNotLoadExternalResources!='true'">
            <!-- retrieve flow dataset  -->
            <xsl:variable name="flowDataset" select="document($URI, /)/flow:flowDataSet"/>
            <xsl:value-of select="$flowDataset/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet"/>
        </xsl:if>
    </xsl:template>



    <!-- retrieves classification from external flowdata file -->
    <xsl:template name="getFlowDatasetClassification">
        <xsl:param name="URI"/>
        <xsl:if test="$doNotLoadExternalResources!='true'">
            <!-- retrieve flow dataset  -->
            <xsl:variable name="flowDataset" select="document($URI, /)/flow:flowDataSet"/>
            <xsl:variable name="type">
                <xsl:value-of select="$flowDataset/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet"/>
            </xsl:variable>
            <!-- determine the element that is read from the flow ds for classification information -->
            <xsl:variable name="classificationElementName">
                <xsl:choose>
                    <xsl:when test="$type='Elementary flow'">elementaryFlowCategorization</xsl:when>
                    <xsl:otherwise>classification</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each
                select="$flowDataset/flow:flowInformation/flow:dataSetInformation/flow:classificationInformation/*[local-name()=$classificationElementName and namespace-uri()='http://lca.jrc.it/ILCD/Common']">
                <xsl:sort select="@name" data-type="text" order="ascending"/>
                <xsl:if test="@name">
                    <xsl:value-of select="@name"/>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:for-each select="*">
                    <xsl:sort select="@level" data-type="number" order="ascending"/>
                    <xsl:value-of select="text()"/>
                    <xsl:if test="following-sibling::*">
                        <xsl:text> / </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <br/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>



</xsl:stylesheet>
