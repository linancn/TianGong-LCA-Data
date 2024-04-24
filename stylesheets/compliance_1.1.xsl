<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:categories="http://lca.jrc.it/ILCD/Categories"
    xmlns:locations="http://lca.jrc.it/ILCD/Locations" xmlns:process="http://lca.jrc.it/ILCD/Process" xmlns:lciamethod="http://lca.jrc.it/ILCD/LCIAMethod"
    xmlns:flow="http://lca.jrc.it/ILCD/Flow" xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty" xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup"
    xmlns:source="http://lca.jrc.it/ILCD/Source" xmlns:contact="http://lca.jrc.it/ILCD/Contact" xmlns:common="http://lca.jrc.it/ILCD/Common"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common">

    <xsl:import href="common.xsl"/>

    <xsl:output indent="no" method="text"/>

    <xsl:param name="lang" select="'en'"/>

    <xsl:param name="hideWarnings" select="true()"/>

    <xsl:param name="maxWarnings" select="400"/>

    <!-- compliance documents UUIDs -->
    <xsl:variable name="complianceDocumentProcessAHighQuality" select="'d975693e-d4e0-4c43-a943-539d9f84cac8'"/>
    <xsl:variable name="complianceDocumentProcessABasicQuality" select="'d5693c8f-9308-4911-a334-fdbcce4b3ef7'"/>
    <xsl:variable name="complianceDocumentProcessAEstimate" select="'0cb541c2-116d-44d8-ad42-cbb23b551f2d'"/>
    <xsl:variable name="complianceDocumentProcessBHighQuality" select="'424b32b5-f279-4fd6-8d33-f106dbe64a95'"/>
    <xsl:variable name="complianceDocumentProcessBBasicQuality" select="'27389dd4-30dd-4f89-8ceb-6e878ec22cda'"/>
    <xsl:variable name="complianceDocumentProcessBEstimate" select="'7bc53f07-4fe0-4619-b08a-061d7eceb585'"/>
    <xsl:variable name="complianceDocumentProcessC1HighQuality" select="'85c70ebb-6909-462a-9efa-8d97cee275ee'"/>
    <xsl:variable name="complianceDocumentProcessC1BasicQuality" select="'55a9c38d-6190-4cd4-b589-45268e4c9475'"/>
    <xsl:variable name="complianceDocumentProcessC1Estimate" select="'9d42c820-1a10-49f3-a387-5a1d355d37ed'"/>
    <xsl:variable name="complianceDocumentProcessC2HighQuality" select="'43160353-af6f-40e7-bd9a-6930b960885a'"/>
    <xsl:variable name="complianceDocumentProcessC2BasicQuality" select="'fec6171f-e2ef-4bb6-934a-37fa323b254b'"/>
    <xsl:variable name="complianceDocumentProcessC2Estimate" select="'50d961dc-0b6a-4796-a2b5-1a12d4f53343'"/>

    <xsl:variable name="complianceDocumentProcessEntryLevel" select="'d92a1a12-2545-49e2-a585-55c259997756'"/>

    <xsl:variable name="complianceDocumentOtherDataSetTypes" select="'9ba3ac1e-6797-4cc0-afd5-1b8f7bf28c6a'"/>

    <xsl:variable name="apos" select="&quot;'&quot;"/>

    <xsl:param name="pathPrefix">
        <xsl:choose>
            <xsl:when test="local-name(/*)=$WRAPPER">
                <xsl:value-of select="'./'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'../'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:variable name="defaultLocationsFile" select="'ILCDLocations.xml'"/>
    <xsl:variable name="referenceLocationsFile" select="'ILCDLocations_Reference.xml'"/>

    <xsl:variable name="defaultCategoriesFile" select="'ILCDClassification.xml'"/>
    <xsl:variable name="referenceCategoriesFile" select="'ILCDClassification_Reference.xml'"/>

    <xsl:variable name="defaultFlowCategoriesFile" select="'ILCDFlowCategorization.xml'"/>
    <xsl:variable name="referenceFlowCategoriesFile" select="'ILCDFlowCategorization_Reference.xml'"/>

    <xsl:variable name="validCategories" select="document($referenceCategoriesFile)/categories:CategorySystem"/>

    <xsl:variable name="validFlowCategories" select="document($referenceFlowCategoriesFile)/categories:CategorySystem"/>

    <xsl:param name="locationsFile">
        <xsl:choose>
            <xsl:when test="/*/@locations">
                <!--            <xsl:message>locations were specified: <xsl:value-of select="/*/@locations"/></xsl:message>-->
                <xsl:value-of select="/*/@locations"/>
            </xsl:when>
            <xsl:when test="document(concat($pathPrefix, $defaultLocationsFile), /)/locations:ILCDLocations">
                <!--            <xsl:message>locations were not specified, using default file</xsl:message>-->
                <xsl:value-of select="concat($pathPrefix, $defaultLocationsFile)"/>
            </xsl:when>
            <xsl:otherwise>
                <!--            <xsl:message>locations were not specified, using reference file</xsl:message>-->
                <xsl:value-of select="$referenceLocationsFile"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="validLocations">
        <xsl:choose>
            <xsl:when test="/*/@locations">
                <xsl:copy-of select="document(/*/@locations, /)"/>
            </xsl:when>
            <xsl:when test="document(concat($pathPrefix, $defaultLocationsFile), /)/locations:ILCDLocations">
                <xsl:copy-of select="document(concat($pathPrefix, $defaultLocationsFile), /)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="document($referenceLocationsFile)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:param name="enumerationValuesSchemaFile" select="'../../schemas/ILCD_Common_EnumerationValues.xsd'"/>
    <xsl:variable name="enumerationValues" select="document($enumerationValuesSchemaFile, /)"/>

    <xsl:template match="*|@*">
        <xsl:apply-templates select="*|@*"/>
    </xsl:template>

    <xsl:template match="text()"/>

    <xsl:variable name="msgPrefix" select="'documentation compliance'"/>
    <xsl:variable name="msgPrefixPrefix" select="'Compliance error: '"/>



    <!-- process dataset-specific compliance -->
    <xsl:template match="/process:processDataSet">

        <xsl:call-template name="checkReferenceToComplianceSystem"/>

        <!-- check classification against reference classification -->
        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='Process']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:dataSetInformation/process:name/process:baseName[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('baseName[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="10"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:dataSetInformation/process:name/process:treatmentStandardsRoutes[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('treatmentStandardsRoutes[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="5"/>
                    <xsl:with-param name="uBound" select="30"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:dataSetInformation/process:name/process:mixAndLocationTypes[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('mixAndLocationTypes[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="5"/>
                    <xsl:with-param name="uBound" select="30"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:dataSetInformation/process:name/process:functionalUnitFlowProperties[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('functionalUnitFlowProperties[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="5"/>
                    <xsl:with-param name="uBound" select="30"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:dataSetInformation/process:classificationInformation/common:classification"/>
                    <xsl:with-param name="elementDesc" select="'classification'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:quantitativeReference"/>
                    <xsl:with-param name="elementDesc" select="'quantitativeReference'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:time/common:referenceYear"/>
                    <xsl:with-param name="elementDesc" select="'referenceYear'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:time/common:dataSetValidUntil"/>
                    <xsl:with-param name="elementDesc" select="'dataSetValidUntil'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:time/common:timeRepresentativenessDescription[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('timeRepresentativenessDescription[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="20"/>
                    <xsl:with-param name="uBound" select="100"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:geography/process:locationOfOperationSupplyOrProduction/@location"/>
                    <xsl:with-param name="elementDesc" select="'locationOfOperationSupplyOrProduction/@location'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="2"/>
                    <xsl:with-param name="uBound" select="20"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:geography/process:locationOfOperationSupplyOrProduction/process:descriptionOfRestrictions[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('locationOfOperationSupplyOrProduction/descriptionOfRestrictions[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="20"/>
                    <xsl:with-param name="uBound" select="200"/>
                </xsl:call-template>

                <xsl:for-each select="//process:geography/process:subLocationOfOperationSupplyOrProduction">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:descriptionOfRestrictions[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                        <xsl:with-param name="elementDesc"
                            select="concat('subLocationOfOperationSupplyOrProduction/descriptionOfRestrictions[@xml:lang=', $apos, $lang, $apos, ']')"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="20"/>
                        <xsl:with-param name="uBound" select="200"/>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:technology/process:technologyDescriptionAndIncludedProcesses[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('technologyDescriptionAndIncludedProcesses[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="200"/>
                    <xsl:with-param name="uBound" select="4000"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:technology/process:technologicalApplicability[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('technologicalApplicability[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="50"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:technology/process:referenceToTechnologyFlowDiagrammOrPicture"/>
                    <xsl:with-param name="elementDesc" select="'referenceToTechnologyFlowDiagrammOrPicture'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:if test="count(//process:mathematicalRelations/*)&gt;0">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="//process:mathematicalRelations/process:modelDescription[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                        <xsl:with-param name="elementDesc" select="concat('mathematicalRelations/modelDescription[@xml:lang=', $apos, $lang, $apos, ']')"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="50"/>
                        <xsl:with-param name="uBound" select="4000"/>
                    </xsl:call-template>
                </xsl:if>

                <xsl:for-each select="//process:mathematicalRelations/process:variableParameter">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="@name"/>
                        <xsl:with-param name="elementDesc" select="'variableParameter/@name'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="5"/>
                        <xsl:with-param name="uBound" select="15"/>
                    </xsl:call-template>

                    <xsl:if test="not(process:formula or process:meanValue)">
                        <xsl:call-template name="complianceEvent">
                            <xsl:with-param name="message"><xsl:if test="$msgPrefix">
                                    <xsl:value-of select="$msgPrefix"/>
                                    <xsl:text>: </xsl:text>
                                </xsl:if>At least one of variableParameter/formula and variableParameter/meanValue must be present and non-empty.</xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:comment[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                        <xsl:with-param name="elementDesc" select="concat('variableParameter/comment[@xml:lang=', $apos, $lang, $apos, ']')"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="5"/>
                        <xsl:with-param name="uBound" select="100"/>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:typeOfDataSet"/>
                    <xsl:with-param name="elementDesc" select="'typeOfDataSet'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:LCIMethodPrinciple"/>
                    <xsl:with-param name="elementDesc" select="'LCIMethodPrinciple'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:deviationsFromLCIMethodPrinciple[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromLCIMethodPrinciple[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:LCIMethodApproaches"/>
                    <xsl:with-param name="elementDesc" select="'LCIMethodApproaches'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:deviationsFromLCIMethodApproaches[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromLCIMethodApproaches[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:modellingConstants[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('modellingConstants[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:LCIMethodAndAllocation/process:deviationsFromModellingConstants[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromModellingConstants[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:dataCutOffAndCompletenessPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('dataCutOffAndCompletenessPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="100"/>
                    <xsl:with-param name="uBound" select="300"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:deviationsFromCutOffAndCompletenessPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromCutOffAndCompletenessPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:dataSelectionAndCombinationPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('dataSelectionAndCombinationPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="50"/>
                    <xsl:with-param name="uBound" select="300"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:deviationsFromSelectionAndCombinationPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromSelectionAndCombinationPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:dataTreatmentAndExtrapolationsPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('dataTreatmentAndExtrapolationsPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="50"/>
                    <xsl:with-param name="uBound" select="300"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:deviationsFromTreatmentAndExtrapolationPrinciples[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('deviationsFromTreatmentAndExtrapolationPrinciples[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:referenceToDataSource"/>
                    <xsl:with-param name="elementDesc" select="'dataSourcesTreatmentAndRepresentativeness/referenceToDataSource'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:percentageSupplyOrProductionCovered"/>
                    <xsl:with-param name="elementDesc" select="'percentageSupplyOrProductionCovered'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:modellingAndValidation/process:dataSourcesTreatmentAndRepresentativeness/process:useAdviceForDataSet[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('useAdviceForDataSet[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="100"/>
                    <xsl:with-param name="uBound" select="1000"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:completeness/process:completenessProductModel"/>
                    <xsl:with-param name="elementDesc" select="'completenessProductModel'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:completeness/process:referenceToSupportedImpactAssessmentMethods"/>
                    <xsl:with-param name="elementDesc" select="'referenceToSupportedImpactAssessmentMethods'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:completeness/process:completenessElementaryFlows"/>
                    <xsl:with-param name="elementDesc" select="'completenessElementaryFlows'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:for-each select="//process:modellingAndValidation/process:completeness/process:completenessElementaryFlows">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="@type"/>
                        <xsl:with-param name="elementDesc" select="'completenessElementaryFlows/@type'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="@value"/>
                        <xsl:with-param name="elementDesc" select="'completenessElementaryFlows/@value'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:modellingAndValidation/process:validation/process:review"/>
                    <xsl:with-param name="elementDesc" select="'review'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:for-each select="//process:modellingAndValidation/process:validation/process:review">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="common:scope"/>
                        <xsl:with-param name="elementDesc" select="'review/scope'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="noText" select="true()"/>
                    </xsl:call-template>

                    <xsl:for-each select="common:scope">
                        <xsl:call-template name="checkPresence">
                            <xsl:with-param name="element" select="common:method"/>
                            <xsl:with-param name="elementDesc" select="'review/scope/method'"/>
                            <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                            <xsl:with-param name="noText" select="true()"/>
                        </xsl:call-template>
                    </xsl:for-each>


                    <xsl:variable name="entryLevel">
                        <xsl:call-template name="isEntryLevelComplianceDeclared"/>
                    </xsl:variable>

                    <xsl:if test="not($entryLevel='true')">
                        <xsl:call-template name="checkPresence">
                            <xsl:with-param name="element" select="common:dataQualityIndicators/common:dataQualityIndicator"/>
                            <xsl:with-param name="elementDesc" select="'dataQualityIndicator'"/>
                            <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                            <xsl:with-param name="noText" select="true()"/>
                        </xsl:call-template>

                        <xsl:for-each select="common:dataQualityIndicators/common:dataQualityIndicator">
                            <xsl:call-template name="checkPresence">
                                <xsl:with-param name="element" select="@name"/>
                                <xsl:with-param name="elementDesc" select="'dataQualityIndicator/@name'"/>
                                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                            </xsl:call-template>
                            <xsl:call-template name="checkPresence">
                                <xsl:with-param name="element" select="@value"/>
                                <xsl:with-param name="elementDesc" select="'dataQualityIndicator/@value'"/>
                                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="common:reviewDetails[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                        <xsl:with-param name="elementDesc" select="concat('reviewDetails[@xml:lang=', $apos, $lang, $apos, ']')"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="1000"/>
                        <xsl:with-param name="uBound" select="3000"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="common:referenceToNameOfReviewerAndInstitution"/>
                        <xsl:with-param name="elementDesc" select="'referenceToNameOfReviewerAndInstitution'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="noText" select="true()"/>
                    </xsl:call-template>

                </xsl:for-each>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/common:commissionerAndGoal/common:referenceToCommissioner"/>
                    <xsl:with-param name="elementDesc" select="'referenceToCommissioner'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:administrativeInformation/common:commissionerAndGoal/common:intendedApplications[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('intendedApplicationss[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:dataGenerator/common:referenceToPersonOrEntityGeneratingTheDataSet"/>
                    <xsl:with-param name="elementDesc" select="'referenceToPersonOrEntityGeneratingTheDataSet'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:dataEntryBy/common:referenceToPersonOrEntityEnteringTheData"/>
                    <xsl:with-param name="elementDesc" select="'referenceToPersonOrEntityEnteringTheData'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:dataEntryBy/common:referenceToDataSetUseApproval"/>
                    <xsl:with-param name="elementDesc" select="'referenceToDataSetUseApproval'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:publicationAndOwnership/common:dateOfLastRevision"/>
                    <xsl:with-param name="elementDesc" select="'dateOfLastRevision'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:publicationAndOwnership/common:referenceToOwnershipOfDataSet"/>
                    <xsl:with-param name="elementDesc" select="'referenceToOwnershipOfDataSet'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:publicationAndOwnership/common:copyright"/>
                    <xsl:with-param name="elementDesc" select="'copyright'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//process:administrativeInformation/process:publicationAndOwnership/common:licenseType"/>
                    <xsl:with-param name="elementDesc" select="'licenseType'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element"
                        select="//process:administrativeInformation/process:publicationAndOwnership/common:accessRestrictions[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('accessRestrictions[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="4"/>
                    <xsl:with-param name="uBound" select="400"/>
                </xsl:call-template>

                <xsl:for-each select="//process:exchanges/process:exchange">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:referenceToFlowDataSet"/>
                        <xsl:with-param name="elementDesc" select="'exchange/referenceToFlowDataSet'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="noText" select="true()"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:exchangeDirection"/>
                        <xsl:with-param name="elementDesc" select="'exchange/exchangeDirection'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:meanAmount"/>
                        <xsl:with-param name="elementDesc" select="'exchange/meanAmount'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="process:resultingAmount"/>
                        <xsl:with-param name="elementDesc" select="'exchange/resultingAmount'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>

                    <xsl:if
                        test="/process:processDataSet/process:modellingAndValidation/process:LCIMethodAndAllocation/process:typeOfDataSet='Unit process, single operation' or /process:processDataSet/process:modellingAndValidation/process:LCIMethodAndAllocation/process:typeOfDataSet='Unit process, black box'">
                        <xsl:call-template name="checkPresence">
                            <xsl:with-param name="element" select="process:dataSourceType"/>
                            <xsl:with-param name="elementDesc" select="'exchange/dataSourceType'"/>
                            <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        </xsl:call-template>

                        <xsl:call-template name="checkPresence">
                            <xsl:with-param name="element" select="process:dataDerivationTypeStatus"/>
                            <xsl:with-param name="elementDesc" select="'exchange/dataDerivationTypeStatus'"/>
                            <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>

            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>


    <!-- flow dataset-specific compliance -->
    <xsl:template match="/flow:flowDataSet">

        <xsl:call-template name="checkReferenceToComplianceSystem"/>

        <!-- check (elementary) flow categories against reference categories -->
        <xsl:choose>
            <xsl:when test="/flow:flowDataSet/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet='Elementary flow'">
                <xsl:for-each select="//common:elementaryFlowCategorization[@name='ILCD' or not(@name)]">
                    <xsl:call-template name="check_hierarchy">
                        <xsl:with-param name="tree" select="$validFlowCategories/categories:categories[@dataType='Flow']"/>
                        <xsl:with-param name="messagePrefix" select="concat($msgPrefixPrefix, $msgPrefix)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
                    <xsl:call-template name="check_hierarchy">
                        <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='Flow']"/>
                        <xsl:with-param name="messagePrefix" select="concat($msgPrefixPrefix, $msgPrefix)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='Flow']"/>
                <xsl:with-param name="messagePrefix" select="concat($msgPrefixPrefix, $msgPrefix)"/>
            </xsl:call-template>
        </xsl:for-each>


        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//flow:dataSetInformation/flow:name/flow:baseName[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('baseName[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="10"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>

                <!-- elementaryFlowCategorization for elementary flows -->
                <xsl:if test="/flow:flowDataSet/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet='Elementary flow'">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="//flow:dataSetInformation/flow:classificationInformation/common:elementaryFlowCategorization/common:category"/>
                        <xsl:with-param name="elementDesc" select="'elementaryFlowCategorization'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                </xsl:if>

                <!-- classification for product and waste flows -->
                <xsl:if
                    test="/flow:flowDataSet/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet='Product flow' or /flow:flowDataSet/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet='Waste flow'">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="//flow:dataSetInformation/flow:classificationInformation/common:classification/common:class"/>
                        <xsl:with-param name="elementDesc" select="'classification'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                </xsl:if>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="/flow:flowDataSet/flow:flowInformation/flow:quantitativeReference/flow:referenceToReferenceFlowProperty"/>
                    <xsl:with-param name="elementDesc" select="'referenceToReferenceFlowProperty'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="/flow:flowDataSet/flow:modellingAndValidation/flow:LCIMethod/flow:typeOfDataSet"/>
                    <xsl:with-param name="elementDesc" select="'typeOfDataSet'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                </xsl:call-template>

                <xsl:for-each select="/flow:flowDataSet/flow:flowProperties/flow:flowProperty">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="flow:meanValue"/>
                        <xsl:with-param name="elementDesc" select="'flowProperty/meanvalue'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                </xsl:for-each>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!-- LCIA method dataset-specific compliance -->
    <xsl:template match="/lciamethod:LCIAMethodDataSet">

        <!--        <xsl:call-template name="checkReferenceToComplianceSystem"/>-->

        <!-- check classification against reference classification -->
        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='LCIAMethod']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>



    <!-- flow property dataset-specific compliance -->
    <xsl:template match="/flowproperty:flowPropertyDataSet">

        <xsl:call-template name="checkReferenceToComplianceSystem"/>

        <!-- check classification against reference classification -->
        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='FlowProperty']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//flowproperty:dataSetInformation/common:name[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('name[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="3"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//flowproperty:quantitativeReference/flowproperty:referenceToReferenceUnitGroup"/>
                    <xsl:with-param name="elementDesc" select="'referenceToReferenceUnitGroup'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>






    <!-- unit group dataset-specific compliance -->
    <xsl:template match="/unitgroup:unitGroupDataSet">

        <xsl:call-template name="checkReferenceToComplianceSystem"/>

        <!-- check classification against reference classification -->
        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='UnitGroup']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//unitgroup:dataSetInformation/common:name[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('name[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="3"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//unitgroup:quantitativeReference/unitgroup:referenceToReferenceUnit"/>
                    <xsl:with-param name="elementDesc" select="'referenceToReferenceUnit'"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="noText" select="true()"/>
                </xsl:call-template>

                <xsl:for-each select="//unitgroup:units/unitgroup:unit">
                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="unitgroup:name"/>
                        <xsl:with-param name="elementDesc" select="'units/unit/name'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                        <xsl:with-param name="lBound" select="1"/>
                        <xsl:with-param name="uBound" select="15"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="unitgroup:meanValue"/>
                        <xsl:with-param name="elementDesc" select="'units/unit/meanValue'"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>

                    <xsl:call-template name="checkPresence">
                        <xsl:with-param name="element" select="unitgroup:generalComment[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                        <xsl:with-param name="elementDesc" select="concat('units/unit/generalComment[@xml:lang=', $apos, $lang, $apos, ']')"/>
                        <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    </xsl:call-template>
                </xsl:for-each>

            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!-- source dataset-specific compliance -->
    <xsl:template match="/source:sourceDataSet">

        <!-- check classification against reference classification -->
        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='Source']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//source:dataSetInformation/common:shortName[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('shortName[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="3"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!-- contact dataset-specific compliance -->
    <xsl:template match="/contact:contactDataSet">

        <xsl:for-each select="//common:classification[@name='ILCD' or not(@name)]">
            <xsl:call-template name="check_hierarchy">
                <xsl:with-param name="tree" select="$validCategories/categories:categories[@dataType='Contact']"/>
                <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="analyzeWarnings">
            <xsl:with-param name="warnings">

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//contact:dataSetInformation/common:shortName[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('shortName[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="2"/>
                    <xsl:with-param name="uBound" select="40"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//contact:dataSetInformation/common:name[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('name[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="3"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>

                <xsl:call-template name="checkPresence">
                    <xsl:with-param name="element" select="//contact:dataSetInformation/contact:centralContactPoint[@xml:lang=$lang or ($lang='en' and not(@xml:lang))]"/>
                    <xsl:with-param name="elementDesc" select="concat('centralContactPoint[@xml:lang=', $apos, $lang, $apos, ']')"/>
                    <xsl:with-param name="messagePrefix" select="$msgPrefix"/>
                    <xsl:with-param name="lBound" select="3"/>
                    <xsl:with-param name="uBound" select="50"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>





    <!-- analyze number of warnings, and throw an error if maximum number of warnings has been exceeded
         this template uses an exslt extension function and therefore has not been moved to common.xsl to keep dependencies to a minimum    
    -->
    <xsl:template name="analyzeWarnings">
        <xsl:param name="warnings"/>
        <xsl:variable name="warningsNodeSet" select="exslt:node-set($warnings)"/>
        <xsl:variable name="numberOfWarnings" select="count($warningsNodeSet/warning)"/>

        <!-- show warnings if $hideWarnings is not true -->
        <xsl:if test="$hideWarnings!='true' or $numberOfWarnings&gt;$maxWarnings">
            <xsl:for-each select="exslt:node-set($warnings)/warning">
                <xsl:message>
                    <xsl:value-of select="@message"/>
                </xsl:message>
            </xsl:for-each>
        </xsl:if>

        <!-- issue an error if the max number of warnings has been exceeded -->
        <xsl:if test="$numberOfWarnings&gt;$maxWarnings">
            <xsl:call-template name="complianceEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">
                    <xsl:if test="$msgPrefix">
                        <xsl:value-of select="$msgPrefix"/>
                        <xsl:text>: </xsl:text>
                    </xsl:if>
                    <xsl:text>There have been </xsl:text>
                    <xsl:value-of select="$numberOfWarnings"/>
                    <xsl:text> warnings. The maximum number of warnings (</xsl:text>
                    <xsl:value-of select="$maxWarnings"/>
                    <xsl:text>) has been exceeded.</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>



    <xsl:template name="checkReferenceToComplianceSystem">
        <xsl:variable name="referencePosition">
            <xsl:call-template name="getReferenceToComplianceSystemPosition"/>
        </xsl:variable>

        <xsl:if test="string(number($referencePosition))='NaN'">
            <xsl:call-template name="complianceEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">
                    <xsl:text>General compliance: Could not find proper reference to compliance system</xsl:text>
                    <xsl:text>.</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- detect position of reference to ILCD compliance system -->
    <xsl:template name="getReferenceToComplianceSystemPosition">
        <xsl:for-each
            select="/*/*[local-name()='modellingAndValidation']/*[local-name()='complianceDeclarations']/*[local-name()='compliance']/*[local-name()='referenceToComplianceSystem']">

            <xsl:variable name="declaredUUID" select="@refObjectId"/>
            <xsl:variable name="declaredURI" select="@uri"/>

            <xsl:variable name="match">
                <xsl:call-template name="checkReferenceToComplianceDocument">
                    <xsl:with-param name="uri" select="$declaredURI"/>
                    <xsl:with-param name="uuid" select="$declaredUUID"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="contains($match,'true')">
                <xsl:value-of select="position()"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- checks a given uri and uuid whether it matches a valid compliance document -->
    <!-- returns a string that can be 'true' or 'truetrue' or 'true(entry-level)true' -->
    <xsl:template name="checkReferenceToComplianceDocument">
        <xsl:param name="uuid"/>
        <xsl:param name="uri"/>

        <xsl:variable name="uuidLC" select="translate($uuid, 'ABCDEF', 'abcdef')"/>
        <xsl:variable name="uriLC" select="translate($uri, 'ABCDEF', 'abcdef')"/>

        <xsl:choose>
            <xsl:when test="local-name(/*)='processDataSet'">
                <xsl:variable name="matchRefObjectId">

                    <xsl:value-of
                        select="   $uuidLC = $complianceDocumentProcessAHighQuality or 
                               $uuidLC = $complianceDocumentProcessABasicQuality or 
                               $uuidLC = $complianceDocumentProcessAEstimate or 
                               $uuidLC = $complianceDocumentProcessBHighQuality or 
                               $uuidLC = $complianceDocumentProcessBBasicQuality or 
                               $uuidLC = $complianceDocumentProcessBEstimate or 
                               $uuidLC = $complianceDocumentProcessC1HighQuality or 
                               $uuidLC = $complianceDocumentProcessC1BasicQuality or 
                               $uuidLC = $complianceDocumentProcessC1Estimate or 
                               $uuidLC = $complianceDocumentProcessC2HighQuality or 
                               $uuidLC = $complianceDocumentProcessC2BasicQuality or 
                               $uuidLC = $complianceDocumentProcessC2Estimate or
                               $uuidLC = $complianceDocumentProcessEntryLevel
                               "/>
                    <xsl:if test="$uuidLC = $complianceDocumentProcessEntryLevel">
                        <xsl:value-of select="'(entry-level)'"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="matchURI">
                    <xsl:value-of
                        select=" contains($uriLC, $complianceDocumentProcessAHighQuality) or  
                                           contains($uriLC, $complianceDocumentProcessABasicQuality) or  
                                           contains($uriLC, $complianceDocumentProcessAEstimate) or  
                                           contains($uriLC, $complianceDocumentProcessBHighQuality) or  
                                           contains($uriLC, $complianceDocumentProcessBBasicQuality) or  
                                           contains($uriLC, $complianceDocumentProcessBEstimate) or  
                                           contains($uriLC, $complianceDocumentProcessC1HighQuality) or  
                                           contains($uriLC, $complianceDocumentProcessC1BasicQuality) or  
                                           contains($uriLC, $complianceDocumentProcessC1Estimate) or  
                                           contains($uriLC, $complianceDocumentProcessC2HighQuality) or  
                                           contains($uriLC, $complianceDocumentProcessC2BasicQuality) or  
                                           contains($uriLC, $complianceDocumentProcessC2Estimate) or
                                           contains($uriLC, $complianceDocumentProcessEntryLevel)
                                         "/>
                    <xsl:if test="contains($uriLC, $complianceDocumentProcessEntryLevel)">
                        <xsl:value-of select="'(entry-level)'"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="concat($matchRefObjectId, $matchURI)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="matchRefObjectId" select="$uuidLC = $complianceDocumentOtherDataSetTypes"/>
                <xsl:variable name="matchURI" select="contains($uriLC, $complianceDocumentOtherDataSetTypes)"/>
                <xsl:value-of select="$matchRefObjectId or $matchURI"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="isEntryLevelComplianceDeclared">
        <xsl:for-each
            select="/*/*[local-name()='modellingAndValidation']/*[local-name()='complianceDeclarations']/*[local-name()='compliance']/*[local-name()='referenceToComplianceSystem']">

            <xsl:variable name="declaredUUID" select="@refObjectId"/>
            <xsl:variable name="declaredURI" select="@uri"/>

            <xsl:variable name="match">
                <xsl:call-template name="checkReferenceToComplianceDocument">
                    <xsl:with-param name="uri" select="$declaredURI"/>
                    <xsl:with-param name="uuid" select="$declaredUUID"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="contains($match,'entry-level')">
                <xsl:value-of select="true()"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
