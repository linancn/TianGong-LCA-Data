<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:import href="compliance_1.1.xsl"/>
    <xsl:import href="common.xsl"/>

    <xsl:output indent="no" method="text"/>



    <xsl:template match="/">

        <xsl:call-template name="assertEquals">
            <xsl:with-param name="param1" select="true()"/>
            <xsl:with-param name="param2" select="true()"/>
        </xsl:call-template>

        <xsl:call-template name="assertTrue">
            <xsl:with-param name="param1" select="true()"/>
        </xsl:call-template>

        <!-- test equalsUUID -->
        <xsl:call-template name="assertTrue">
            <xsl:with-param name="param1">
                <xsl:call-template name="equalsUUID">
                    <xsl:with-param name="uuid1" select="'aaaaaaaa-bbbb-cccc-1111-FfFfFfFfFfFf'"/>
                    <xsl:with-param name="uuid2" select="'aaAAAaaa-bBBb-cccc-1111-ffffffffffff'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>


        <xsl:call-template name="assertTrue">
            <xsl:with-param name="param1">
                <xsl:call-template name="checkReferenceToComplianceDocument">
                    <xsl:with-param name="uri" select="'foo'"/>
                    <xsl:with-param name="uuid" select="'bar'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:variable name="foo">
            <xsl:call-template name="checkReferenceToComplianceDocument">
                <xsl:with-param name="uri" select="'foo'"/>
                <xsl:with-param name="uuid" select="'85c70ebb-6909-462a-9efa-8d97cee275ee'"/>
            </xsl:call-template>
        </xsl:variable>

    </xsl:template>


    <xsl:template name="assertEquals">
        <xsl:param name="param1"/>
        <xsl:param name="param2"/>
        <xsl:if test="not(boolean($param1=$param2))">
            <xsl:message>
                <xsl:text>FAILURE: expression </xsl:text>
                <xsl:value-of select="$param1"/>
                <xsl:text> is not equal to </xsl:text>
                <xsl:value-of select="$param2"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>


    <xsl:template name="assertTrue">
        <xsl:param name="param1"/>
        <xsl:if test="not(boolean($param1)='true')">
            <xsl:message>
                <xsl:text>FAILURE: expression </xsl:text>
                <xsl:value-of select="$param1"/>
                <xsl:text> is not true.</xsl:text>
            </xsl:message>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
