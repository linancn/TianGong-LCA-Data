<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ilcd="http://lca.jrc.it/ILCD" xmlns:process="http://lca.jrc.it/ILCD/Process"
    xmlns:common="http://lca.jrc.it/ILCD/Common" xmlns:categories="http://lca.jrc.it/ILCD/Categories" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!-- switch debug messages on or off by setting to true() or false() -->
    <xsl:variable name="debug" select="false()"/>

    <xsl:variable name="fancyMessages" select="false()"/>

    <xsl:variable name="PROCESS" select="'processDataSet'"/>
    <xsl:variable name="FLOW" select="'flowDataSet'"/>
    <xsl:variable name="FLOWPROPERTY" select="'flowPropertyDataSet'"/>
    <xsl:variable name="UNITGROUP" select="'unitGroupDataSet'"/>
    <xsl:variable name="SOURCE" select="'sourceDataSet'"/>
    <xsl:variable name="CONTACT" select="'contactDataSet'"/>
    <xsl:variable name="LCIAMETHOD" select="'LCIAMethodDataSet'"/>
    <xsl:variable name="WRAPPER" select="'ILCD'"/>


    <xsl:variable name="defaultLocationsFile" select="'ILCDLocations.xml'"/>
    <xsl:variable name="referenceLocationsFile" select="'ILCDLocations_Reference.xml'"/>

    <xsl:variable name="defaultCategoriesFile" select="'ILCDClassification.xml'"/>
    <xsl:variable name="referenceCategoriesFile" select="'ILCDClassification_Reference.xml'"/>

    <xsl:variable name="defaultFlowCategoriesFile" select="'ILCDFlowCategorization.xml'"/>
    <xsl:variable name="referenceFlowCategoriesFile" select="'ILCDFlowCategorization_Reference.xml'"/>

    <xsl:variable name="defaultLCIAMethodologiesFile" select="'ILCDLCIAMethodologies.xml'"/>
    <xsl:variable name="referenceLCIAMethodologiesFile" select="'ILCDLCIAMethodologies_Reference.xml'"/>


    <!-- Checks if an element matching the expression in $dependsOn is present, and outputs an appropriate message otherwise.  -->
    <xsl:template name="checkDependency">
        <xsl:param name="elementDesc"/>
        <xsl:param name="dependsOn"/>
        <xsl:param name="dependsOnDesc" select="local-name($dependsOn)"/>
        <xsl:param name="messagePrefix"/>
        <xsl:if test="count($dependsOn)=0">
            <xsl:call-template name="complianceEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message"><xsl:if test="$messagePrefix">
                        <xsl:value-of select="$messagePrefix"/>
                        <xsl:text>: </xsl:text>
                    </xsl:if>If <xsl:value-of select="$elementDesc"/> is present, <xsl:value-of select="$dependsOnDesc"/> must be specified.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template name="checkPresence">
        <xsl:param name="element"/>
        <xsl:param name="elementDesc" select="local-name($element)"/>
        <xsl:param name="lBound"/>
        <xsl:param name="uBound"/>
        <xsl:param name="noText" select="false()"/>
        <xsl:param name="messagePrefix"/>
        <xsl:choose>
            <xsl:when test="count($element)=0 or ($noText=false() and string-length($element)=0)">
                <xsl:call-template name="complianceEvent">
                    <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                    <xsl:with-param name="message">
                        <xsl:if test="$messagePrefix">
                            <xsl:value-of select="$messagePrefix"/>
                            <xsl:text>: </xsl:text>
                        </xsl:if>Element <xsl:value-of select="$elementDesc"/> must be present<xsl:if test="$noText!=true()"> and non-empty</xsl:if>.</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$lBound!='' or $uBound!=''">
                    <xsl:variable name="charCount" select="string-length($element)"/>
                    <xsl:if test="$lBound!='' and $charCount&lt;$lBound">
                        <xsl:element name="warning">
                            <xsl:attribute name="message">
                                <xsl:text>Compliance warning: </xsl:text>
                                <xsl:if test="$messagePrefix">
                                    <xsl:value-of select="$messagePrefix"/>
                                    <xsl:text>: </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="$elementDesc"/>
                                <xsl:text> is shorter (</xsl:text>
                                <xsl:value-of select="$charCount"/>
                                <xsl:text> characters) than minimum recommended length of </xsl:text>
                                <xsl:value-of select="$lBound"/>
                                <xsl:text> characters.</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="deviation">
                                <xsl:value-of select="-1 * (1 - (number($charCount) div number($lBound)))"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$uBound!='' and $charCount&gt;$uBound">
                        <xsl:element name="warning">
                            <xsl:attribute name="message">
                                <xsl:text>Compliance warning: </xsl:text>
                                <xsl:if test="$messagePrefix">
                                    <xsl:value-of select="$messagePrefix"/>
                                    <xsl:text>: </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="$elementDesc"/>
                                <xsl:text> is longer (</xsl:text>
                                <xsl:value-of select="$charCount"/>
                                <xsl:text> characters), than maximum recommended length of </xsl:text>
                                <xsl:value-of select="$uBound"/>
                                <xsl:text> characters.</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="deviation">
                                <xsl:value-of select="-1 * (1 - (number($charCount) div number($uBound)))"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="checkFileExistence">
        <xsl:param name="uri"/>
        <xsl:param name="quiet" select="false()"/>
        <xsl:param name="relativeToStylesheet" select="false()"/>
        <xsl:choose>
            <xsl:when test="relativeToStylesheet='true'">
                <xsl:value-of select="boolean(document($uri))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="boolean(document($uri, /))"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$quiet!='true'">
            <xsl:message>checking existence of <xsl:value-of select="$uri"/></xsl:message>
        </xsl:if>
    </xsl:template>


    <xsl:template name="checkValue">
        <xsl:param name="element"/>
        <xsl:param name="value1"/>
        <xsl:param name="value2"/>
        <xsl:param name="elementDesc" select="local-name($element)"/>
        <xsl:param name="messagePrefix"/>
        <xsl:if test="not($element=$value1) and not($element=$value2)">
            <xsl:call-template name="complianceEvent">
                <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
                <xsl:with-param name="message"><xsl:if test="$messagePrefix">
                        <xsl:value-of select="$messagePrefix"/>
                        <xsl:text>: </xsl:text>
                    </xsl:if>Value of <xsl:value-of select="$elementDesc"/> must be "<xsl:value-of select="$value1"/>"<xsl:if test="not($value2='')"> or "<xsl:value-of
                            select="$value2"/>"</xsl:if>.</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- the following templates evaluate to true if conditionally mandatory condition for the particular fields is met -->
    <xsl:template name="principleCondition">
        <xsl:choose>
            <xsl:when test="/process:processDataSet/process:modellingAndValidation/process:LCIMethodAndAllocation/process:typeOfDataSet/text()!='Unit process, not pre-allocated'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="reviewCondition">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::*[local-name()='review']/@type!='Internal review' and ancestor-or-self::*[local-name()='review']/@type!='Not reviewed'">
                <xsl:value-of select="true()"/>
                <xsl:call-template name="log">
                    <xsl:with-param name="message">reviewCondition is true</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
                <xsl:call-template name="log">
                    <xsl:with-param name="message">reviewCondition is false</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="complianceCondition">
        <xsl:choose>
            <xsl:when test="count(preceding::*[local-name()='referenceToComplianceSystem'])>0">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template that does the real job checking the categories-->
    <!-- andreas schmidt, 28.12.2005)  -->
    <xsl:template name="check_hierarchy">
        <xsl:param name="category_list" select="common:class|common:category"/>
        <xsl:param name="tree"/>
        <xsl:param name="level" select="0"/>
        <xsl:param name="already_parsed" select="''"/>
        <xsl:param name="messagePrefix"/>

        <xsl:variable name="first" select="$category_list[@level=$level]"/>

        <xsl:variable name="tree_node" select="$tree/categories:category[@name=$first]"/>

        <!--    <xsl:message>level: <xsl:value-of select="$level"/>, already_parsed: <xsl:value-of select="$already_parsed"/></xsl:message>-->

        <xsl:choose>
            <xsl:when test="count($category_list) &gt; 0">
                <xsl:choose>
                    <xsl:when test="count($first)=0">
                        <xsl:message terminate="no"><xsl:if test="$messagePrefix">
                                <xsl:value-of select="$messagePrefix"/>
                                <xsl:text>: </xsl:text>
                            </xsl:if>Attribute 'level' has wrong value (expected: level=<xsl:value-of select="$level"/>, found level=<xsl:value-of select="$category_list[1]/@level"
                            />) </xsl:message>
                    </xsl:when>

                    <xsl:when test="count($tree_node)=0">
                        <xsl:message terminate="no">
                            <xsl:if test="$messagePrefix">
                                <xsl:value-of select="$messagePrefix"/>
                                <xsl:text>: </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$already_parsed=''">top-category "<xsl:value-of select="$first"/>" unknown</xsl:when>
                                <xsl:otherwise>category "<xsl:value-of select="$first"/>" under path "<xsl:value-of select="$already_parsed"/>" unknown</xsl:otherwise>
                            </xsl:choose>
                        </xsl:message>
                    </xsl:when>
                </xsl:choose>

                <xsl:call-template name="check_hierarchy">
                    <xsl:with-param name="category_list" select="$category_list[position() &gt; 1]"/>
                    <xsl:with-param name="tree" select="$tree_node[@name=$first]"/>
                    <xsl:with-param name="level" select="$level+1"/>
                    <xsl:with-param name="already_parsed" select="concat($already_parsed , '/',$first)"/>
                    <xsl:with-param name="messagePrefix" select="$messagePrefix"/>
                </xsl:call-template>
            </xsl:when>

            <!--        <xsl:otherwise>
        <xsl:message  terminate="no">category path "<xsl:value-of select="$already_parsed"/>" OK
        </xsl:message>
        </xsl:otherwise>
-->
        </xsl:choose>
    </xsl:template>


    <xsl:template name="getSchemaName">
        <xsl:param name="rootElement"/>
        <xsl:choose>
            <xsl:when test="$rootElement='ILCDCategories'">
                <xsl:text>ILCD_Categories.xsd</xsl:text>
            </xsl:when>
            <xsl:when test="$rootElement='ILCDLocations'">
                <xsl:text>ILCD_Locations.xsd</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>ILCD_</xsl:text>
                <xsl:value-of select="concat(translate(substring($rootElement,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($rootElement,2))"/>
                <xsl:text>.xsd</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="getSchemaPath">
        <xsl:param name="rootElement"/>
        <xsl:if test="$rootElement!='ILCDCategories' and $rootElement!='ILCDLocations'">
            <xsl:text>../</xsl:text>
        </xsl:if>
        <xsl:text>../schemas/</xsl:text>
    </xsl:template>


    <xsl:template name="determineReferenceType">
        <xsl:param name="for"/>
        <xsl:param name="referenceTypes"/>
        <xsl:param name="rootElement" select="local-name(/*)"/>
        <xsl:choose>
            <xsl:when test="$referenceTypes/reference[@name=$for]/dataset/@type!='SELF'">
                <xsl:value-of select="$referenceTypes/reference[@name=$for]/dataset/@type"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$rootElement=$PROCESS">
                        <xsl:value-of select="'process data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$LCIAMETHOD">
                        <xsl:value-of select="'LCIA method data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$FLOW">
                        <xsl:value-of select="'flow data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$FLOWPROPERTY">
                        <xsl:value-of select="'flow property data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$UNITGROUP">
                        <xsl:value-of select="'unit group data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$CONTACT">
                        <xsl:value-of select="'contact data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$SOURCE">
                        <xsl:value-of select="'source data set'"/>
                    </xsl:when>
                    <xsl:when test="$rootElement=$WRAPPER">
                        <xsl:call-template name="determineReferenceType">
                            <xsl:with-param name="for" select="$for"/>
                            <xsl:with-param name="referenceTypes" select="$referenceTypes"/>
                            <xsl:with-param name="rootElement" select="local-name(ancestor::*[contains(local-name(),'DataSet')])"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">ERROR: Could not determine dataset type for document with root element <xsl:value-of select="local-name(/*)"/></xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="isSubReferenceAllowed">
        <xsl:param name="on"/>
        <xsl:param name="referenceTypes"/>
        <xsl:value-of select="$referenceTypes/reference[@name=$on]/dataset/@type='source data set' and $referenceTypes/reference[@name=$on]/dataset/@subReference='yes'"/>
    </xsl:template>


    <!-- determines the short name of a dataset -->
    <xsl:template name="determineDataSetShortName">
        <xsl:param name="rootElement" select="local-name(/*)"/>
        <xsl:choose>
            <xsl:when test="(/*/@version='1.0' or /*/@version='1.0.1') and $rootElement='processOrLCIResultDataSet'">
                <xsl:value-of select="'Process'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($PROCESS)">
                <xsl:value-of select="'Process'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($LCIAMETHOD)">
                <xsl:value-of select="'LCIAMethod'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($FLOW)">
                <xsl:value-of select="'Flow'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($FLOWPROPERTY)">
                <xsl:value-of select="'FlowProperty'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($UNITGROUP)">
                <xsl:value-of select="'UnitGroup'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($CONTACT)">
                <xsl:value-of select="'Contact'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($SOURCE)">
                <xsl:value-of select="'Source'"/>
            </xsl:when>
            <xsl:when test="string($rootElement)=string($WRAPPER)">
                <xsl:call-template name="determineDataSetShortName">
                    <xsl:with-param name="rootElement" select="local-name(ancestor::*[contains(local-name(),'DataSet')])"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--        <xsl:message terminate="no">ERROR: Could not determine dataset short name for document with root element <xsl:value-of select="local-name(/*)"/></xsl:message>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="isElementaryFlow">
        <xsl:param name="datasetShortName">
            <xsl:call-template name="determineDataSetShortName"/>
        </xsl:param>
        <xsl:choose>
            <xsl:when
                test="$datasetShortName='Flow' and /*[local-name()='flowDataSet']/*[local-name()='modellingAndValidation']/*[local-name()='LCIMethod']/*[local-name()='typeOfDataSet']/text()='Elementary flow'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- returns true if string1 ends with the characters in string2 -->
    <xsl:template name="endsWith">
        <xsl:param name="string1"/>
        <xsl:param name="string2"/>

        <xsl:choose>
            <xsl:when test="contains($string1, $string2) and substring-after($string1, $string2) = ''">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- returns the last part of string1 that is separated by string2 -->
    <xsl:template name="substringAfterLast">
        <xsl:param name="string1"/>
        <xsl:param name="string2"/>
        <xsl:choose>
            <xsl:when test="contains($string1, $string2)">
                <xsl:call-template name="substringAfterLast">
                    <xsl:with-param name="string1" select="substring-after($string1, $string2)"/>
                    <xsl:with-param name="string2" select="$string2"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- reverses a string -->
    <xsl:template name="reverse">
        <xsl:param name="string"/>

        <xsl:variable name="thisLength" select="string-length($string)"/>
        <xsl:choose>
            <xsl:when test="$thisLength = 0">
                <xsl:value-of select="$string"/>
            </xsl:when>
            <xsl:when test="$thisLength = 1">
                <xsl:value-of select="$string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="restReverse">
                    <xsl:call-template name="reverse">
                        <xsl:with-param name="string" select="substring($string, 1, $thisLength -1)"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat(substring($string, $thisLength, 1),$restReverse)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- replaces a string inside a string -->
    <xsl:template name="replaceString">
        <xsl:param name="string"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($string,$replace)">
                <xsl:value-of select="concat(substring-before($string,$replace),$with)"/>
                <xsl:call-template name="replaceString">
                    <xsl:with-param name="string" select="substring-after($string,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="equalsUUID">
        <xsl:param name="uuid1"/>
        <xsl:param name="uuid2"/>
        <xsl:value-of select="translate($uuid1, 'abcdef', 'ABCDEF') = translate($uuid2, 'abcdef', 'ABCDEF')"/>
    </xsl:template>
    
    <xsl:template name="containsUUID">
        <xsl:param name="uuidList"/>
        <xsl:param name="uuid"/>
        <xsl:variable name="uuidListLC" select="translate($uuidList, 'abcdef', 'ABCDEF')"/>
        <xsl:variable name="uuidLC" select="translate($uuid, 'abcdef', 'ABCDEF')"/>
        <xsl:value-of select="contains($uuidListLC, $uuidLC)"/>
    </xsl:template>
    
    
    <xsl:template name="line">
        <xsl:message>-----------------------------------------------------------------------------------------------------------------------------------------</xsl:message>
    </xsl:template>


    <xsl:template name="warn">
        <xsl:param name="message"/>
        <xsl:if test="$fancyMessages='true'">
            <xsl:call-template name="line"/>
        </xsl:if>
        <xsl:message>WARNING: <xsl:value-of select="$message"/></xsl:message>
        <xsl:if test="$fancyMessages='true'">
            <xsl:call-template name="line"/>
        </xsl:if>
    </xsl:template>


    <xsl:template name="warn_removal">
        <xsl:call-template name="warn">
            <xsl:with-param name="message">
                <xsl:text>removing element </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> with content </xsl:text>
                <xsl:value-of select="text()"/>
                <xsl:if test="text()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:for-each select="@*">
                    <xsl:text>@</xsl:text>
                    <xsl:value-of select="name()"/>
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="event">
        <xsl:param name="type"/>
        <xsl:param name="message"/>
        <xsl:param name="fancyMessages" select="false()"/>
        <xsl:if test="$fancyMessages='true'">
            <xsl:call-template name="line"/>
        </xsl:if>
        <xsl:message><xsl:value-of select="$type"/> error: <xsl:value-of select="$message"/></xsl:message>
        <xsl:if test="$fancyMessages='true'">
            <xsl:call-template name="line"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="validationEvent">
        <xsl:param name="message"/>
        <xsl:param name="fancyMessages" select="false()"/>
        <xsl:call-template name="event">
            <xsl:with-param name="type" select="'Validation'"/>
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="complianceEvent">
        <xsl:param name="message"/>
        <xsl:param name="fancyMessages" select="false()"/>
        <xsl:call-template name="event">
            <xsl:with-param name="type" select="'Compliance'"/>
            <xsl:with-param name="message" select="$message"/>
            <xsl:with-param name="fancyMessages" select="$fancyMessages"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="stripPrefix">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name,':')">
                <xsl:value-of select="substring-after($name,':')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- log debug messages -->
    <xsl:template name="log">
        <xsl:param name="message"/>
        <xsl:if test="$debug=true()">
            <xsl:message>
                <xsl:value-of select="$message"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
