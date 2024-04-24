<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:categories="http://lca.jrc.it/ILCD/Categories"
    xmlns:process="http://lca.jrc.it/ILCD/Process" xmlns:lciamethod="http://lca.jrc.it/ILCD/LCIAMethod" xmlns:flow="http://lca.jrc.it/ILCD/Flow"
    xmlns:flowproperty="http://lca.jrc.it/ILCD/FlowProperty" xmlns:unitgroup="http://lca.jrc.it/ILCD/UnitGroup" xmlns:source="http://lca.jrc.it/ILCD/Source"
    xmlns:contact="http://lca.jrc.it/ILCD/Contact" xmlns:common="http://lca.jrc.it/ILCD/Common" xmlns:ilcd="http://lca.jrc.it/ILCD"
    exclude-result-prefixes="xsl xs categories process lciamethod flow flowproperty unitgroup source contact common ilcd">

    <!-- default language for which language codes are not displayed -->
    <xsl:param name="defaultLanguage" select="'en'"/>

    <!-- alternative language to fall back to if no data is available for the default language specified above -->
    <xsl:param name="alternativeLanguage" select="'de'"/>

    <!-- display all data in all languages -->
    <xsl:param name="showAllLanguages" select="false()"/>

    <!-- with this switch, all attempts to load information from other documents can be turned off -->
    <xsl:param name="doNotLoadExternalResources" select="false()"/>

    <!-- If set to true(), try to load resources that are referenced from within datasets and highlight entry if resource is not available.
		  This is helpful for checking if a set of dataset files is complete and all links are working.
 		   - this feature is experimental
		   - this may not work in certain versions of Internet Explorer and can cause unexpected results in other browsers
		   - works best with Firefox and Safari
	-->
    <xsl:param name="checkResourceAvailablity" select="false()"/>

    <xsl:variable name="schemaDocument" select="document(concat($schemaPath, $schema), /)"/>

    <!-- common schema files -->
    <!-- all calls to document() are relative to the base URI of the instance document being transformed -->
    <xsl:variable name="schemaSecondary1" select="document(concat($schemaPath, 'ILCD_Common_Groups.xsd'), /)"/>
    <xsl:variable name="schemaSecondary2" select="document(concat($schemaPath, 'ILCD_Common_DataTypes.xsd'), /)"/>
    <xsl:variable name="schemaSecondary3" select="document(concat($schemaPath, 'ILCD_Common_Validation.xsd'), /)"/>
    <xsl:variable name="schemaEnums" select="document(concat($schemaPath, 'ILCD_Common_EnumerationValues.xsd'), /)"/>

    <xsl:key name="schemaDocumentKey" match="xs:element|xs:attribute" use="@name|@ref"/>
    <xsl:key name="schemaDocumentElementKey" match="xs:element" use="@name|@ref"/>
    <xsl:key name="schemaDocumentEnumKey" match="xs:enumeration" use="@value"/>
    <xsl:key name="schemaDocumentEnumTypeKey" match="xs:simpleType" use="@name|@ref"/>

    <xsl:param name="resourceNotFoundMessage">RESOURCE NOT FOUND</xsl:param>
    <xsl:variable name="resourceNotFoundCSSClass">warning</xsl:variable>

    <xsl:variable name="break" select="'&#160;'"/>


    <!-- root template -->
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:call-template name="getCompleteTitle"/>
                </title>
                <style type="text/css">
					<xsl:text>
						table.top {
							border: 1px solid #AB845D; 
							background-color: #FFFBF3;
						}
						tr {
							background-color:#FFFFFF;
						}   
						a {
							color:#0A4755;
						}
						a:active, a:visited {
							color:#894C0F;
						}

						/* tooltip styles */
						a.info {
						    position:relative; 
						    z-index:24;
						    color:#000000;
						    text-decoration:none
						}
						
						a.info:hover {
							z-index:25; 
							background-color:#FFE8B7;
						}
						
						a.info span {
							display: none
						}
						
						a.info:hover span {                                               
						    display:block;
						    position:absolute;
						    top:2em; left:2em; width:25em;
						    border:1px solid #7BCBDE;
						    background-color:#B9EDF7; 
							color:#000000;
						    text-align: left
						}
			
						/*   general styles  */                                               
						.title 		{ 	
							font-family: Helvetica,Arial,sans serif;
							font-size: 14;
							font-weight: bold;
							vertical-align: top;
							background-color: #fc9336 ;
							color: #000000;
						}
						.toc 		{ 	
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							font-weight: normal;
							vertical-align: top;
							background-color: #FFD783 ;
							color: #000000;
						}
						.section { 	
  						font-family: Helvetica,Arial,sans serif;
  						font-size: 14;
  						font-weight: bold;
  						vertical-align: top;   
  						background-color: #ffb951  ;
  						color: #000000;
						}
						.root { 	
  						font-family: Helvetica,Arial,sans serif;
  						font-size: 14;
  						font-weight: bold;
  						vertical-align: top;   
  						background-color: #ffb951  ;
  						color: #000000;
						}
						.subsection { 	
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							font-weight: bold;
							vertical-align: top;   
							background-color: #ffd783  ;
							color: #000000;
						}
						.fieldname { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							font-weight: normal;
							vertical-align: top;   
							background-color: #FFF3D9;
							color: #002277  ;
						}
						.data          { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							background-color: #FFFFFF;
							color: #000000;
							font-weight: normal;						
						}
						.data_neutral     { 
							font-weight: normal;
						}
						.data_enum     { 
							font-weight: normal;
							font-style: italic;
						}
						.referencename   { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							font-weight: bold;
							background-color: #FFFFFF ;
							color: #002277  ;
						}
						.referencedata   { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 12;
							color: red;
							background-color: #FFFFFF ;
							color: #000000;
						}
						.table_header   { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 11;
							font-weight: normal;
							background-color: #ffeece  ;
							color: #002277  ;
						}
						.exchanges_section   { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 9;
							background-color: #ffeece ;
							color: #000000;
						}
						.exchanges_data   { 
							font-family: Helvetica,Arial,sans serif;
							font-size: 9;
							font-weight: bold;
							background-color: #FFFFFF ;
							color: #000000;
						}
						tr.highlight td.data {
							border-width: 2px;
							border-style: solid;
							border-color: #A2D3DE;
						}
						.lang {
							font-weight: normal;
							color: grey;			
						}
						.warning {
							font-weight: bold;
							color: red;			
						}
					</xsl:text>
				</style>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>


    <!-- root element -->
    <xsl:template match="/*">
        <table class="top" cellpadding="3px">
            <tr>
                <td class="title" colspan="2">
                    <xsl:call-template name="getCompleteTitle"/>
                </td>
            </tr>
            <xsl:if test="local-name()='processDataSet' or local-name()='LCIAMethodDataSet'">
                <xsl:call-template name="makeToc"/>
            </xsl:if>
            <xsl:apply-templates/>
        </table>
    </xsl:template>


    <!-- build title -->
    <xsl:template name="getCompleteTitle">
        <xsl:call-template name="getFieldShortDesc">
            <xsl:with-param name="fieldName" select="local-name(/*)"/>
        </xsl:call-template>: <xsl:call-template name="getTitle"/><xsl:text> (</xsl:text><xsl:value-of select="$defaultLanguage"/><xsl:text>)</xsl:text>
    </xsl:template>


    <!-- build table of contents -->
    <xsl:template name="makeToc">
        <tr>
            <td class="toc" colspan="2"> Table of Contents: <xsl:for-each select="/*/*">
                    <xsl:variable name="fieldShortDesc">
                        <xsl:call-template name="getFieldShortDesc">
                            <xsl:with-param name="fieldName" select="local-name()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <a href="#{local-name()}">
                        <xsl:value-of select="$fieldShortDesc"/>
                    </a>
                    <xsl:if test="position()!=last()">
                        <xsl:text>  -  </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>


    <!-- main sections -->
    <xsl:template match="/*/*[local-name()!='exchanges']">
        <xsl:variable name="descendantRequirements">
            <xsl:for-each select="descendant-or-self::*">
                <xsl:call-template name="getFieldRequirement">
                    <xsl:with-param name="fieldName" select="local-name()"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="displaySection">
            <xsl:call-template name="decideFieldDisplay">
                <xsl:with-param name="fieldRequirement" select="$descendantRequirements"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="not(local-name()='modellingAndValidation' and $showFieldsMode='mandatory')">
            <xsl:if test="$displaySection='true'">
                <xsl:variable name="fieldShortDesc">
                    <xsl:call-template name="getFieldShortDesc">
                        <xsl:with-param name="fieldName" select="local-name()"/>
                    </xsl:call-template>
                </xsl:variable>
                <tr>
                    <td class="section" colspan="2" style="padding-left: 10px;">
                        <a name="{local-name()}"/>
                        <xsl:value-of select="$fieldShortDesc"/>
                    </td>
                </tr>
                <xsl:apply-templates/>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- ignore extensions -->
    <xsl:template match="common:other" priority="1000"/>


    <!-- subsections -->
    <xsl:template match="/*/*/*[local-name()!='exchange' and local-name()!='referenceToFlowDataSet']">
        <xsl:variable name="descendantRequirements">
            <xsl:for-each select="descendant-or-self::*">
                <xsl:call-template name="getFieldRequirement">
                    <xsl:with-param name="fieldName" select="name()"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="displaySection">
            <xsl:call-template name="decideFieldDisplay">
                <xsl:with-param name="fieldRequirement" select="$descendantRequirements"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="$displaySection='true'">
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
            <xsl:choose>
                <xsl:when test="local-name()='publicationAndOwnership'">
                    <xsl:call-template name="masterTemplate">
                        <xsl:with-param name="currentName" select="'common:UUID'"/>
                        <xsl:with-param name="paddingleft" select="30"/>
                        <xsl:with-param name="data">
                            <xsl:value-of select="//*[local-name()='UUID']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="local-name()='complianceDeclarations'">
                    <tr>
                        <td colspan="2">
                            <table>
                                <tr>
                                    <xsl:apply-templates select="child::*"/>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- don't display UUID at its actual position -->
    <xsl:template match="//*[local-name()='UUID']"/>


    <!-- categories -->
    <xsl:template match="*[local-name()='classificationInformation']">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="common:classification/@name">
        <xsl:text> (</xsl:text>
        <xsl:choose>
            <xsl:when test="parent::*/@classes">
                <a href="{parent::*/@classes}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template match="common:classification">
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

        <tr>
            <td class="fieldname" style="padding-left: {(number(count(ancestor::*)-1)*10)}px;">
                <a class="info" href="javascript:void(0);">
                    <xsl:value-of select="$fieldShortDesc"/>
                    <span>
                        <xsl:value-of select="$comment"/>
                    </span>
                </a>
                <xsl:apply-templates select="@name"/>
            </td>
            <td class="data">
                <table class="data">
                    <tr>
                        <td class="fieldname">
                            <xsl:variable name="currentName" select="'class'"/>
                            <xsl:variable name="displayField">
                                <xsl:call-template name="decideFieldDisplay">
                                    <xsl:with-param name="fieldRequirement">
                                        <xsl:call-template name="getFieldRequirement">
                                            <xsl:with-param name="fieldName" select="$currentName"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$displayField='true'">
                                <xsl:for-each select="*[@level=0]">
                                    <xsl:variable name="fieldShortDesc2">
                                        <xsl:call-template name="getFieldShortDesc">
                                            <xsl:with-param name="fieldName" select="$currentName"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="comment2">
                                        <xsl:call-template name="getComment">
                                            <xsl:with-param name="fieldName" select="$currentName"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <a class="info" href="javascript:void(0);">
                                        <xsl:value-of select="$fieldShortDesc2"/>
                                        <span>
                                            <xsl:value-of select="$comment2"/>
                                        </span>
                                    </a>
                                </xsl:for-each>
                            </xsl:if>

                            <xsl:variable name="currentName2" select="'level'"/>
                            <xsl:variable name="displayField2">
                                <xsl:call-template name="decideFieldDisplay">
                                    <xsl:with-param name="fieldRequirement">
                                        <xsl:call-template name="getFieldRequirement">
                                            <xsl:with-param name="fieldName" select="$currentName2"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$displayField2='true'">
                                <xsl:for-each select="*[@level!=0]">
                                    <xsl:sort select="@level" data-type="number" order="ascending"/>
                                    <xsl:variable name="fieldShortDesc2">
                                        <xsl:call-template name="getFieldShortDesc">
                                            <xsl:with-param name="fieldName" select="$currentName2"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="comment2">
                                        <xsl:call-template name="getComment">
                                            <xsl:with-param name="fieldName" select="$currentName2"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <a class="info" href="javascript:void(0);">
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="translate($fieldShortDesc2, '%', @level)"/>
                                        <span>
                                            <xsl:value-of select="$comment2"/>
                                        </span>
                                    </a>
                                </xsl:for-each>
                            </xsl:if>
                        </td>
                    </tr>
                    <tr>
                        <td class="data">
                            <xsl:variable name="currentName3" select="'class'"/>
                            <xsl:variable name="displayField3">
                                <xsl:call-template name="decideFieldDisplay">
                                    <xsl:with-param name="fieldRequirement">
                                        <xsl:call-template name="getFieldRequirement">
                                            <xsl:with-param name="fieldName" select="$currentName3"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$displayField3='true'">
                                <xsl:for-each select="*[@level=0]">
                                    <xsl:value-of select="text()"/>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:variable name="currentName4" select="'level'"/>
                            <xsl:variable name="displayField4">
                                <xsl:call-template name="decideFieldDisplay">
                                    <xsl:with-param name="fieldRequirement">
                                        <xsl:call-template name="getFieldRequirement">
                                            <xsl:with-param name="fieldName" select="$currentName4"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$displayField4='true'">
                                <xsl:for-each select="*[@level!=0]">
                                    <xsl:sort select="@level" data-type="number" order="ascending"/>
                                    <xsl:text> / </xsl:text>
                                    <xsl:value-of select="text()"/>
                                </xsl:for-each>
                            </xsl:if>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>


    <!-- references -->
    <!-- This renders a reference in a standard way and the pattern includes all reference elements. For any special treatment, 
        corresponding templates need to have a higher priority. -->
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
            or local-name()='referenceToEntity'
            or local-name()='referenceToEntitiesWithExclusiveAccess' 
            or local-name()='referenceToExternalDocumentation'             
            or local-name()='referenceToFlowDataSet' 
            or local-name()='referenceToFlowPropertyDataSet'
            or local-name()='referenceToIncludedMethods'
            or local-name()='referenceToIncludedNormalisationDataSets'
            or local-name()='referenceToIncludedProcesses' 
            or local-name()='referenceToIncludedSubMethods'
            or local-name()='referenceToIncludedWeightingDataSets'
            or local-name()='referenceToLCAMethodDetails' 
            or local-name()='referenceToLCIAMethodDataSet' 
            or local-name()='referenceToLCIAMethodFlowDiagrammOrPicture' 
            or local-name()='referenceToLogo'
            or local-name()='referenceToMethodologyFlowChart'
            or local-name()='referenceToModelSource'
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
            or local-name()='referenceToUnchangedRepublication'
            or local-name()='referenceQuantity']">

        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="fieldDescSuffix"><xsl:text> (</xsl:text><xsl:value-of select="@type"/>)</xsl:with-param>
            <xsl:with-param name="disableDescendantCount" select="true()"/>
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <xsl:call-template name="renderReference"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- reviews -->
    <xsl:template match="*[local-name()='review']">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="disableSiblingCount" select="true()"/>
            <xsl:with-param name="data">
                <xsl:call-template name="printEnumData">
                    <xsl:with-param name="value" select="@type"/>
                </xsl:call-template>
                <table border="0" cellspacing="7px">
                    <xsl:if test="*[local-name()='scope']">
                        <tr>
                            <td class="fieldname">
                                <xsl:variable name="fieldShortDesc">
                                    <xsl:call-template name="getFieldShortDesc">
                                        <xsl:with-param name="fieldName" select="'scope'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="comment">
                                    <xsl:call-template name="getComment">
                                        <xsl:with-param name="fieldName" select="'scope'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <a class="info" href="javascript:void(0);">
                                    <xsl:value-of select="$fieldShortDesc"/>
                                    <span>
                                        <xsl:value-of select="$comment"/>
                                    </span>
                                </a>
                            </td>
                            <xsl:if test="*[local-name()='scope']/*[local-name()='method']">
                                <td class="fieldname">
                                    <xsl:variable name="fieldShortDesc2">
                                        <xsl:call-template name="getFieldShortDesc">
                                            <xsl:with-param name="fieldName" select="'method'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="comment2">
                                        <xsl:call-template name="getComment">
                                            <xsl:with-param name="fieldName" select="'method'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <a class="info" href="javascript:void(0);">
                                        <xsl:value-of select="$fieldShortDesc2"/>
                                        <span>
                                            <xsl:value-of select="$comment2"/>
                                        </span>
                                    </a>
                                </td>
                            </xsl:if>
                        </tr>

                        <xsl:for-each select="*[local-name()='scope']">
                            <tr>
                                <xsl:call-template name="renderCell">
                                    <xsl:with-param name="data" select="@name"/>
                                </xsl:call-template>
                                <xsl:for-each select="*[local-name()='method' and position()=1]">
                                    <xsl:call-template name="renderCell">
                                        <xsl:with-param name="data" select="@name"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </tr>
                            <xsl:for-each select="*[local-name()='method' and position()!=1]">
                                <tr>
                                    <td/>
                                    <xsl:call-template name="renderCell">
                                        <xsl:with-param name="data" select="@name"/>
                                    </xsl:call-template>
                                </tr>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:if>
                </table>

            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="*[local-name()!='scope']"/>
    </xsl:template>

    <xsl:template name="renderCell">
        <xsl:param name="currentName" select="local-name()"/>
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
            <td class="data">
                <xsl:choose>
                    <xsl:when test="$dataClass='data_enum'">
                        <xsl:call-template name="printEnumData">
                            <xsl:with-param name="value" select="$data"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="{$dataClass}">
                            <xsl:value-of select="$data"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*[local-name()='permanentDataSetURI']">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <a href="{text()}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- date and time completed -->
    <xsl:template match="*[local-name()='timeStamp']">
        <xsl:variable name="date">
            <xsl:value-of select="substring-before(.,'T')"/>
        </xsl:variable>

        <xsl:variable name="timeAndZone">
            <xsl:value-of select="substring-after(.,'T')"/>
        </xsl:variable>

        <xsl:variable name="time">
            <xsl:choose>
                <xsl:when test="contains($timeAndZone, 'Z')">
                    <xsl:value-of select="substring-before($timeAndZone, 'Z')"/>
                </xsl:when>
                <xsl:when test="contains($timeAndZone, '+')">
                    <xsl:value-of select="substring-before($timeAndZone, '+')"/>
                </xsl:when>
                <xsl:when test="contains($timeAndZone, '-')">
                    <xsl:value-of select="substring-before($timeAndZone, '-')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after(., 'T')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="zone">
            <xsl:choose>
                <xsl:when test="contains($timeAndZone, '-')"> -<xsl:value-of select="substring-after($timeAndZone, '-')"/>
                </xsl:when>
                <xsl:when test="contains($timeAndZone, '+')"> +<xsl:value-of select="substring-after($timeAndZone, '+')"/>
                </xsl:when>
                <xsl:when test="contains($timeAndZone, 'Z')"> UTC </xsl:when>
                <xsl:otherwise>(no time zone specified)</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="data">
                <xsl:value-of select="$date"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$time"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$zone"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="*[local-name()='relativeStandardDeviation95In']">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="data">
                <xsl:value-of select="text()"/>
                <xsl:text> %</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[local-name()='copyright']">
        <xsl:call-template name="masterTemplate">
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

    <!-- images to be embedded if available -->
    <xsl:template
        match="*[local-name()='referenceToTechnologyPictogramme' or local-name()='referenceToTechnologyFlowDiagrammOrPicture' or local-name()='referenceToLCIAMethodFlowDiagrammOrPicture' or local-name()='referenceToMethodologyFlowChart' or local-name()='referenceToLogo']"
        priority="20">
        <xsl:variable name="sourceType">
            <xsl:call-template name="getSourceDatasetCategory">
                <xsl:with-param name="sourceDatasetURI" select="@uri"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="categoriesFile" select="/*/@categories"/>
        <xsl:variable name="validCategories" select="document($categoriesFile, /)/categories:ILCDCategories"/>

        <xsl:variable name="reqdSourceType">
            <xsl:value-of select="$validCategories/categories:sourceCategories/categories:category[@id=0]/@name"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$sourceType=$reqdSourceType">
                <!-- embed image tag in result document -->
                <xsl:variable name="uri">
                    <xsl:call-template name="getRefToDigitalFileURIFromSourceDataset">
                        <xsl:with-param name="sourceDatasetURI" select="@uri"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:call-template name="masterTemplate">
                    <xsl:with-param name="currentName" select="name()"/>
                    <xsl:with-param name="fieldDescSuffix"><xsl:text> (</xsl:text><xsl:value-of select="@type"/>)</xsl:with-param>
                    <xsl:with-param name="copy" select="true()"/>
                    <xsl:with-param name="data">
                        <a href="{@uri}" alt="{common:shortDescription/text()}">
                            <img src="{$uri}" alt="{@uri}" border="0"/>
                        </a>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- treat as regular reference -->
                <xsl:call-template name="masterTemplate">
                    <xsl:with-param name="currentName" select="name()"/>
                    <xsl:with-param name="fieldDescSuffix"><xsl:text> (</xsl:text><xsl:value-of select="@type"/>)</xsl:with-param>
                    <xsl:with-param name="copy" select="true()"/>
                    <xsl:with-param name="disableDescendantCount" select="true()"/>
                    <xsl:with-param name="data">
                        <xsl:call-template name="renderReference"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- compliance, dataqualityindicators -->
    <xsl:template match="*[local-name()='compliance']/*[local-name()!='referenceToComplianceSystem']">
        <td valign="bottom">
            <xsl:call-template name="rowMasterTemplate">
                <xsl:with-param name="omitIfEmpty" select="false()"/>
                <xsl:with-param name="data">
                    <xsl:value-of select="."/>
                </xsl:with-param>
            </xsl:call-template>
        </td>
    </xsl:template>

    <xsl:template match="*[local-name()='referenceToComplianceSystem']" priority="20">
        <td class="data" valign="bottom">
            <xsl:call-template name="rowMasterTemplate">
                <xsl:with-param name="fieldDescSuffix"><xsl:text> (</xsl:text><xsl:value-of select="@type"/>)</xsl:with-param>
                <xsl:with-param name="omitIfEmpty" select="false()"/>
                <xsl:with-param name="copy" select="true()"/>
                <xsl:with-param name="data">
                    <xsl:call-template name="renderReference"/>
                </xsl:with-param>
            </xsl:call-template>
        </td>
    </xsl:template>

    <xsl:template match="common:dataQualityIndicators">
        <xsl:apply-templates select="child::*"/>
    </xsl:template>

    <xsl:template match="common:dataQualityIndicator">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="paddingleft" select="40"/>
            <xsl:with-param name="copy" select="true()"/>
            <xsl:with-param name="data">
                <xsl:call-template name="printEnumData">
                    <xsl:with-param name="value" select="@name"/>
                </xsl:call-template>: <xsl:call-template name="printEnumData">
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- default template -->
    <xsl:template match="*">
        <xsl:call-template name="masterTemplate">
            <xsl:with-param name="applyTemplates" select="true()"/>
            <xsl:with-param name="omitIfEmpty" select="true()"/>
            <xsl:with-param name="data"/>
        </xsl:call-template>
    </xsl:template>


    <!-- default template, row display mode -->
    <xsl:template match="*" mode="rowDisplay">
        <xsl:call-template name="rowMasterTemplate">
            <xsl:with-param name="applyTemplates" select="true()"/>
            <xsl:with-param name="omitIfEmpty" select="false()"/>
            <xsl:with-param name="data"> </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- master template for left-to-right display of elements -->
    <xsl:template name="rowMasterTemplate">
        <xsl:param name="currentName" select="local-name()"/>
        <xsl:param name="fieldDescSuffix"/>
        <xsl:param name="displayFieldName" select="true()"/>
        <xsl:param name="translateFieldDescSearch"/>
        <xsl:param name="translateFieldDescReplace"/>
        <xsl:param name="data"/>
        <xsl:param name="applyTemplates" select="false()"/>
        <xsl:param name="copy" select="false()"/>
        <xsl:param name="omitIfEmpty" select="true()"/>
        <xsl:param name="disableDescendantCount" select="false()"/>
        <xsl:param name="disableSiblingCount" select="false()"/>

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

        <xsl:if test="$displayField='true'">

            <xsl:if test="(normalize-space(text())!='') or not($omitIfEmpty)">
                <xsl:variable name="fieldShortDesc">
                    <xsl:call-template name="getFieldShortDesc">
                        <xsl:with-param name="fieldName" select="$currentName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comment">
                    <xsl:call-template name="getComment">
                        <xsl:with-param name="fieldName" select="$currentName"/>
                    </xsl:call-template>
                </xsl:variable>

                <table class="data">
                    <xsl:if test="$displayFieldName='true'">
                        <tr>
                            <td class="fieldname">
                                <a class="info" href="javascript:void(0);">
                                    <xsl:choose>
                                        <xsl:when test="$translateFieldDescSearch!=''">
                                            <xsl:value-of select="translate($fieldShortDesc,$translateFieldDescSearch,$translateFieldDescReplace)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$fieldShortDesc"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:value-of select="$fieldDescSuffix"/>
                                    <span>
                                        <xsl:value-of select="$comment"/>
                                    </span>
                                </a>
                            </td>
                        </tr>
                    </xsl:if>

                    <xsl:variable name="dataClass">
                        <xsl:call-template name="decideDataClass">
                            <xsl:with-param name="fieldName" select="$currentName"/>
                        </xsl:call-template>
                    </xsl:variable>

                    <tr>
                        <td class="data">
                            <xsl:if test="@xml:lang and @xml:lang!=$defaultLanguage">
                                <span class="lang">
                                    <xsl:value-of select="@xml:lang"/>
                                    <xsl:text> </xsl:text>
                                </span>
                            </xsl:if>

                            <xsl:choose>
                                <xsl:when test="$dataClass='data_enum'">
                                    <xsl:variable name="value">
                                        <xsl:choose>
                                            <xsl:when test="$data=''">
                                                <xsl:value-of select="text()"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$data"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:call-template name="printEnumData">
                                        <xsl:with-param name="value" select="$value"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="{$dataClass}">
                                        <xsl:choose>
                                            <xsl:when test="$copy='true'">
                                                <xsl:copy-of select="$data"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$data"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="$applyTemplates=true()">
                                            <xsl:apply-templates/>
                                        </xsl:if>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </xsl:if>
        </xsl:if>
    </xsl:template>



    <!-- master template for top-to-bottom display of elements -->
    <xsl:template name="masterTemplate">
        <xsl:param name="currentName" select="local-name()"/>
        <xsl:param name="fieldDescSuffix"/>
        <xsl:param name="translateFieldDescSearch"/>
        <xsl:param name="translateFieldDescReplace"/>
        <xsl:param name="data"/>
        <xsl:param name="cssClass"/>
        <xsl:param name="applyTemplates" select="false()"/>
        <xsl:param name="copy" select="false()"/>
        <xsl:param name="omitIfEmpty" select="false()"/>
        <xsl:param name="disableDescendantCount" select="false()"/>
        <xsl:param name="disableSiblingCount" select="false()"/>
        <xsl:param name="paddingleft" select="number(count(ancestor::*)*10)"/>

        <xsl:variable name="fieldShortDesc">
            <xsl:call-template name="getFieldShortDesc">
                <xsl:with-param name="fieldName" select="$currentName"/>
            </xsl:call-template>
        </xsl:variable>
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
        <xsl:call-template name="log">
            <xsl:with-param name="message">
                <xsl:value-of select="$currentName"/> - <xsl:value-of select="$fieldRequirement"/> - <xsl:value-of select="$displayField"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="$displayField='true'">
            <xsl:variable name="comment">
                <xsl:call-template name="getComment">
                    <xsl:with-param name="fieldName" select="$currentName"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="defaultLanguageCondition">
                <xsl:call-template name="defaultLanguageCondition"/>
            </xsl:variable>
            <xsl:variable name="alternativeLanguageCondition">
                <xsl:call-template name="alternativeLanguageCondition"/>
            </xsl:variable>
            <xsl:if
                test="(not($omitIfEmpty) or not(count(descendant::*)=0 and normalize-space(text())='')) and (not(@xml:lang) or ($defaultLanguageCondition='true' or $alternativeLanguageCondition='true'))">
                <tr class="{$cssClass}">
                    <td class="fieldname" style="padding-left: {$paddingleft}px;">
                        <a class="info" href="javascript:void(0);">
                            <xsl:if
                                test="(count(preceding-sibling::*[local-name()=$currentName and not(@xml:lang)])=0 or $disableSiblingCount) or (count(descendant::*)!=0 and not($disableDescendantCount))">
                                <xsl:choose>
                                    <xsl:when test="$translateFieldDescSearch!=''">
                                        <xsl:value-of select="translate($fieldShortDesc,$translateFieldDescSearch,$translateFieldDescReplace)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$fieldShortDesc"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$fieldDescSuffix"/>
                            </xsl:if>
                            <span>
                                <xsl:value-of select="$comment"/>
                            </span>
                        </a>
                    </td>

                    <xsl:variable name="dataClass">
                        <xsl:call-template name="decideDataClass">
                            <xsl:with-param name="fieldName" select="$currentName"/>
                        </xsl:call-template>
                    </xsl:variable>

                    <td class="data">
                        <xsl:choose>
                            <xsl:when test="@xml:lang">
                                <span class="{$dataClass}">
                                    <xsl:call-template name="printMultiLangContent"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$dataClass='data_enum'">
                                        <xsl:call-template name="printEnumData">
                                            <xsl:with-param name="value" select="$data"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="{$dataClass}">
                                            <xsl:choose>
                                                <xsl:when test="$copy='true'">
                                                    <xsl:copy-of select="$data"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="printMultiLineContent">
                                                        <xsl:with-param name="string" select="$data"/>
                                                    </xsl:call-template>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:if test="$applyTemplates=true()">
                                                <xsl:apply-templates/>
                                            </xsl:if>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- extracts information regarding requirement of the given field from the XML Schema document -->
    <xsl:template name="getFieldRequirement">
        <xsl:param name="fieldName"/>
        <xsl:param name="byPassConditionalChecks" select="false()"/>

        <xsl:variable name="result">
            <xsl:call-template name="log">
                <xsl:with-param name="message"><xsl:value-of select="not($byPassConditionalChecks)"/>.<xsl:value-of select="count(ancestor::ilcd:review)"/></xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="not($byPassConditionalChecks) and ($fieldName='LCIMethodPrinciple')">
                    <xsl:variable name="condition">
                        <xsl:call-template name="principleCondition"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$condition='true'">m</xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="$fieldName"/>
                                <xsl:with-param name="byPassConditionalChecks" select="true()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not($byPassConditionalChecks) and ($fieldName='deviationsFromLCIMethodPrinciple')">
                    <xsl:variable name="condition">
                        <xsl:call-template name="principleCondition"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$condition='true'">r</xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="$fieldName"/>
                                <xsl:with-param name="byPassConditionalChecks" select="true()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not($byPassConditionalChecks) and count(ancestor-or-self::*[local-name()='review'])">
                    <xsl:variable name="condition">
                        <xsl:call-template name="reviewCondition"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$condition='true'">m <xsl:call-template name="log">
                                <xsl:with-param name="message">MANDATORY</xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="log">
                                <xsl:with-param name="message"> getting field requirement, bypassing cond checks: <xsl:call-template name="getFieldRequirement">
                                        <xsl:with-param name="fieldName" select="$fieldName"/>
                                        <xsl:with-param name="byPassConditionalChecks" select="true()"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="$fieldName"/>
                                <xsl:with-param name="byPassConditionalChecks" select="true()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not($byPassConditionalChecks) and ($fieldName='approvalOfOverallCompliance')">
                    <xsl:variable name="condition">
                        <xsl:call-template name="complianceCondition"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$condition='true'">m</xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getFieldRequirement">
                                <xsl:with-param name="fieldName" select="$fieldName"/>
                                <xsl:with-param name="byPassConditionalChecks" select="true()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$schemaDocument | $schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                        <xsl:value-of select="key('schemaDocumentKey',$fieldName)//ilcd:field-requirement/text()"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($result)"/>
    </xsl:template>

    <!-- extracts short description of the given field from the XML Schema document -->
    <xsl:template name="getFieldShortDesc">
        <xsl:param name="fieldName"/>
        <xsl:param name="parent" select="local-name(parent::*)"/>
        <xsl:variable name="result">
            <xsl:choose>
                <!-- resolve ambiguities -->
                <xsl:when
                    test="$fieldName='name' or $fieldName='common:name' or $fieldName='common:generalComment' or $fieldName='generalComment' or $fieldName='flowProperties' or $fieldName='referenceToDataSource'">
                    <xsl:variable name="parentType">
                        <xsl:call-template name="getElementType">
                            <xsl:with-param name="elementName" select="$parent"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="result1">
                        <xsl:for-each select="$schemaDocument">
                            <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)[ancestor::xs:complexType[@name=$parentType]]//ilcd:display-name/text()"/>
                            <xsl:value-of select="key('schemaDocumentElementKey',concat('common:',$fieldName))[ancestor::xs:complexType[@name=$parentType]]//ilcd:display-name/text()"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="normalize-space($result1)!=''">
                            <xsl:value-of select="$result1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                                <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)[ancestor::xs:complexType[@name=$parentType]]//ilcd:display-name/text()"/>
                                <xsl:value-of select="key('schemaDocumentElementKey',concat('common:',$fieldName))[ancestor::xs:complexType[@name=$parentType]]//ilcd:display-name/text()"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="($fieldName='location' or $fieldName='uncertaintyDistributionType') and local-name()='exchanges'">
                    <xsl:for-each select="$schemaDocument | $schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                        <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)//ilcd:display-name/text()"/>
                    </xsl:for-each>
                </xsl:when>
                <!-- default -->
                <xsl:otherwise>
                    <xsl:variable name="result1">
                        <xsl:for-each select="$schemaDocument">
                            <xsl:value-of select="key('schemaDocumentKey',$fieldName)//ilcd:display-name/text()"/>
                            <xsl:value-of select="key('schemaDocumentKey',concat('common:', $fieldName))//ilcd:display-name/text()"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="normalize-space($result1)!=''">
                            <xsl:value-of select="$result1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                                <xsl:value-of select="key('schemaDocumentKey',$fieldName)//ilcd:display-name/text()"/>
                                <xsl:value-of select="key('schemaDocumentKey',concat('common:', $fieldName))//ilcd:display-name/text()"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($result)"/>
    </xsl:template>

    <!-- determines whether a field is backed by an enumerated list - experimental -->
    <xsl:template name="isFromEnumList">
        <xsl:param name="fieldName"/>
        <xsl:variable name="type">
            <xsl:for-each select="$schemaDocument | $schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                <xsl:choose>
                    <xsl:when test="key('schemaDocumentKey',$fieldName)/@type">
                        <xsl:value-of select="key('schemaDocumentKey',$fieldName)/@type"/>
                        <xsl:text>%</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="type2">
            <xsl:value-of select="substring-before($type, '%')"/>
        </xsl:variable>
        <xsl:choose>
            <!-- some exceptions that can't be decided automatically -->
            <xsl:when test="$fieldName='name' and ancestor::*[local-name()='dataSetInformation']">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="(local-name()='scope' and local-name(parent::*)='review') or (local-name()='method' and local-name(parent::*)='scope')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="endsWith">
                    <xsl:with-param name="string1" select="$type2"/>
                    <xsl:with-param name="string2" select="'Values'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- determines whether a field is backed by an enumerated list - experimental -->
    <xsl:template name="isFromEnumList2">
        <xsl:param name="fieldName"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <!-- some exceptions that can't be decided automatically -->
            <xsl:when test="$fieldName='name' and ancestor::*[local-name()='dataSetInformation']">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="(local-name()='scope' and local-name(parent::*)='review') or (local-name()='method' and local-name(parent::*)='scope')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="endsWith">
                    <xsl:with-param name="string1" select="$type"/>
                    <xsl:with-param name="string2" select="'Values'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="getEnumComment">
        <xsl:param name="enumValue"/>

        <xsl:variable name="result">
            <xsl:for-each select="$schemaEnums | $schemaSecondary3">
                <xsl:value-of select="key('schemaDocumentEnumKey', $enumValue)/xs:annotation/xs:documentation/text()"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="$result"/>
    </xsl:template>


    <!-- returns the type of an XML Schema element -->
    <xsl:template name="getElementType">
        <xsl:param name="elementName"/>
        <xsl:choose>
            <!-- as those are rendered differently, they deserve special treatment -->
            <xsl:when test="$elementName='exchanges'">
                <xsl:value-of select="'ExchangeType'"/>
            </xsl:when>
            <xsl:when test="$elementName='flowProperties'">
                <xsl:value-of select="'FlowPropertyType'"/>
            </xsl:when>
            <xsl:when test="$elementName='flowsExchanges'">
                <xsl:value-of select="'FlowExchangeType'"/>
            </xsl:when>
            <xsl:when test="$elementName='LCIAResults'">
                <xsl:value-of select="'LCIAResultType'"/>
            </xsl:when>
            <xsl:when test="$elementName='dataSetInformation'">
                <xsl:value-of select="'DataSetInformationType'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$schemaDocument | $schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                    <xsl:value-of select="key('schemaDocumentElementKey', $elementName)/@type"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- extracts information regarding requirement of the given field from the XML Schema document -->
    <xsl:template name="getComment">
        <xsl:param name="fieldName"/>
        <xsl:param name="parent" select="local-name(parent::*)"/>

        <xsl:variable name="result">
            <xsl:choose>
                <!-- resolve ambiguities -->
                <xsl:when
                    test="$fieldName='name' or $fieldName='common:name' or $fieldName='common:generalComment' or $fieldName='generalComment' or $fieldName='flowProperties' or $fieldName='referenceToDataSource'">
                    <xsl:variable name="parentType">
                        <xsl:call-template name="getElementType">
                            <xsl:with-param name="elementName" select="$parent"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="result1">
                        <xsl:for-each select="$schemaDocument">
                            <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)[ancestor::xs:complexType[@name=$parentType]]//xs:documentation/text()"/>
                            <xsl:value-of select="key('schemaDocumentElementKey',concat('common:',$fieldName))[ancestor::xs:complexType[@name=$parentType]]//xs:documentation/text()"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="normalize-space($result1)!=''">
                            <xsl:value-of select="$result1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                                <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)[ancestor::xs:complexType[@name=$parentType]]//xs:documentation/text()"/>
                                <xsl:value-of select="key('schemaDocumentElementKey',concat('common:',$fieldName))[ancestor::xs:complexType[@name=$parentType]]//xs:documentation/text()"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="($fieldName='location' or $fieldName='uncertaintyDistributionType') and local-name()='exchanges'">
                    <xsl:for-each select="$schemaDocument | $schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                        <xsl:value-of select="key('schemaDocumentElementKey',$fieldName)//xs:documentation/text()"/>
                    </xsl:for-each>
                </xsl:when>
                <!-- default -->
                <xsl:otherwise>
                    <xsl:variable name="result1">
                        <xsl:for-each select="$schemaDocument">
                            <xsl:value-of select="key('schemaDocumentKey',$fieldName)//xs:documentation/text()"/>
                            <xsl:value-of select="key('schemaDocumentKey',concat('common:',$fieldName))//xs:documentation/text()"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="normalize-space($result1)!=''">
                            <xsl:value-of select="$result1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$schemaSecondary1 | $schemaSecondary2 | $schemaSecondary3">
                                <xsl:value-of select="key('schemaDocumentKey',$fieldName)//xs:documentation/text()"/>
                                <xsl:value-of select="key('schemaDocumentKey',concat('common:',$fieldName))//xs:documentation/text()"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($result)"/>
    </xsl:template>


    <!-- decides whether a field should be displayed or not. returns true or false depending on global showFieldsMode variable and given fieldsrequirement parameter -->
    <xsl:template name="decideFieldDisplay">
        <xsl:param name="fieldRequirement"/>
        <xsl:choose>
            <xsl:when test="$showFieldsMode='mandatory'">
                <xsl:choose>
                    <xsl:when test="/process:processDataSet and local-name()='geography'">
                        <xsl:value-of select="false()"/>
                    </xsl:when>
                    <xsl:when test="contains($fieldRequirement,'m')">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$showFieldsMode='recommended'">
                <xsl:choose>
                    <xsl:when test="contains($fieldRequirement,'m') or contains($fieldRequirement,'r')">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="decideDataClass">
        <xsl:param name="fieldName"/>
        <xsl:variable name="isFromEnum">
            <xsl:call-template name="isFromEnumList">
                <xsl:with-param name="fieldName" select="$fieldName"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isFromEnum='true'">
                <xsl:text>data_enum</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>data_neutral</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="decideDataClass2">
        <xsl:param name="fieldName"/>
        <xsl:param name="type"/>
        <xsl:variable name="isFromEnum">
            <xsl:call-template name="isFromEnumList2">
                <xsl:with-param name="fieldName" select="$fieldName"/>
                <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isFromEnum='true'">
                <xsl:text>data_enum</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>data_neutral</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- retrieve the URI to the actual file from a source dataset -->
    <xsl:template name="getRefToDigitalFileURIFromSourceDataset">
        <xsl:param name="sourceDatasetURI"/>
        <xsl:if test="$doNotLoadExternalResources!='true'">
            <xsl:value-of select="document($sourceDatasetURI, /)/source:sourceDataSet/source:sourceInformation/source:dataSetInformation/source:referenceToDigitalFile/@uri"/>
        </xsl:if>
    </xsl:template>

    <!-- retrieve the category of a source dataset -->
    <xsl:template name="getSourceDatasetCategory">
        <xsl:param name="sourceDatasetURI"/>
        <xsl:if test="$doNotLoadExternalResources!='true'">
            <xsl:value-of select="document($sourceDatasetURI, /)/source:sourceDataSet/source:sourceInformation/source:dataSetInformation/source:classificationInformation/common:class[@level='0']"/>
        </xsl:if>
    </xsl:template>


    <!-- extracts the name of a flow property from a given flow property dataset -->
    <xsl:template name="getFlowPropertyName">
        <xsl:param name="flowPropertyDataset"/>
        <xsl:choose>
            <xsl:when test="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:dataSetInformation/common:name[@xml:lang=$defaultLanguage]">
                <xsl:value-of
                    select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:dataSetInformation/common:name[@xml:lang=$defaultLanguage]/text()"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:dataSetInformation/flowproperty:name[@xml:lang=$alternativeLanguage]/text()"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- extracts the name of the reference unit for a given unit group dataset -->
    <xsl:template name="getUnitGroupReferenceUnitName">
        <xsl:param name="unitGroupDataset"/>
        <xsl:value-of
            select="$unitGroupDataset/unitgroup:unitGroupDataSet/unitgroup:units/unitgroup:unit[@dataSetInternalID=$unitGroupDataset/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:quantitativeReference/unitgroup:referenceToReferenceUnit]/unitgroup:name"
        />
    </xsl:template>

    <xsl:template name="getUnitGroupName">
        <xsl:param name="unitGroupDataset"/>
        <xsl:value-of select="$unitGroupDataset/unitgroup:unitGroupDataSet/unitgroup:unitGroupInformation/unitgroup:dataSetInformation/common:name"/>
    </xsl:template>

    <xsl:template name="getFlowPropertyAndUnitGroup">
        <xsl:param name="flowPropertyDatasetURI"/>

        <xsl:if test="$doNotLoadExternalResources!='true'">
            <xsl:choose>
                <xsl:when test="boolean(document($flowPropertyDatasetURI, /))">
                    <xsl:variable name="flowPropertyDataset" select="document($flowPropertyDatasetURI, /)"/>
                    <xsl:call-template name="getFlowPropertyName">
                        <xsl:with-param name="flowPropertyDataset" select="$flowPropertyDataset"/>
                    </xsl:call-template>
                    <xsl:variable name="unitGroupDatasetURI"
                        select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:quantitativeReference/flowproperty:referenceToReferenceUnitGroup/@uri"/>
                    <xsl:text> (</xsl:text>
                    <xsl:call-template name="getUnitGroupReferenceUnitName">
                        <xsl:with-param name="unitGroupDataset" select="document($unitGroupDatasetURI, /)"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template name="getUnitGroup">
        <xsl:param name="flowPropertyDatasetURI"/>

        <xsl:if test="$doNotLoadExternalResources!='true'">
            <xsl:choose>
                <xsl:when test="boolean(document($flowPropertyDatasetURI, /))">
                    <xsl:variable name="flowPropertyDataset" select="document($flowPropertyDatasetURI, /)"/>
                    <xsl:variable name="unitGroupDatasetURI"
                        select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:quantitativeReference/flowproperty:referenceToReferenceUnitGroup/@uri"/>
                    <xsl:call-template name="getUnitGroupReferenceUnitName">
                        <xsl:with-param name="unitGroupDataset" select="document($unitGroupDatasetURI, /)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template name="getUnitGroupAndFlowProperty">
        <xsl:param name="flowDatasetURI"/>

        <xsl:if test="$doNotLoadExternalResources!='true'">
            <xsl:choose>
                <xsl:when test="boolean(document($flowDatasetURI, /))">
                    <xsl:variable name="flowDataset" select="document($flowDatasetURI, /)"/>
                    <!-- retrieve reference flow dataset for flow -->
                    <xsl:variable name="flowPropertyDatasetURI"
                        select="$flowDataset/flow:flowDataSet/flow:flowProperties/flow:flowProperty[@dataSetInternalID=$flowDataset/flow:flowDataSet/flow:flowInformation/flow:quantitativeReference/flow:referenceToReferenceFlowProperty]/flow:referenceToFlowPropertyDataSet/@uri"/>
                    <xsl:variable name="flowPropertyDataset" select="document($flowPropertyDatasetURI, /)"/>
                    <!-- retrieve reference unit group dataset for flow property -->
                    <xsl:variable name="unitGroupDatasetURI"
                        select="$flowPropertyDataset/flowproperty:flowPropertyDataSet/flowproperty:flowPropertiesInformation/flowproperty:quantitativeReference/flowproperty:referenceToReferenceUnitGroup/@uri"/>
                    <xsl:variable name="unitGroupDataset" select="document($unitGroupDatasetURI, /)"/>
                    <xsl:call-template name="getUnitGroupReferenceUnitName">
                        <xsl:with-param name="unitGroupDataset" select="$unitGroupDataset"/>
                    </xsl:call-template>
                    <xsl:text> (</xsl:text>
                    <xsl:call-template name="getFlowPropertyName">
                        <xsl:with-param name="flowPropertyDataset" select="$flowPropertyDataset"/>
                    </xsl:call-template>
                    <xsl:text>)</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- tables: process the list of elements, invoking printTableHeader for each one -->
    <xsl:template name="processTableHeaders">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="substring-before($list,',')"/>
                </xsl:call-template>
                <xsl:call-template name="processTableHeaders">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printTableHeader">
                    <xsl:with-param name="elementName" select="$list"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- tables: render a single header including comment -->
    <xsl:template name="printTableHeader">
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


    <!-- tables: render a single data table cell in exchanges section (variant 1)-->
    <xsl:template name="printTableData">
        <xsl:param name="currentName" select="local-name()"/>
        <xsl:param name="isEnum" select="false()"/>
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
            <xsl:choose>
                <xsl:when test="$isEnum='true'">
                    <xsl:value-of select="'data_enum'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="decideDataClass">
                        <xsl:with-param name="fieldName" select="$currentName"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$displayField='true'">
            <td class="exchanges_data">
                <xsl:choose>
                    <xsl:when test="$dataClass='data_enum'">
                        <xsl:call-template name="printEnumData">
                            <xsl:with-param name="value" select="$data"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="{$dataClass}">
                            <xsl:copy-of select="$data"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:if>
    </xsl:template>


    <!-- tables: render the row where headers of the table are shown -->
    <xsl:template name="printTableHeaderRow">
        <xsl:param name="headerElements"/>
        <tr>
            <xsl:call-template name="processTableHeaders">
                <xsl:with-param name="list" select="$headerElements"/>
            </xsl:call-template>
        </tr>
    </xsl:template>


    <!-- this templates formats values from an enumeration with their suitable descriptions -->
    <xsl:template name="printEnumData">
        <xsl:param name="value"/>
        <span class="data_enum">
            <a class="info" href="javascript:void(0);">
                <xsl:choose>
                    <xsl:when test="$value=''">
                        <xsl:value-of select="text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
                <span>
                    <xsl:call-template name="getEnumComment">
                        <xsl:with-param name="enumValue" select="$value"/>
                    </xsl:call-template>
                </span>
            </a>
        </span>
    </xsl:template>

    <!-- this templates outputs the text node of a node depending on the global language settings -->
    <xsl:template name="printMultiLangContent">
        <xsl:variable name="defaultLanguageCondition">
            <xsl:call-template name="defaultLanguageCondition"/>
        </xsl:variable>
        <xsl:choose>
            <!-- check: if all languages are to be displayed, just go ahead and do it -->
            <xsl:when test="$showAllLanguages='true'">
                <span class="lang">
                    <xsl:value-of select="@xml:lang"/>
                    <xsl:text> </xsl:text>
                </span>
                <xsl:call-template name="printMultiLineContent">
                    <xsl:with-param name="string" select="text()"/>
                </xsl:call-template>
            </xsl:when>
            <!-- check: if I am the node with the matching default language, go ahead and print the text node -->
            <xsl:when test="$defaultLanguageCondition='true'">
                <xsl:call-template name="printMultiLineContent">
                    <xsl:with-param name="string" select="text()"/>
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise, if I am the node with the alternative language and there's no sibling (with the same nodename) for the default one, print the text node along with the alt lang code -->
            <xsl:otherwise>
                <xsl:variable name="nodeName" select="name()"/>
                <xsl:variable name="alternativeLanguageCondition">
                    <xsl:call-template name="alternativeLanguageCondition"/>
                </xsl:variable>
                <xsl:if test="$alternativeLanguageCondition='true'">
                    <span class="lang">
                        <xsl:value-of select="@xml:lang"/>
                        <xsl:text> </xsl:text>
                    </span>
                    <xsl:call-template name="printMultiLineContent">
                        <xsl:with-param name="string" select="text()"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- returns whether the current node is of the default language -->
    <xsl:template name="defaultLanguageCondition">
        <xsl:choose>
            <xsl:when test="$showAllLanguages='true'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="@xml:lang=$defaultLanguage or ($defaultLanguage='en' and not(@xml:lang))">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- returns whether the current node is to be rendered since it's of the alternative language -->
    <xsl:template name="alternativeLanguageCondition">
        <xsl:variable name="nodeName" select="name()"/>
        <xsl:choose>
            <xsl:when test="$showAllLanguages='true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when
                test="count(preceding-sibling::*[(@xml:lang=$defaultLanguage or not(@xml:lang)) and name()=$nodeName])+count(following-sibling::*[(@xml:lang=$defaultLanguage or not(@xml:lang)) and name()=$nodeName])=0 and @xml:lang=$alternativeLanguage">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- copy the text node only if @xml:lang matches the default or alternative language on a multi-lang element -->
    <xsl:template match="*" mode="multiLang">
        <xsl:param name="prefix"/>
        <xsl:param name="suffix"/>
        <xsl:param name="printLanguageCode" select="true()"/>

        <xsl:variable name="defaultLanguageCondition">
            <xsl:call-template name="defaultLanguageCondition"/>
        </xsl:variable>

        <xsl:variable name="alternativeLanguageCondition">
            <xsl:call-template name="alternativeLanguageCondition"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not(@xml:lang) and $defaultLanguage='en'">
                <xsl:copy-of select="$prefix"/>
                <xsl:apply-templates select="text()"/>
                <xsl:copy-of select="$suffix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$defaultLanguageCondition='true'">
                        <xsl:copy-of select="$prefix"/>
                        <xsl:apply-templates select="text()"/>
                        <xsl:copy-of select="$suffix"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$alternativeLanguageCondition='true'">
                            <xsl:if test="$printLanguageCode='true'">
                                <span class="lang">
                                    <xsl:value-of select="@xml:lang"/>
                                    <xsl:text> </xsl:text>
                                </span>
                            </xsl:if>
                            <xsl:copy-of select="$prefix"/>
                            <xsl:apply-templates select="text()"/>
                            <xsl:copy-of select="$suffix"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- render a reference -->
    <xsl:template name="renderReference">
        <xsl:param name="uri" select="@uri"/>
        <xsl:param name="type" select="@type"/>
        <xsl:param name="linkText"/>
        <xsl:param name="linkTextSuffix"/>

        <xsl:param name="stdLinkText">
            <xsl:choose>
                <xsl:when test="descendant::common:shortDescription[@xml:lang=$defaultLanguage]">
                    <xsl:value-of select="descendant::common:shortDescription[@xml:lang=$defaultLanguage]/text()"/>
                </xsl:when>
                <xsl:when test="descendant::common:shortDescription[not(@xml:lang)] and $defaultLanguage='en'">
                    <xsl:value-of select="descendant::common:shortDescription[not(@xml:lang)]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="descendant::common:shortDescription[@xml:lang=$alternativeLanguage]">
                            <xsl:value-of select="descendant::common:shortDescription[@xml:lang=$alternativeLanguage]/text()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>no description available</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <xsl:variable name="outLinkText">
            <xsl:choose>
                <xsl:when test="$linkText!=''">
                    <xsl:value-of select="$linkText"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$stdLinkText"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$linkTextSuffix"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$uri!=''">
                <!-- check if resource is available -->
                <xsl:variable name="resourceExists">
                    <xsl:choose>
                        <xsl:when test="$checkResourceAvailablity='true'">
                            <xsl:call-template name="checkFileExistence">
                                <xsl:with-param name="uri" select="@uri"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="true()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="linkCSSClass">
                    <xsl:choose>
                        <xsl:when test="$resourceExists='true'">
                            <xsl:value-of select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'warning'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$uri"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="$type"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="$linkCSSClass"/>
                    </xsl:attribute>

                    <xsl:call-template name="printMultiLineContent">
                        <xsl:with-param name="string" select="$outLinkText"/>
                    </xsl:call-template>

                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="printMultiLineContent">
                    <xsl:with-param name="string" select="$outLinkText"/>
                </xsl:call-template>
                <xsl:text> (No URI available)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="descendant::common:subReference">
            <xsl:apply-templates select="descendant::common:subReference"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="common:subReference">
        <xsl:if test="position()=1">
            <xsl:text> (</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="printMultiLineContent">
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="contains($string,$break)">
                <xsl:value-of select="substring-before($string,$break)"/>
                <br/>
                <xsl:call-template name="printMultiLineContent">
                    <xsl:with-param name="string" select="substring-after($string,$break)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="printResourceNotFoundMessage">
        <div class="{$resourceNotFoundCSSClass}">
            <xsl:value-of select="$resourceNotFoundMessage"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
