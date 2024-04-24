<?xml version="1.0" encoding="UTF-8"?>
<!-- ILCD Format Version 1.1 Tools Build 1020 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

	<xsl:variable name="schemaPath" select="'../../schemas/'"/>

	<xsl:variable name="schema">
		<xsl:call-template name="getSchemaName">
			<xsl:with-param name="rootElement" select="local-name(/*)"/>
		</xsl:call-template>
	</xsl:variable>
	
</xsl:stylesheet>
