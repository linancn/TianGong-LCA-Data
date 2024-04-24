<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:lciamethod="http://lca.jrc.it/ILCD/LCIAMethod"
    xmlns:common="http://lca.jrc.it/ILCD/Common" exclude-result-prefixes="lciamethod common xs">

    <xsl:import href="common.xsl"/>
    <xsl:import href="display-common.xsl"/>
    <xsl:import href="dataset-common.xsl"/>

    <!-- use this parameter to define which fields are to be displayed. Allowed values: mandatory, recommended, all -->
    <xsl:param name="showFieldsMode">all</xsl:param>


    <xsl:template name="getTitle">
        <xsl:value-of select="/lciamethod:LCIAMethodDataSet/lciamethod:LCIAMethodInformation/lciamethod:dataSetInformation/common:name"/>
    </xsl:template>


    <xsl:template match="lciamethod:useAdviceForDataSet">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="text()"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="lciamethod:interventionLocation">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="text()"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="lciamethod:geographicalRepresentativenessDescription"/>
    </xsl:template>


    <xsl:template match="lciamethod:interventionSubLocation">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data">
                <xsl:value-of select="text()"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="lciamethod:descriptionOfRestrictions"/>
    </xsl:template>


    <xsl:template match="lciamethod:referenceToReferenceUnitGroup">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <xsl:call-template name="renderReference"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="lciamethod:characterisationFactors">
        <!-- holds the elements to display in the order they are supposed to appear in -->
        <xsl:variable name="fullListofCharacterisationFactorsElements"
            select="'referenceToFlowDataSet,location,exchangeDirection,meanValue,minimumValue,maximumValue,uncertaintyDistributionType,relativeStandardDeviation95In,dataDerivationTypeStatus,deviatingRecommendation'"/>

        <xsl:variable name="characterisationFactorsElements">
            <xsl:call-template name="getNonEmptyFactorElements">
                <xsl:with-param name="list" select="$fullListofCharacterisationFactorsElements"/>
            </xsl:call-template>
        </xsl:variable>

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
                    <xsl:call-template name="printFlowsExchangesHeaderRow">
                        <xsl:with-param name="characterisationFactorsElements" select="$characterisationFactorsElements"/>
                    </xsl:call-template>

                    <!-- now process all flow properties  -->
                    <xsl:for-each select="*">
                        <tr>
                            <!-- process the children of flowProperty  -->
                            <xsl:call-template name="processFlowsExchangesData">
                                <xsl:with-param name="list" select="$characterisationFactorsElements"/>
                            </xsl:call-template>
                        </tr>
                        <xsl:if test="count(lciamethod:referencesToDataSource)>0">
                            <xsl:apply-templates select="lciamethod:referencesToDataSource"/>
                        </xsl:if>
                        <xsl:if test="normalize-space(lciamethod:generalComment/text())!=''">
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
                                    <xsl:apply-templates select="lciamethod:generalComment"/>
                                </td>
                            </tr>
                        </xsl:if>
                    </xsl:for-each>
                </table>
            </td>
        </tr>
    </xsl:template>


    <!-- render the row where headers of the flowProperty table are shown -->
    <xsl:template name="printFlowsExchangesHeaderRow">
        <xsl:param name="characterisationFactorsElements"/>
        <tr>
            <xsl:call-template name="processFlowsExchangesHeaders">
                <xsl:with-param name="list" select="$characterisationFactorsElements"/>
            </xsl:call-template>
        </tr>
    </xsl:template>


    <!-- process the list of elements, invoking printFlowsExchangesHeader for each one -->
    <xsl:template name="processFlowsExchangesHeaders">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="printFlowsExchangesHeader">
                    <xsl:with-param name="elementName" select="substring-before($list,',')"/>
                </xsl:call-template>
                <xsl:call-template name="processFlowsExchangesHeaders">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printFlowsExchangesHeader">
                    <xsl:with-param name="elementName" select="$list"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- render a single header including comment -->
    <xsl:template name="printFlowsExchangesHeader">
        <xsl:param name="elementName"/>
        <xsl:variable name="fieldRequirement">
            <xsl:call-template name="getFieldRequirement">
                <xsl:with-param name="fieldName" select="$elementName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="displayField">
            <xsl:call-template name="decideFieldDisplay">
                <xsl:with-param name="fieldRequirement" select="$fieldRequirement"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="$displayField='true'">
            <xsl:variable name="displayName">
                <xsl:call-template name="getFieldShortDesc">
                    <xsl:with-param name="fieldName" select="$elementName"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="comment">
                <xsl:call-template name="getComment">
                    <xsl:with-param name="fieldName" select="$elementName"/>
                </xsl:call-template>
            </xsl:variable>
            <th class="table_header">
                <a class="info" href="javascript:void(0);">
                    <xsl:value-of select="$displayName"/>
                    <span>
                        <xsl:value-of select="$comment"/>
                    </span>
                </a>
            </th>
        </xsl:if>
    </xsl:template>


    <!-- process the list of elements, invoking printExchangesData for each one -->
    <xsl:template name="processFlowsExchangesData">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="printFlowsExchangesData">
                    <xsl:with-param name="currentName" select="substring-before($list, ',')"/>
                </xsl:call-template>
                <xsl:call-template name="processFlowsExchangesData">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printFlowsExchangesData">
                    <xsl:with-param name="currentName" select="$list"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- fetch additional data if needed and invoke printFlowsExchangesTableData -->
    <xsl:template name="printFlowsExchangesData">
        <xsl:param name="currentName"/>
        <xsl:variable name="data">
            <xsl:choose>
                <xsl:when test="$currentName='referenceToFlowDataSet'">
                    <xsl:call-template name="renderReference">
                        <xsl:with-param name="linkText" select="common:shortDescription[xml:lang=$defaultLanguage]/text()"/>
                        <xsl:with-param name="uri" select="lciamethod:referenceToFlowDataSet/@uri"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='relativeStandardDeviation95In' and lciamethod:relativeStandardDeviation95In/text()!=''">
                    <xsl:value-of select="lciamethod:relativeStandardDeviation95In"/>
                    <xsl:text> %</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="*[local-name()=$currentName]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="printFlowsExchangesTableData">
            <xsl:with-param name="currentName" select="$currentName"/>
            <xsl:with-param name="data">
                <xsl:copy-of select="$data"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>


    <!-- render a single data table cell in FlowsExchanges section -->
    <xsl:template name="printFlowsExchangesTableData">
        <xsl:param name="currentName"/>
        <xsl:param name="data"/>

        <xsl:variable name="fieldRequirement">
            <xsl:call-template name="getFieldRequirement">
                <xsl:with-param name="fieldName" select="$currentName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="displayField">
            <xsl:call-template name="decideFieldDisplay">
                <xsl:with-param name="fieldRequirement" select="$fieldRequirement"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="dataClass">
            <xsl:call-template name="decideDataClass">
                <xsl:with-param name="fieldName" select="$currentName"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="$displayField='true'">
            <td class="exchanges_data">
                <span class="{$dataClass}">
                    <xsl:choose>
                        <xsl:when test="$dataClass='data_enum'">
                            <a class="info" href="javascript:void(0);">
                                <xsl:value-of select="$data"/>
                                <span>
                                    <xsl:call-template name="getEnumComment">
                                        <xsl:with-param name="enumValue" select="$data"/>
                                    </xsl:call-template>
                                </span>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$data"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </td>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getNonEmptyFactorElements">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="getNonEmptyFactorElementsDoWork">
                    <xsl:with-param name="elementName" select="substring-before($list,',')"/>
                </xsl:call-template>
                <xsl:call-template name="getNonEmptyFactorElements">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getNonEmptyFactorElementsDoWork">
                    <xsl:with-param name="elementName" select="$list"/>
                    <xsl:with-param name="last" select="true()"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getNonEmptyFactorElementsDoWork">
        <xsl:param name="elementName"/>
        <xsl:param name="last" select="false()"/>
        <xsl:variable name="dataPresent">
            <xsl:for-each select="lciamethod:factor/*[local-name()=$elementName]">
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


    <!-- render referencesToDataSource cell in exchanges section -->
    <xsl:template match="lciamethod:flowExchange/lciamethod:referencesToDataSource">
        <xsl:variable name="comment">
            <xsl:call-template name="getComment">
                <xsl:with-param name="fieldName" select="local-name()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="lciamethod:referenceToDataSource">
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


    <xsl:template match="lciamethod:flowExchange/lciamethod:generalComment">
        <xsl:call-template name="printMultiLangContent"/>
    </xsl:template>

</xsl:stylesheet>
