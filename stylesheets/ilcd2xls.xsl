<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:categories="http://lca.jrc.it/ILCD/Categories"
    xmlns:process="http://lca.jrc.it/ILCD/Process" xmlns:lciamethod="http://lca.jrc.it/ILCD/LCIAMethod" xmlns:flow="http://lca.jrc.it/ILCD/Flow"
    xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty" xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup" xmlns:source="http://lca.jrc.it/ILCD/Source"
    xmlns:contact="http://lca.jrc.it/ILCD/Contact" xmlns:common="http://lca.jrc.it/ILCD/Common" xmlns:ilcd="http://lca.jrc.it/ILCD" xmlns:ilcd2xls="edu.kit.ilcd.ilcd2xls.XLSWrite"
    exclude-result-prefixes="xsl xs categories process lciamethod flow flowproperty unitgroup source contact common ilcd">

    <xsl:import href="common.xsl"/>
    <xsl:import href="display-common.xsl"/>
    <xsl:import href="dataset-common.xsl"/>
    <xsl:import href="process2html.xsl"/>

    <xsl:param name="showFieldsMode" select="all"/>
    <xsl:param name="includeFieldDescriptions" select="true()"/>
    <xsl:param name="includeEnumDescriptions" select="true()"/>

    <xsl:param name="fileName" select="'/Users/oliver.kusche/Projekte/ILCD2XLS/x-sheet-default.xls'"/>

    <xsl:param name="sourceFile"/>
    <xsl:param name="timeStamp"/>

    <xsl:variable name="styleSheetVersion" select="0.1"/>

    <xsl:variable name="exchangeElements"
        select="'exchangeDirection,!typeOfFlow,!classification,referenceToVariable,location,referenceToFlowDataSet,resultingAmount,!unit,!flowProperty,meanAmount,minimumAmount,maximumAmount,uncertaintyDistributionType,relativeStandardDeviation95In,!allocations,functionType,dataSourceType,dataDerivationTypeStatus,!generalComment,!referencesToDataSource'"/>
    <xsl:variable name="LCIAResultElements" select="'referenceToLCIAMethodDataSet,meanAmount,uncertaintyDistributionType,relativeStandardDeviation95In,!generalComment'"/>

    <xsl:variable name="STYLE_DEFAULT" select="number(0)"/>
    <xsl:variable name="STYLE_NOWRAP" select="number(1)"/>
    <xsl:variable name="STYLE_BOLD" select="number(2)"/>
    <xsl:variable name="STYLE_ITALIC" select="number(4)"/>
    <xsl:variable name="STYLE_SECTION" select="number(8)"/>
    <xsl:variable name="STYLE_SUBSECTION" select="number(16)"/>
    <xsl:variable name="STYLE_REFERENCE" select="number(32)"/>

    <xsl:variable name="NO_OUTPUT" select="'NO%%OUTPUT'"/>

    <xsl:template match="/">
        
        <xsl:value-of select="ilcd2xls:init($fileName)"/>

        <xsl:value-of select="ilcd2xls:setAutoSize(0)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(1)"/>
        <xsl:value-of select="ilcd2xls:setSize(2, 1300)"/>
        <xsl:value-of select="ilcd2xls:setSize(3, 20000)"/>
        <xsl:value-of select="ilcd2xls:setSize(4, 18000)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(5)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(6)"/>
        <xsl:value-of select="ilcd2xls:hideColumn(1)"/>

        <xsl:call-template name="printHeader"/>

        <xsl:apply-templates select="*"/>

        <xsl:call-template name="printInfo"/>

        <xsl:value-of select="ilcd2xls:finish()"/>
    </xsl:template>



    <xsl:template name="printInfo">
        <xsl:variable name="infoSheet">
            <xsl:value-of select="ilcd2xls:addSheet('Info')"/>
        </xsl:variable>
        <xsl:value-of select="ilcd2xls:switchToSheet(number($infoSheet))"/>

        <xsl:value-of select="ilcd2xls:setAutoSize(0)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(1)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(2)"/>

        <xsl:value-of select="ilcd2xls:writeToCell('Generator', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(concat('ILCD2XLS Stylesheet v', $styleSheetVersion), $STYLE_DEFAULT)"/>
        <xsl:value-of select="ilcd2xls:newLine()"/>

        <xsl:value-of select="ilcd2xls:writeToCell('Source file', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell($sourceFile, $STYLE_DEFAULT)"/>
        <xsl:value-of select="ilcd2xls:newLine()"/>

        <xsl:value-of select="ilcd2xls:writeToCell('Timestamp', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell($timeStamp, $STYLE_DEFAULT)"/>
        <xsl:value-of select="ilcd2xls:newLine()"/>

    </xsl:template>



    <xsl:template name="printHeader">
        <xsl:value-of select="ilcd2xls:writeToCell(0, 'Field description', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(1, 'Element/attribute name', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(2, 'lang', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(3, 'Contents / short description', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(4, 'URI', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(5, 'UUID', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(6, 'Version', $STYLE_BOLD)"/>
        <xsl:value-of select="ilcd2xls:newLine()"/>
    </xsl:template>



    <xsl:template match="*">
        <xsl:call-template name="masterTemplate"/>
    </xsl:template>



    <xsl:template name="masterTemplate">
        <xsl:param name="fieldName" select="local-name()"/>

        <xsl:param name="elementName" select="name()"/>

        <xsl:param name="fieldShortDesc">
            <xsl:call-template name="getFieldShortDesc">
                <xsl:with-param name="fieldName" select="$fieldName"/>
            </xsl:call-template>
        </xsl:param>

        <xsl:param name="comment">
            <xsl:if test="$includeFieldDescriptions='true'">
                <xsl:call-template name="getComment">
                    <xsl:with-param name="fieldName" select="$fieldName"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:param>

        <xsl:param name="lang" select="@xml:lang"/>

        <xsl:param name="contents" select="text()"/>

        <xsl:param name="contents2"/>

        <xsl:param name="descriptionSuffix"/>

        <xsl:param name="descriptionPrefix"/>

        <xsl:param name="contentsSuffix"/>

        <xsl:param name="style" select="$STYLE_DEFAULT"/>

        <xsl:param name="applyTemplates" select="true()"/>

        <xsl:param name="newLine" select="true()"/>

        <xsl:param name="dataClass">
            <xsl:call-template name="decideDataClass">
                <xsl:with-param name="fieldName" select="local-name()"/>
            </xsl:call-template>
        </xsl:param>

        <xsl:value-of select="ilcd2xls:writeToCell(0, concat($descriptionPrefix, $fieldShortDesc, $descriptionSuffix), $comment, number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(1, $elementName, number($style))"/>

        <xsl:variable name="langstyle">
            <xsl:choose>
                <xsl:when test="$style=$STYLE_DEFAULT">
                    <xsl:value-of select="$STYLE_NOWRAP"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$style"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="ilcd2xls:writeToCell(2, $lang, '',  number($langstyle))"/>

        <xsl:choose>
            <xsl:when test="$dataClass='data_enum'">
                <xsl:variable name="enumComment1">
                    <xsl:if test="$includeEnumDescriptions='true'">
                        <xsl:call-template name="getEnumComment">
                            <xsl:with-param name="enumValue" select="$contents"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="enumComment2">
                    <xsl:if test="$includeEnumDescriptions='true'">
                        <xsl:call-template name="getEnumComment">
                            <xsl:with-param name="enumValue" select="$contents2"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="ilcd2xls:writeToCell(3, concat($contents, $contentsSuffix), $enumComment1, number($STYLE_ITALIC))"/>
                <xsl:value-of select="ilcd2xls:writeToCell(4, $contents2, $enumComment2, number($STYLE_ITALIC))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="ilcd2xls:writeToCell(3, concat($contents, $contentsSuffix), number($style))"/>
                <xsl:value-of select="ilcd2xls:writeToCell(4, $contents2, number($style))"/>
            </xsl:otherwise>
        </xsl:choose>


        <xsl:if test="$newLine='true'">
            <xsl:value-of select="ilcd2xls:newLine()"/>
        </xsl:if>

        <xsl:if test="$applyTemplates='true'">
            <xsl:apply-templates select="*"/>
        </xsl:if>
    </xsl:template>



    <xsl:template match="*[starts-with(local-name(), 'referenceTo') and @type]">
        <xsl:if test="@uri!=''">
            <xsl:value-of select="ilcd2xls:setHyperLink(4, @uri, '')"/>
        </xsl:if>

        <xsl:value-of select="ilcd2xls:writeToCell(5, @refObjectId, $STYLE_REFERENCE)"/>
        <xsl:value-of select="ilcd2xls:writeToCell(6, @version, $STYLE_REFERENCE)"/>

        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="lang" select="$defaultLanguage"/>
            <xsl:with-param name="contents" select="common:shortDescription[@xml:lang=$defaultLanguage]"/>
            <xsl:with-param name="contents2" select="@uri"/>
            <xsl:with-param name="descriptionSuffix"> (<xsl:value-of select="@type"/>)</xsl:with-param>
            <xsl:with-param name="style" select="$STYLE_REFERENCE"/>
            <xsl:with-param name="applyTemplates" select="false()"/>
        </xsl:call-template>

        <xsl:apply-templates select="common:shortDescription[not(@xml:lang=$defaultLanguage)] | common:subReference"/>

    </xsl:template>



    <xsl:template match="/*|/*/*|/*/*/*">

        <xsl:variable name="style">
            <xsl:choose>
                <xsl:when test="count(ancestor::*)>1">
                    <xsl:value-of select="$STYLE_SUBSECTION"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$STYLE_SECTION"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="title">
            <xsl:if test="count(ancestor::*)=0">
                <xsl:call-template name="getTitle"/>
            </xsl:if>
        </xsl:variable>

        <xsl:value-of select="ilcd2xls:writeToCell(1, '', number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(2, '', number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(3, '', number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(4, '', number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(5, '', number($style))"/>
        <xsl:value-of select="ilcd2xls:writeToCell(6, '', number($style))"/>

        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="style" select="$style"/>
            <xsl:with-param name="contents" select="$title"/>
            <xsl:with-param name="lang" select="$defaultLanguage"/>
        </xsl:call-template>

    </xsl:template>



    <xsl:template match="common:classification">
        <xsl:if test="@classes!=''">
            <xsl:value-of select="ilcd2xls:setHyperLink(4, @classes, '')"/>
        </xsl:if>

        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents" select="@name"/>
            <xsl:with-param name="contents2" select="@classes"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="process:referenceToReferenceFlow">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents">
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



    <xsl:template match="common:class">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="descriptionPrefix" select="'   '"/>
            <xsl:with-param name="descriptionSuffix">
                <xsl:choose>
                    <xsl:when test="@level=0">
                        <xsl:text> top category</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> sub category </xsl:text>
                        <xsl:value-of select="@level"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="common:subReference">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="descriptionPrefix" select="'sub-reference'"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="process:locationOfOperationSupplyOrProduction | process:subLocationOfOperationSupplyOrProduction">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents" select="@location|@subLocation"/>
            <xsl:with-param name="applyTemplates" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="fieldName" select="'latitudeAndLongitude'"/>
            <xsl:with-param name="contents" select="@latitudeAndLongitude"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="process:variableParameter">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents" select="@name"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="common:scope">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents" select="@name"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="common:method">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="descriptionPrefix" select="'   '"/>
            <xsl:with-param name="contents" select="@name"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="common:dataQualityIndicator">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="descriptionPrefix" select="'   '"/>
            <xsl:with-param name="contents" select="@name"/>
            <xsl:with-param name="contents2" select="@value"/>
            <xsl:with-param name="dataClass" select="'data_enum'"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="process:completenessElementaryFlows">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="contents" select="@type"/>
            <xsl:with-param name="contents2" select="@value"/>
        </xsl:call-template>
    </xsl:template>



    <xsl:template match="process:exchanges" priority="100">

        <xsl:variable name="exchangesSheet">
            <xsl:value-of select="ilcd2xls:addSheet('Inputs and Outputs')"/>
        </xsl:variable>

        <xsl:value-of select="ilcd2xls:switchToSheet(number($exchangesSheet))"/>

        <xsl:call-template name="printExchangesTableHeaderRow">
            <xsl:with-param name="elements" select="$exchangeElements"/>
        </xsl:call-template>

        <xsl:apply-templates select="process:exchange">
            <xsl:sort select="process:exchangeDirection"/>
        </xsl:apply-templates>

        <xsl:value-of select="ilcd2xls:setAutoSize(0)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(1)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(2)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(3)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(4)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(5)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(6)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(7)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(8)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(9)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(10)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(11)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(12)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(13)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(14)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(15)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(16)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(17)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(18)"/>
        <xsl:value-of select="ilcd2xls:setSize(19, 15000)"/>
        <xsl:value-of select="ilcd2xls:setSize(20, 15000)"/>
        <xsl:value-of select="ilcd2xls:setSize(21, 200)"/>
        <xsl:value-of select="ilcd2xls:setSize(22, 10000)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(24)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(25)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(26)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(27)"/>
    </xsl:template>


    <xsl:template match="process:exchange" priority="100">
        <xsl:variable name="flowInfo">
            <xsl:call-template name="getFlowDatasetType">
                <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="classificationInfo">
            <xsl:call-template name="getFlowDatasetClassification">
                <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="processExchangesData">
            <xsl:with-param name="list" select="$exchangeElements"/>
        </xsl:call-template>

        <xsl:value-of select="ilcd2xls:newLine()"/>
    </xsl:template>



    <!-- render the row where headers of the exchanges table are shown -->
    <xsl:template name="printExchangesTableHeaderRow">
        <xsl:param name="elements"/>
        <xsl:call-template name="processTableHeaders">
            <xsl:with-param name="list" select="$elements"/>
        </xsl:call-template>
        <xsl:value-of select="ilcd2xls:newLine()"/>
    </xsl:template>



    <!-- tables: render a single header including comment -->
    <xsl:template name="printTableHeader">
        <xsl:param name="elementName"/>
        <xsl:param name="suffix" select="''"/>

        <xsl:choose>
            <xsl:when test="$elementName='!typeOfFlow'">
                <!-- must read comment for this field from FlowDataset schema -->
                <xsl:variable name="fieldName" select="'typeOfDataSet'"/>
                <xsl:variable name="flowSchema" select="document('../../schemas/ILCD_FlowDataSet.xsd', /)"/>
                <xsl:variable name="comment">
                    <xsl:if test="$includeFieldDescriptions='true'">
                        <xsl:for-each select="$flowSchema">
                            <xsl:value-of select="key('schemaDocumentKey', $fieldName)//xs:documentation/text()"/>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="ilcd2xls:writeToCell('Type of flow',$comment,$STYLE_SECTION)"/>
            </xsl:when>
            <xsl:when test="$elementName='!classification'">
                <xsl:value-of select="ilcd2xls:writeToCell('Classification','',$STYLE_SECTION)"/>
            </xsl:when>
            <xsl:when test="$elementName='!unit'">
                <xsl:value-of select="ilcd2xls:writeToCell('Unit','',$STYLE_SECTION)"/>
            </xsl:when>
            <xsl:when test="$elementName='!flowProperty'">
                <xsl:value-of select="ilcd2xls:writeToCell('Flow Property','',$STYLE_SECTION)"/>
            </xsl:when>
            <xsl:when test="$elementName='!allocations'">
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="'allocatedFraction'"/>
                </xsl:call-template>
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="'allocation'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$elementName='!generalComment'">
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="'generalComment'"/>
                    <xsl:with-param name="suffix" select="concat(' [',$defaultLanguage,']')"/>
                </xsl:call-template>
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="'generalComment'"/>
                    <xsl:with-param name="suffix" select="concat(' [',$alternativeLanguage,']')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$elementName='!referencesToDataSource'">
                <xsl:value-of select="ilcd2xls:writeToCell('',2)"/>
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="'referencesToDataSource'"/>
                    <xsl:with-param name="suffix" select="concat(' short description [',$defaultLanguage,']')"/>
                </xsl:call-template>
                <xsl:value-of select="ilcd2xls:writeToCell('URI',$STYLE_SECTION)"/>
                <xsl:value-of select="ilcd2xls:writeToCell('UUID',$STYLE_SECTION)"/>
                <xsl:value-of select="ilcd2xls:writeToCell('Version',$STYLE_SECTION)"/>
                <xsl:value-of select="ilcd2xls:writeToCell('Subreference(s)',$STYLE_SECTION)"/>
            </xsl:when>
            <xsl:otherwise>
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
                            <xsl:with-param name="parent" select="local-name(.)"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="comment">
                        <xsl:if test="$includeFieldDescriptions='true'">
                            <xsl:call-template name="getComment">
                                <xsl:with-param name="fieldName" select="$elementName"/>
                                <xsl:with-param name="parent" select="local-name(.)"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:value-of select="ilcd2xls:writeToCell(concat($displayName,$suffix),$comment,$STYLE_SECTION)"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="printExchangesData">
        <xsl:param name="currentName"/>

        <xsl:variable name="data">
            <xsl:choose>
                <xsl:when test="$currentName='!typeOfFlow'">
                    <xsl:call-template name="getFlowDatasetType">
                        <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='!classification'">
                    <xsl:call-template name="getFlowDatasetClassification">
                        <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='!unit'">
                    <xsl:variable name="flowDataset" select="document(process:referenceToFlowDataSet/@uri, /)"/>
                    <xsl:variable name="flowPropertyDatasetURI"
                        select="$flowDataset/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$flowDataset/flow:flowDataSet/flow:flowInformation/flow:quantitativeReference/flow:referenceToReferenceFlowProperty]/flow:referenceToFlowPropertyDataSet/@uri"/>
                    <xsl:variable name="flowPropertyDataset" select="document($flowPropertyDatasetURI, /)"/>
                    <xsl:variable name="unitGroupDatasetURI"
                        select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:quantitativeReference/flowproperty:referenceToReferenceUnitGroup/@uri"/>
                    <xsl:variable name="unitGroupDataset" select="document($unitGroupDatasetURI, /)"/>
                    <xsl:variable name="unit">
                        <xsl:call-template name="getUnitGroupReferenceUnitName">
                            <xsl:with-param name="unitGroupDataset" select="$unitGroupDataset"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$unit"/>
                </xsl:when>
                <xsl:when test="$currentName='!flowProperty'">
                    <xsl:variable name="flowDataset" select="document(process:referenceToFlowDataSet/@uri, /)"/>
                    <xsl:variable name="flowPropertyDatasetURI"
                        select="$flowDataset/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$flowDataset/flow:flowDataSet/flow:flowInformation/flow:quantitativeReference/flow:referenceToReferenceFlowProperty]/flow:referenceToFlowPropertyDataSet/@uri"/>
                    <xsl:variable name="flowPropertyDataset" select="document($flowPropertyDatasetURI, /)"/>
                    <xsl:call-template name="getFlowPropertyName">
                        <xsl:with-param name="flowPropertyDataset" select="$flowPropertyDataset"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$currentName='referenceToFlowDataSet'">
                    <xsl:variable name="details">
                        <xsl:call-template name="getFlowDatasetDetails">
                            <xsl:with-param name="URI" select="process:referenceToFlowDataSet/@uri"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="ilcd2xls:setHyperLink(process:referenceToFlowDataSet/@uri, $details)"/>
                    <xsl:value-of select="$details"/>
                </xsl:when>
                <xsl:when test="$currentName='referenceToLCIAMethodDataSet'">
                    <xsl:if test="process:referenceToLCIAMethodDataSet/@uri!=''">
                        <xsl:value-of select="ilcd2xls:setHyperLink(process:referenceToLCIAMethodDataSet/@uri, '')"/>
                    </xsl:if>
                    <xsl:value-of select="process:referenceToLCIAMethodDataSet/common:shortDescription[@xml:lang='en']"/>
                </xsl:when>
                <xsl:when test="$currentName='!allocations'">
                    <xsl:variable name="originalColumn" select="ilcd2xls:getCurrentColumn()"/>
                    <xsl:variable name="originalRow" select="ilcd2xls:getCurrentRow()"/>

                    <xsl:for-each select="process:allocations/process:allocation">
                        <xsl:variable name="currentColumn" select="ilcd2xls:getCurrentColumn()"/>
                        <xsl:variable name="currentRow" select="ilcd2xls:getCurrentRow()"/>

                        <xsl:variable name="coProduct" select="@internalReferenceToCoProduct"/>
                        <xsl:variable name="details">
                            <xsl:call-template name="getFlowDatasetDetails">
                                <xsl:with-param name="URI"
                                    select="parent::*/parent::*/parent::*/process:exchange[@dataSetInternalID=$coProduct]/process:referenceToFlowDataSet/@uri"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="ilcd2xls:writeToCell(concat(@allocatedFraction, ' %'), $STYLE_NOWRAP)"/>
                        <xsl:value-of
                            select="ilcd2xls:setHyperLink(parent::*/parent::*/parent::*/process:exchange[@dataSetInternalID=$coProduct]/process:referenceToFlowDataSet/@uri, '')"/>
                        <xsl:value-of select="ilcd2xls:writeToCell($details, $STYLE_NOWRAP)"/>
                        <xsl:value-of select="ilcd2xls:setCurrentColumn($originalColumn)"/>
                        <xsl:value-of select="ilcd2xls:setCurrentRow($currentRow+1)"/>

                        <xsl:if test="not(position()=last())">
                            <xsl:value-of select="ilcd2xls:addToNewLineBuffer(1)"/>
                        </xsl:if>
                    </xsl:for-each>

                    <xsl:value-of select="ilcd2xls:setCurrentColumn($originalColumn+2)"/>
                    <xsl:value-of select="ilcd2xls:setCurrentRow($originalRow)"/>

                    <xsl:value-of select="$NO_OUTPUT"/>
                </xsl:when>
                <xsl:when test="$currentName='!generalComment'">
                    <xsl:value-of select="ilcd2xls:writeToCell(process:generalComment[@xml:lang=$defaultLanguage]/text(), $STYLE_NOWRAP)"/>
                    <xsl:value-of select="ilcd2xls:writeToCell(process:generalComment[@xml:lang=$alternativeLanguage]/text(), $STYLE_NOWRAP)"/>
                </xsl:when>
                <xsl:when test="$currentName='!referencesToDataSource'">
                    <xsl:variable name="originalColumn" select="ilcd2xls:getCurrentColumn()"/>
                    <xsl:variable name="originalRow" select="ilcd2xls:getCurrentRow()"/>

                    <xsl:for-each select="process:referencesToDataSource/process:referenceToDataSource">
                        <xsl:variable name="currentColumn" select="ilcd2xls:getCurrentColumn()"/>
                        <xsl:variable name="currentRow" select="ilcd2xls:getCurrentRow()"/>

                        <xsl:value-of select="ilcd2xls:writeToCell(common:shortDescription, $STYLE_NOWRAP)"/>
                        <xsl:value-of select="ilcd2xls:setHyperLink(@uri, '')"/>
                        <xsl:value-of select="ilcd2xls:writeToCell(@uri, $STYLE_NOWRAP)"/>
                        <xsl:value-of select="ilcd2xls:writeToCell(@refObjectId, $STYLE_NOWRAP)"/>
                        <xsl:value-of select="ilcd2xls:writeToCell(@version, $STYLE_NOWRAP)"/>
                        <xsl:for-each select="common:subReference">
                            <xsl:value-of select="ilcd2xls:writeToCell(text(), $STYLE_NOWRAP)"/>
                        </xsl:for-each>
                        <xsl:value-of select="ilcd2xls:setCurrentColumn($originalColumn)"/>
                        <xsl:value-of select="ilcd2xls:setCurrentRow($currentRow+1)"/>

                        <xsl:if test="not(position()=last())">
                            <xsl:value-of select="ilcd2xls:addToNewLineBuffer(1)"/>
                        </xsl:if>
                    </xsl:for-each>

                    <xsl:value-of select="ilcd2xls:setCurrentColumn($originalColumn+4)"/>
                    <xsl:value-of select="ilcd2xls:setCurrentRow($originalRow)"/>

                    <xsl:value-of select="$NO_OUTPUT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="*[local-name()=$currentName]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="dataClass">
            <xsl:call-template name="decideDataClass">
                <xsl:with-param name="fieldName" select="$currentName"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="enumComment">
            <xsl:if test="$includeEnumDescriptions='true'">
                <xsl:call-template name="getEnumComment">
                    <xsl:with-param name="enumValue" select="$data"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>


        <xsl:if test="$data!=$NO_OUTPUT">
            <xsl:choose>
                <xsl:when test="$dataClass='data_enum'">
                    <xsl:value-of select="ilcd2xls:writeToCell(normalize-space($data), $enumComment, $STYLE_ITALIC)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ilcd2xls:writeToCell(normalize-space($data), $STYLE_NOWRAP)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>



    <xsl:template match="process:LCIAResults" priority="100">
        <xsl:variable name="LCIAResultsSheet">
            <xsl:value-of select="ilcd2xls:addSheet('LCIA Results')"/>
        </xsl:variable>
        <xsl:value-of select="ilcd2xls:switchToSheet(number($LCIAResultsSheet))"/>

        <xsl:call-template name="printExchangesTableHeaderRow">
            <xsl:with-param name="elements" select="$LCIAResultElements"/>
        </xsl:call-template>

        <xsl:apply-templates select="process:LCIAResult"/>

        <xsl:value-of select="ilcd2xls:setAutoSize(0)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(1)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(2)"/>
        <xsl:value-of select="ilcd2xls:setAutoSize(3)"/>
        <xsl:value-of select="ilcd2xls:setSize(4, 20000)"/>
        <xsl:value-of select="ilcd2xls:setSize(5, 20000)"/>
    </xsl:template>



    <xsl:template match="process:LCIAResult" priority="100">
        <xsl:call-template name="processExchangesData">
            <xsl:with-param name="list" select="$LCIAResultElements"/>
        </xsl:call-template>
        <xsl:value-of select="ilcd2xls:newLine()"/>
    </xsl:template>


    <xsl:template match="@xml:lang"/>


</xsl:stylesheet>
