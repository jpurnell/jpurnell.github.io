<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/opml">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	  <head>
		<title>
		  <xsl:value-of select="head/title"/>
		</title>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>
		<style>		  
			html { 
				max-width: 800px; 
			    font-family: "Helvetica", system-ui, "Arial", "Sans-Serif";
				font-size: 0.85em;
				  margin: 60px auto;
				  width: 90%; 
			    line-height: 1.2; 
			    font-size: 1.15em; 
			} 
			body { 
				font-family: "Helvetica", system-ui, "Arial", "Sans-Serif";
				  font-size: 0.85em;
				  margin: 60px auto;
				  width: 90%;
			}
			  </style>
	  </head>
	  <body>
		<p>
		  This is a list of blogs and news sources I follow. The page
		  is itself an <a href="http://opml.org/">OPML</a> file, which
		  means you can copy the link into your RSS reader to
		  subscribe to all the feeds listed below.
		</p>
		<ul>
		  <xsl:apply-templates select="body/outline/outline"/>
		</ul>
	  </body>
	</html>
  </xsl:template>
  <xsl:template match="outline" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:choose>
	  <xsl:when test="@type">
		<xsl:choose>
		  <xsl:when test="@xmlUrl">
			<li>
			  <strong>
				<a href="{@htmlUrl}"><xsl:value-of select="@text"/></a>
				(<a class="feed" href="{@xmlUrl}">feed</a>)
			  </strong>
			  <xsl:choose>
				<xsl:when test="@description != ''">
				  <br/><xsl:value-of select="@description"/>
				</xsl:when>
			  </xsl:choose>
			</li>
		  </xsl:when>
		</xsl:choose>
	  </xsl:when>
	</xsl:choose>
  </xsl:template>
</xsl:stylesheet>