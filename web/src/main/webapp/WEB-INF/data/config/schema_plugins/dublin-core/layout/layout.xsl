<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-dublin-core="http://geonetwork-opensource.org/xsl/functions/profiles/dublin-core"
  exclude-result-prefixes="#all">

  <xsl:include href="utility-fn.xsl"/>


  <!-- Visit all tree -->
  <xsl:template mode="mode-dublin-core" match="dc:*|dct:*">
    <xsl:apply-templates mode="mode-dublin-core" select="*|@*"/>
  </xsl:template>


  <!-- Forget those DC elements -->
  <xsl:template mode="mode-dublin-core"
    match="dc:*[
    starts-with(name(), 'dc:elementContainer') or
    starts-with(name(), 'dc:any')
    ]"
    priority="300">
    <xsl:apply-templates mode="mode-dublin-core" select="*|@*"/>
  </xsl:template>


  <!-- Boxed the root element -->
  <xsl:template mode="mode-dublin-core" priority="200" match="simpledc">
    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label" select="gn-fn-metadata:getLabel($schema, name(.), $labels)/label"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <xsl:with-param name="subTreeSnippet">
        <xsl:apply-templates mode="mode-dublin-core" select="*"/>
      </xsl:with-param>
      <xsl:with-param name="editInfo" select="gn:element"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Forget all elements ... -->
  <xsl:template mode="mode-dublin-core" match="gn:*|@*"/>

  <!-- 
    ... but not the one proposing the list of elements to add in DC schema
    
    Template to display non existing element ie. geonet:child element
    of the metadocument. Display in editing mode only and if 
  the editor mode is not flat mode. -->
  <xsl:template mode="mode-dublin-core" match="gn:child[contains(@name, 'CHOICE_ELEMENT')]"
    priority="2000">
    <xsl:if test="$isEditing and 
      not($isFlatMode)">

      <!-- Create a new configuration to only create
            a add action for non existing node. The add action for 
            the existing one is below the last element. -->
      <xsl:variable name="newElementConfig">
        <xsl:variable name="dcConfig"
          select="ancestor::node()/gn:child[contains(@name, 'CHOICE_ELEMENT')]"/>
        <xsl:variable name="existingElementNames" select="string-join(../descendant::*/name(), ',')"/>

        <gn:child>
          <xsl:copy-of select="$dcConfig/@*"/>
          <xsl:copy-of select="$dcConfig/gn:choose[not(contains($existingElementNames, @name))]"/>
        </gn:child>
      </xsl:variable>

      <xsl:call-template name="render-element-to-add">
        <xsl:with-param name="childEditInfo" select="$newElementConfig/gn:child"/>
        <xsl:with-param name="parentEditInfo" select="../gn:element"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>




  <!-- the other elements in DC. -->
  <xsl:template mode="mode-dublin-core" priority="100" match="dc:*|dct:*">
    <xsl:variable name="name" select="name(.)"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, $name, $labels)"/>
    <xsl:variable name="helper" select="gn-fn-metadata:getHelper($labelConfig/helper, .)"/>


    <!-- Add view and edit template-->
    <xsl:call-template name="render-element">
      <xsl:with-param name="label" select="$labelConfig/label"/>
      <xsl:with-param name="value" select="."/>
      <xsl:with-param name="cls" select="local-name()"/>
      <!--<xsl:with-param name="widget"/>
            <xsl:with-param name="widgetParams"/>-->
      <xsl:with-param name="xpath" select="gn-fn-metadata:getXPath(.)"/>
      <!--<xsl:with-param name="attributesSnippet" as="node()"/>-->
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      <xsl:with-param name="name" select="if ($isEditing) then gn:element/@ref else ''"/>
      <xsl:with-param name="editInfo" select="gn:element"/>
      <xsl:with-param name="widget" select="gn-fn-dublin-core:getFieldWidget(name())"/>
      <xsl:with-param name="listOfValues" select="$helper"/>
    </xsl:call-template>

    <!-- Add a control to add this type of element
      if this element is the last element of its kind.
    -->
    <xsl:if
      test="$isEditing and 
      not($isFlatMode) and 
      count(following-sibling::node()[name() = $name]) = 0">

      <!-- Create configuration to add action button for this element. -->
      <xsl:variable name="dcConfig"
        select="ancestor::node()/gn:child[contains(@name, 'CHOICE_ELEMENT')]"/>
      <xsl:variable name="newElementConfig">
        <gn:child>
          <xsl:copy-of select="$dcConfig/@*"/>
          <xsl:copy-of select="$dcConfig/gn:choose[@name = $name]"/>
        </gn:child>
      </xsl:variable>
      <xsl:call-template name="render-element-to-add">
        <xsl:with-param name="childEditInfo" select="$newElementConfig/gn:child"/>
        <xsl:with-param name="parentEditInfo" select="$dcConfig/parent::node()/gn:element"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>