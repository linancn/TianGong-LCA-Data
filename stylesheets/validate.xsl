<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common" xmlns:categories="http://lca.jrc.it/ILCD/Categories"
    xmlns:locations="http://lca.jrc.it/ILCD/Locations" xmlns:lciamethodologies="http://lca.jrc.it/ILCD/LCIAMethodologies" xmlns:process="http://lca.jrc.it/ILCD/Process"
    xmlns:lciamethod="http://lca.jrc.it/ILCD/LCIAMethod" xmlns:flow="http://lca.jrc.it/ILCD/Flow" xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty"
    xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup" xmlns:source="http://lca.jrc.it/ILCD/Source" xmlns:contact="http://lca.jrc.it/ILCD/Contact"
    xmlns:common="http://lca.jrc.it/ILCD/Common">

    <xsl:import href="common.xsl"/>

    <xsl:output indent="no" method="text"/>


    <xsl:variable name="version" select="'1.1'"/>

    <xsl:param name="disableCheckForeignCategories" select="false()"/>

    <xsl:param name="noEmptyClassification" select="false()"/>

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

    <xsl:param name="LCIAMethodologiesFile">
        <xsl:choose>
            <xsl:when test="/*/@LCIAMethodologies">
                <!--            <xsl:message>LCIAMethodologies were specified: <xsl:value-of select="/*/@LCIAMethodologies"/></xsl:message>-->
                <xsl:value-of select="/*/@LCIAMethodologies"/>
            </xsl:when>
            <xsl:when test="document(concat($pathPrefix, $defaultLCIAMethodologiesFile), /)/lciamethodologies:ILCDLCIAMethodologies">
                <!--            <xsl:message>LCIAMethodologies were not specified, using default file</xsl:message>-->
                <xsl:value-of select="concat($pathPrefix, $defaultLCIAMethodologiesFile)"/>
            </xsl:when>
            <xsl:otherwise>
                <!--            <xsl:message>LCIAMethodologies were not specified, using reference file</xsl:message>-->
                <xsl:value-of select="$referenceLCIAMethodologiesFile"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="validLCIAMethodologies">
        <xsl:choose>
            <xsl:when test="/*/@LCIAMethodologies">
                <xsl:copy-of select="document(/*/@LCIAMethodologies, /)"/>
            </xsl:when>
            <xsl:when test="document(concat($pathPrefix, $defaultLCIAMethodologiesFile), /)/lciamethodologies:ILCDLCIAMethodologies">
                <xsl:copy-of select="document(concat($pathPrefix, $defaultLCIAMethodologiesFile), /)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="document($referenceLCIAMethodologiesFile)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:variable name="referenceTypes" select="document('reference_types.xml')/referenceTypes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="/*/@version"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="ILCD">
        <xsl:for-each select="child::*">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>


    <!-- process dataset-specific validation -->
    <xsl:template match="process:processDataSet">

        <xsl:if test="(not(@metaDataOnly) or @metaDataOnly='false') and not(process:exchanges)">
            <xsl:call-template name="validationEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">metaDataOnly is false, but no exchanges section is present.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:apply-templates select="@*|*"/>
    </xsl:template>


    <xsl:template match="process:processDataSet/process:processInformation/process:quantitativeReference">
        <xsl:choose>
            <xsl:when test="@type='Reference flow(s)' and count(process:referenceToReferenceFlow)=0">
                <xsl:call-template name="validationEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">Type of Quantitative Reference is specified as "<xsl:value-of select="@type"/>", but no corresponding elements
                        ReferenceToReferenceFlow were found.</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type!='Reference flow(s)' and count(process:functionalUnitOrOther)=0">
                <xsl:call-template name="validationEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">Type of Quantitative Reference is specified as "<xsl:value-of select="@type"/>", but no corresponding elements
                        functionalUnitOrOther were found.</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- LCIA method datasets: methodologies -->
    <xsl:template match="lciamethod:LCIAMethodDataSet/lciamethod:LCIAMethodInformation/lciamethod:dataSetInformation/lciamethod:methodology">
        <xsl:call-template name="checkLCIAMethodology"/>
        <xsl:apply-templates select="*"/>
    </xsl:template>


    <!-- all datasets: locations -->
    <xsl:template
        match="process:processDataSet//process:geography/process:locationOfOperationSupplyOrProduction/@location | 
      process:processDataSet//process:geography/process:subLocationOfOperationSupplyOrProduction/@subLocation |
      process:processDataSet//process:exchange/process:location | 
      lciamethod:LCIAMethodDataSet/lciamethod:LCIAMethodInformation/lciamethod:geography/lciamethod:interventionLocation |
      lciamethod:LCIAMethodDataSet/lciamethod:LCIAMethodInformation/lciamethod:geography/lciamethod:interventionSubLocation |
      lciamethod:LCIAMethodDataSet/lciamethod:LCIAMethodInformation/lciamethod:geography/lciamethod:impactLocation |
      lciamethod:LCIAMethodDataSet/lciamethod:characterisationFactors/lciamethod:factor/lciamethod:location">
        <xsl:call-template name="checkLocation"/>
    </xsl:template>


    <!-- check references -->
  <xsl:template
    match="*[local-name()='referenceToCommissioner'          
      or local-name()='referenceToComplementingProcess' 
      or local-name()='referenceToCompleteReviewReport'             
      or local-name()='referenceToComplianceSystem' 
      or local-name()='referenceToContact'             
      or local-name()='referenceToConvertedOriginalDataSetFrom' 
      or local-name()='referenceToDataHandlingPrinciples' 
      or local-name()='referenceToDataSetFormat' 
      or local-name()='referenceToDataSetUseApproval' 
      or local-name()='referenceToDataSource' 
      or local-name()='referenceToEntitiesWithExclusiveAccess' 
      or local-name()='referenceToExternalDocumentation'             
      or local-name()='referenceToFlowDataSet' 
      or local-name()='referenceToFlowPropertyDataSet' 
      or local-name()='referenceToIncludedProcesses' 
      or local-name()='referenceToIncludedSubMethods' 
      or local-name()='referenceToLCAMethodDetails' 
      or local-name()='referenceToLCIAMethodDataSet' 
      or local-name()='referenceToLogo' 
      or local-name()='referenceToNameOfReviewerAndInstitution' 
      or local-name()='referenceToOwnershipOfDataSet' 
      or local-name()='referenceToPersonOrEntityEnteringTheData' 
      or local-name()='referenceToPersonOrEntityGeneratingTheDataSet' 
      or local-name()='referenceToPrecedingDataSetVersion' 
      or local-name()='referenceToRawDataDocumentation' 
      or local-name()='referenceToReferenceUnitGroup' 
      or local-name()='referenceToRegistrationAuthority' 
      or local-name()='referenceToSource' 
      or local-name()='referenceToSupportedImpactAssessmentMethods' 
      or local-name()='referenceToTechnicalSpecification' 
      or local-name()='referenceToTechnologyFlowDiagrammOrPicture' 
      or local-name()='referenceToTechnologyPictogramme' 
      or local-name()='referenceToUnchangedRepublication' ]">

        <xsl:call-template name="checkReference"/>
    </xsl:template>


    <!-- check a reference -->
    <xsl:template name="checkReference">

        <xsl:variable name="elementName" select="name()"/>
        <xsl:variable name="typeFound" select="@type"/>

        <!-- check for correct type attribute  -->
        <xsl:variable name="correctType">
            <xsl:call-template name="determineReferenceType">
                <xsl:with-param name="for" select="local-name()"/>
                <xsl:with-param name="referenceTypes" select="$referenceTypes"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="@type!=$correctType">
            <xsl:call-template name="validationEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">Element <xsl:value-of select="name()"/>: reference type "<xsl:value-of select="$correctType"/>" expected, but "<xsl:value-of
                        select="@type"/>" found.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- reference must have either refObjectId or uri, or both -->
        <xsl:if test="not(@refObjectId or @uri)">
            <xsl:call-template name="validationEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">Element <xsl:value-of select="$elementName"/>: a reference must have either refObjectId or uri attribute, or both.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- check if subReference element is allowed -->
        <xsl:if test="count(common:subReference)>0">
            <xsl:if
                test="$typeFound!='source data set' or local-name()='referenceToDataSetFormat' or local-name()='referenceToComplianceSystem' or local-name()='referenceToPrecedingDataSetVersion' or local-name()='referenceToTechnologyFlowDiagrammOrPicture' or local-name()='referenceToTechnologyPictogramme' or local-name()='logo'">
                <xsl:call-template name="validationEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">Element <xsl:value-of select="$elementName"/>: a subReference element is not allowed for this reference.</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

    </xsl:template>


    <xsl:template match="*[local-name()='classificationInformation']">
        <xsl:if test="$noEmptyClassification='true'">
            <xsl:if test="count(child::*)=0">
                <xsl:call-template name="warn">
                    <xsl:with-param name="message">classificationInformation is empty (checking with noEmptyClassification switch explicitly set to true).</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>


    <!-- check category information -->
    <xsl:template match="common:classification|common:elementaryFlowCategorization">
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="@name">
                    <xsl:value-of select="@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'ILCD'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- check foreign categories only if $disableCheckForeignCategories is not true -->
        <xsl:if test="$name='ILCD' or not($disableCheckForeignCategories='true')">
            <!-- prepare categories file -->
            <xsl:variable name="categoriesFile">
                <xsl:choose>
                    <xsl:when test="@classes">
                        <xsl:value-of select="@classes"/>
                    </xsl:when>
                    <xsl:when test="@categories">
                        <xsl:value-of select="@categories"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="local-name()='classification'">
                                <xsl:choose>
                                    <xsl:when test="document(concat($pathPrefix, $defaultCategoriesFile), /)/categories:CategorySystem">
                                        <xsl:value-of select="concat($pathPrefix, $defaultCategoriesFile)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$referenceCategoriesFile"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="document(concat($pathPrefix, $defaultFlowCategoriesFile), /)/categories:CategorySystem">
                                        <xsl:value-of select="concat($pathPrefix, $defaultFlowCategoriesFile)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$referenceFlowCategoriesFile"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="validCategories">
                <xsl:choose>
                    <xsl:when test="@classes">
                        <xsl:copy-of select="document(@classes, /)"/>
                    </xsl:when>
                    <xsl:when test="@categories">
                        <xsl:copy-of select="document(@categories, /)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="local-name()='classification'">
                                <xsl:choose>
                                    <xsl:when test="document(concat($pathPrefix, $defaultCategoriesFile), /)/categories:CategorySystem">
                                        <xsl:copy-of select="document(concat($pathPrefix, $defaultCategoriesFile), /)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="document($referenceCategoriesFile)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="document(concat($pathPrefix, $defaultFlowCategoriesFile), /)/categories:CategorySystem">
                                        <xsl:copy-of select="document(concat($pathPrefix, $defaultFlowCategoriesFile), /)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="document($referenceFlowCategoriesFile)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- check if categories file is available -->
            <xsl:choose>
                <xsl:when test="exslt:node-set($validCategories)/categories:CategorySystem">
                    <xsl:variable name="dataSetShortName">
                        <xsl:call-template name="determineDataSetShortName"/>
                    </xsl:variable>
                    <!-- checking categories-->
                    <xsl:call-template name="check_hierarchy">
                        <xsl:with-param name="messagePrefix">Validation error for <xsl:value-of select="local-name()"/> "<xsl:value-of select="$name"/>", using file "<xsl:value-of
                                select="$categoriesFile"/>"</xsl:with-param>
                        <xsl:with-param name="tree" select="exslt:node-set($validCategories)/categories:CategorySystem/categories:categories[@dataType=$dataSetShortName]"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="validationEvent">
                        <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                        <xsl:with-param name="message">Could not open classification file "<xsl:value-of select="$categoriesFile"/>" for checking classification "<xsl:value-of
                                select="$name"/>"</xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- template that checks if a location is valid -->
    <xsl:template name="checkLocation">
        <xsl:variable name="presentLocation" select="."/>

        <!-- if locations file is not available, report error -->
        <xsl:choose>
            <xsl:when test="exslt:node-set($validLocations)/locations:ILCDLocations">
                <xsl:if test="count(exslt:node-set($validLocations)/locations:ILCDLocations/locations:location[@value=$presentLocation])=0 and $presentLocation!=''">
                    <xsl:call-template name="validationEvent">
                        <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                        <xsl:with-param name="message">Location "<xsl:value-of select="."/>" is not valid in element/attribute <xsl:value-of select="name()"/></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="validationEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">Could not open locations file <xsl:value-of select="$locationsFile"/> for checking locations</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- template that checks if a LCIA methodology is valid -->
    <xsl:template name="checkLCIAMethodology">
        <xsl:variable name="presentMethodology" select="."/>

        <!-- if methodologies file is not available, report error -->
        <xsl:choose>
            <xsl:when test="exslt:node-set($validLCIAMethodologies)/lciamethodologies:ILCDLCIAMethodologies">
                <xsl:if
                    test="count(exslt:node-set($validLCIAMethodologies)/lciamethodologies:ILCDLCIAMethodologies/lciamethodologies:methodology[@name=$presentMethodology])=0 and $presentMethodology!=''">
                    <xsl:call-template name="validationEvent">
                        <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                        <xsl:with-param name="message">LCIA methodology "<xsl:value-of select="."/>" is not valid in element/attribute <xsl:value-of select="name()"
                            /></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="validationEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">Could not open LCIA methodologies file <xsl:value-of select="$LCIAMethodologiesFile"/> for checking LCIA
                        methodologies</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*|@*">
        <xsl:apply-templates select="*|@*"/>
    </xsl:template>

    <xsl:template match="text()"/>

    <!-- check version attribute -->
    <xsl:template match="/*/@version">
        <xsl:if test="string(.)!=$version">
            <xsl:call-template name="validationEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message">Invalid schema version found in input document: <xsl:value-of select="."/> found, <xsl:value-of select="$version"/>
                    expected.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
