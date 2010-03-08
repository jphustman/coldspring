<DOCFLEX_TEMPLATE VER='1.13'>
CREATED='2009-05-05 04:55:37'
LAST_UPDATE='2009-10-30 06:36:29'
DESIGNER_TOOL='DocFlex SDK 1.x'
DESIGNER_LICENSE_TYPE='Filigris Works Team'
TEMPLATE_TYPE='DocumentTemplate'
DSM_TYPE_ID='xsddoc'
ROOT_ETS={'xs:%element';'xs:complexType';'xs:group'}
<TEMPLATE_PARAMS>
	PARAM={
		param.name='doc.comp.diagram.links';
		param.title='Hyperlinks';
		param.grouping='true';
	}
	PARAM={
		param.name='doc.comp.diagram.links.attribute.global';
		param.title='Global Attributes';
		param.type='enum';
		param.enum.values='global;local';
	}
	PARAM={
		param.name='doc.comp.diagram.links.element.local';
		param.title='Local Elements';
		param.type='enum';
		param.enum.values='global;local';
	}
</TEMPLATE_PARAMS>
FMT={
	doc.lengthUnits='pt';
	doc.hlink.style.link='cs2';
}
<STYLES>
	CHAR_STYLE={
		style.name='Default Paragraph Font';
		style.id='cs1';
		style.default='true';
	}
	PAR_STYLE={
		style.name='Diagram Heading';
		style.id='s1';
		text.font.style.bold='true';
		text.color.foreground='#990000';
		par.bkgr.opaque='true';
		par.bkgr.color='#F5F5F5';
		par.border.style='solid';
		par.border.color='#999999';
		par.padding.left='3';
		par.padding.right='3';
		par.padding.top='3';
		par.padding.bottom='3';
	}
	CHAR_STYLE={
		style.name='Hyperlink';
		style.id='cs2';
		text.decor.underline='true';
		text.color.foreground='#0000FF';
	}
	PAR_STYLE={
		style.name='Normal';
		style.id='s2';
		style.default='true';
	}
</STYLES>
<ROOT>
	<FOLDER>
		<BODY>
			<AREA_SEC>
				ON_OUTPUT_EXPR='setVar ("has-content-model-diagrams", true)'
				<AREA>
					<CTRL_GROUP>
						FMT={
							par.alignment='Center';
							par.margin.top='8';
							par.margin.bottom='8';
						}
						<CTRLS>
							<IMAGE_CTRL>
								FMT={
									image.option.allowRotation='true';
								}
								<DOC_HLINK>
									COND='imgMapElement.instanceOf("xs:attribute") ?\n  hasParamValue("doc.comp.diagram.links.attribute.global", "global")\n:\n! imgMapElement.instanceOf("xs:%localElement") || \nhasParamValue("doc.comp.diagram.links.element.local", "global")'
									ALT_HLINK
									HKEYS={
										'imgMapElement.id';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									ALT_HLINK
									HKEYS={
										'imgMapElement.id';
										'"local"';
										'rootElement.id';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									ALT_HLINK
									HKEYS={
										'imgMapElement.id';
										'"def"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									ALT_HLINK
									HKEYS={
										'imgMapElement.id';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									ALT_HLINK
									HKEYS={
										'imgMapElement.id';
										'"xml-source-location"';
									}
								</DOC_HLINK>
								IMAGE_TYPE='element-image'
							</IMAGE_CTRL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</BODY>
		<HEADER>
			<AREA_SEC>
				FMT={
					par.style='s1';
				}
				<AREA>
					<CTRL_GROUP>
						FMT={
							trow.bkgr.color='#CCCCFF';
						}
						<CTRLS>
							<LABEL>
								TEXT='Content Model Diagram'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</HEADER>
	</FOLDER>
</ROOT>
CHECKSUM='pAsl4nA+oGifx2lpw6pVvzBRscfChnbgSUQeIn74M0c'
</DOCFLEX_TEMPLATE>