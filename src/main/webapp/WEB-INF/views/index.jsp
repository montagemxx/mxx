<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title><spring:message code="${appProperties['app.title.key']}" text="Stream Flight Planner"/></title>
    <link type="text/css" href="resources/css/jquery-ui-layout-1.4.0/layout-default.css" rel="stylesheet" />
    <link rel="website icon" href="resources/img/${appProperties['app.favicon']}" type="image/x-icon" />
    <link type="text/css" href="resources/css/jquery-ui-1.11.1/<c:out value="${defaultStyle}"/>/jquery-ui.css" rel="stylesheet" id="stylesheet" />
    <link type="text/css" href="resources/css/themes/<c:out value="${defaultStyle}"/>/style.css?v=${buildNumber}" rel="stylesheet" id="theme"/>
    <link type="text/css" href="resources/css/jqgrid-4.6.0/ui.jqgrid.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/wijmo-3.20142.45/jquery.wijmo.wijmenu.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/wijmo-3.20142.45/jquery.wijmo.wijtooltip.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/picklist.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/xToolsRenderDetails.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/fileinput.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/combobox.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/selectbox.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/EditGrid.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/style-ux.css" rel="stylesheet" />
    <link type="text/css" href="resources/css/style.css?v=${buildNumber}" rel="stylesheet" />
    <link type="text/css" href="resources/css/style-<c:out value="${defaultStyle}"/>.css?v=${buildNumber}" rel="stylesheet"/>
    <link rel="stylesheet" href="resources/css/font-awesome-4.4.0/css/font-awesome.min.css" />
    <script type="text/javascript" src="resources/js/requirejs/require.js?v=${buildNumber}"></script>
    <script type="text/javascript" src="resources/js/require-config.js?v=${buildNumber}"></script>
    <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_USERS', 'ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_PARTNERS')" var="isRoleAdmin"></security:authorize>
    <spring:eval expression="T(com.comcast.x1.authentication.partner.AuthenticationPartnerContext).getPartnerContext(null)" var="partnerContext"></spring:eval>
    <c:if test="${partnerContext ne null}">
    	<c:if test="${partnerContext.partner ne null}">
    		<c:set value="${partnerContext.partner.code}" var="currentPartnerCode" ></c:set>
    	</c:if>
    </c:if>
   
    <script type="text/javascript">
	    var appSystem='${appProperties['app.system']}';
	    var isAdmin=${isRoleAdmin};
	    var isTVE = typeof appSystem!== 'undefined' && appSystem=='TVE';
    </script>
    <script type="text/javascript">
        /*global require, document, window, location */
        require([
            'console',
            'jquery',
            'axl/page',
            'axl/tabs',
            'axl/menus',
            'axl/legacy-content',
            'help',
            'changes/Version',
            'changes/Summary',
            'changes/VersionHistory',
            'changes/LocatorsValidate',
            'changes/StationsValidate',
            'system/RecordingValidation',
            'system/StreamValidation',
            'system/CapacityPlanning',
            'system/BulkUpload',
            'streams/StreamsSummary',
            'streams/NationalStreamsSummary',
            'streams/StreamSourcesSummary',
            'streams/AddStream',
            'imports/ImportsSummary',
            'imports/ImportsValidate',
            'rdzs/RdzsSummary',
            'transcoders/TranscodersSummary',
            'packagers/PackagersSummary',
            'recorderManagers/RecorderManagerSummary',
            'locators/LocatorsSummary',
            'stations/WhitelistManagement',
            'stations/PegManagement',
            'stations/PPVManagement',
//            'xports',
            'admin/UserManagement',
            'admin/PartnerManagement',
            'delay',
            'versionUtil',
            'applicationUtil',
            'jqueryui',
            'jqueryuilayout',
            'jqueryhashchange',
            'purl'], function (console, $, Page, Tabs, Menus, LegacyContent, help, Version, ChangeSummary, VersionHistory, LocatorsValidate, StationsValidate,
                               RecordingValidation, StreamingValidation, CapacityPlanning, BulkUpload, 
                               StreamsSummary, NationalStreamsSummary, StreamSourcesSummary, AddStream,
                               ImportsSummary, ImportsValidate, RdzsSummary, TranscoderSummary, PackagersSummary,
                               RecorderManagerSummary, LocatorsSummary, WhitelistManagement, PegManagement, PPVManagement,/*xports,*/ UserManagement,
                               PartnerManagement, delay, versionUtil, applicationUtil) {
            'use strict';
            $(document).ready(function ($) {
                var streamsInited = false,
                    rdzsInited = false,
                    isNatRegion = $.url().param('transcoderFacility') === "<c:out value="${nationalRegionName}"/>" ? true : false,
                    $error = $('<div id="system-error-msg" title="Alert"></div>').appendTo('body').dialog({autoOpen: false, closeText: ''}),
                    
                    currentPartnerCode = function(){
                    	return '<c:out value="${currentPartnerCode}"/>';
                    },
                    isPartnerComcast = function(){
                    	var currPartnerCode = currentPartnerCode();
                    	return currPartnerCode === 'comcast' || currPartnerCode === 'comcast-mt';
                    },
                    generatePreActivateFunc = function(tabName) {
                        // menu items under the tab call this before they respond to the 'activate' notification
                        return function() {
                            $('div[id$="-accordions"]').hide(); // hide them all
                            $('#' + tabName + '-accordions').show();
                            $('#' + tabName + '-accordions' + '>div').hide();
                        }
                    },
                    packagersPreActivate = generatePreActivateFunc("packagers"),
                    recorderMgrsPreActivate = generatePreActivateFunc("recorderMgrs"),
                    locatorsPreActivate = generatePreActivateFunc("locators"),
                    changesPreActivate = generatePreActivateFunc("changes"),
                    systemPreActivate = generatePreActivateFunc("system"),
                    adminPreActivate = generatePreActivateFunc("admin"),
                    streamsPreActivate = generatePreActivateFunc("streams"),
                    importsPreActivate = generatePreActivateFunc("imports"),
                    	rdzsPreActivate = generatePreActivateFunc("rdzs"),
                    xcdrsPreActivate = generatePreActivateFunc("xcdrs"),
                    stationsPreActivate = generatePreActivateFunc("stations"),

                    hideVersionPickerAnd = function(preActivateFn){
                    	return function(){
	                    	if (typeof preActivateFn === "function") {
	                			preActivateFn();
	                		}
	                    	versionUtil.disableVersionPicker();
                    	}
                    },
                    showVersionPickerAnd = function(preActivateFn){
                    	return function(){
	                    	if (typeof preActivateFn === "function") {
	                			preActivateFn();
	                		}
	                    	versionUtil.enableVersionPicker();
                    	}
                    },
                    sfpMainMenu = [
						{
    						name: 'Changes',
    						hashId: 'changes',
    						isDefault: true,
    						Constructor: Menus,
    						options: {
        						showHeader: true
    						},
    						children: [
    						    {
                                    name: 'Version',
                                    hashId: 'version',
                                    isDefault: 1,
                                    isHidden: false,
                                    Constructor: Version,
                                    options: {
                                        versionUrl: 'version/' + $.url().param('transcoderFacility'),
                                        versionAddUrl: 'version/' + $.url().param('transcoderFacility') + '/add',
                                        versionUpdateUrl: 'version/' + $.url().param('transcoderFacility') + '/update',
                                        versionDeleteUrl: 'version/' + $.url().param('transcoderFacility') + '/delete',
                                        // <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_METADATA')">
                                        versionCreator: true,
                                        // </security:authorize>
                                        helpUrl: help.getUrl('Version'),
                                        preActivate: showVersionPickerAnd(changesPreActivate),
                                        $error: $error,
                                    }
                                },
                                {
                                    name: 'Summary',
                                    hashId: 'changesummary',
                                    isDefault: 2,
                                    isHidden: false,
                                    Constructor: ChangeSummary,
                                    options: {
                                    	url: 'changes/' + $.url().param('transcoderFacility'),
                                        details: '#changes-accordions',
                                        isNatRegion: isNatRegion,
                                        // <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_METADATA','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_RDZS')">
                                        rdzCreator: true,
                                        // </security:authorize>
                                     	// <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_TRANSCODERS_WRITE')">
                                        transcoderManager: true,
                                        // </security:authorize>
                                        rmUpdatesSupportedUrl: 'recorderManager/' + $.url().param('transcoderFacility') + '/updatessupported',//TODO verify RM write access?
                                        helpUrl: help.getUrl('ChangeSummary'),
                                        preActivate: showVersionPickerAnd(changesPreActivate),
                                        $error: $error,
                                    }
                                },
                                {
                                	name: 'History',
                                	hashId: 'versionHistory',
                                	isDefault: 3,
                                	isHidden: false,
                                	Constructor: VersionHistory,
                                	options: {
                                		url: 'versionHistory/' + $.url().param('transcoderFacility'),
                                		details: '#changes-accordions',
                                		helpUrl: help.getUrl('VersionHistory'),
                                		preActivate: hideVersionPickerAnd(changesPreActivate),
                                		$error: $error
                                	}
                                },
	                            {
	                                name: 'Validate Locators',
	                                hashId: 'validate',
	                                isDefault: 4,
	                                Constructor: LocatorsValidate,
	                                options: {
	                                    url: 'media/' + $.url().param('transcoderFacility') + '/validate',
	                                    alignUrl: 'media/' + $.url().param('transcoderFacility') + '/align',
	                                    rmUpdatesSupportedUrl: 'recorderManager/' + $.url().param('transcoderFacility') + '/updatessupported',
	                                    // <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_LOCATORS')">
	                                    locatorManager: true,
	                                    // </security:authorize>
	                                    helpUrl: help.getUrl('LocatorsValidate'),
	                                    details: '#changes-accordions',
	                                    preActivate: hideVersionPickerAnd(changesPreActivate),
	                                    $error: $error
	                                }
	                            },
	                            {
	                                name: 'Validate Mapping',
	                                hashId: 'validateStationMapping',
	                                isDefault: 5,
	                                Constructor: StationsValidate,
	                                options: {
	                                    url: 'stationmapping/' + $.url().param('transcoderFacility'),
	                                    // <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_STREAMS')">
	                                    streamManager: true,
	                                    // </security:authorize>,
	                            		helpUrl: help.getUrl('StationsValidate'),
	                                    details: '#changes-accordions',
	                                    preActivate: hideVersionPickerAnd(changesPreActivate),
	                                    $error: $error
	                                }
	                            }
							]
						},
                        {
                            name: 'System',
                            hashId: 'system',
                            isDefault: false,
                            Constructor: Menus,
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'Capacity Planning',
                                    hashId: 'planning',
                                    isDefault: 1,
                                    Constructor: CapacityPlanning,
                                    options: {
                                    	planningUrl: 'system/' + $.url().param('transcoderFacility') + '/planning',
                                        helpUrl: help.getUrl('SystemCapacityPlanning'),
                                        details: '#system-accordions',
                                        preActivate: hideVersionPickerAnd(systemPreActivate),
                                        $error: $error,
                                    }
                                },
                                {
                                    name: 'Recording Validation',
                                    hashId: 'rec-vld',
                                    isHidden: isNatRegion,
                                    Constructor: RecordingValidation,
                                    options: {
                                        hasReload: true,
                                        recmgrUrl: 'recmgr/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('SystemRecordingValidation'),
                                        details: '#system-accordions',
                                        preActivate: hideVersionPickerAnd(systemPreActivate),
                                        $error: $error,
                                    }
                                },
                                {
                                    name: 'Streaming Validation',
                                    hashId: 'strm-vld',
                                    Constructor: StreamingValidation,
                                    options: {
                                        streamingVldUrl: 'system/' + $.url().param('transcoderFacility') + '/streamingvalidation',
                                        helpUrl: help.getUrl('SystemStreamingValidation'),
                                        details: '#system-accordions',
                                        preActivate: hideVersionPickerAnd(systemPreActivate),
                                        $error: $error,
                                    }
                                },
                                {
                                    name: 'Bulk Upload',
                                    hashId: 'upload',
                                    isDefault: 2,
                                    isDisabled: !versionUtil.isEditable(),
                                    Constructor: BulkUpload,
                                    options: {
                                        // <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_METADATA','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_RDZS')">
                                        rdzCreator: true,
                                        // </security:authorize>
                                        uploadUrl: 'system/' + $.url().param('transcoderFacility') + '/bulkupload',
                                        rmUpdatesSupportedUrl: 'recorderManager/' + $.url().param('transcoderFacility') + '/updatessupported',
                                        helpUrl: help.getUrl('SystemBulkUpload'),
                                        details: '#system-accordions',
                                        preActivate: showVersionPickerAnd(systemPreActivate),
                                        showUnivrstyGrid: "${appProperties['show.university.grid']}" !== 'false',
                                        $error: $error,
                                    }
                                }
                            ]
                        },
                        {
                        	name:'Logical Streams',
                       		hashId: 'streams',
                        	isDefault: false,
                        	Constructor: Menus,
                        	options: {
                            	showHeader: true
                        	},
                        	children: [
                           		{
	                                name: 'Transcoder Facility Summary',
	                                hashId: 'streamssummary',
	                                isDefault: 1,
	                                resetOn: ['streamsourcessummary','addstream'],
	                                Constructor: StreamsSummary,
	                                options: {
	                                    // <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_STREAMS','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_LOCATORS')">
	                                    streamManager: true,
	                                    // </security:authorize>
	                                    url: 'logicalStreams/' + $.url().param('transcoderFacility'),
	                                    versionAddUrl: 'version/' + $.url().param('transcoderFacility')+'/add',
	                                    details: '#streams-accordions',
	                                    isNatRegion: isNatRegion,
	                                    helpUrl: help.getUrl('LogicalStreamsRegionalSummary'),
	                                    defaultNatRegion: "<c:out value="${nationalRegionName}"/>",
	                                    stationSearch: 'search/' + $.url().param('transcoderFacility') + '/station',
	                                    subGridAddOnly: "${appProperties['stream.subGridAddOnly']}" !== 'false',
	                                    subGridUpdateOnly: "${appProperties['stream.subGridUpdateOnly']}" !== 'false',
	                                    displayLocatorData: isTVE && isPartnerComcast(),
	                                    dataUpdated: function () {
	                                        console.log('streams has updated');
	                                        if (rdzsInited) {
	                                            rdzs.remove();
	                                            rdzsInited = false;
	                                        }
	                                    },
	                                    preActivate: showVersionPickerAnd(streamsPreActivate)
	                                }
	                            },
	                            {
	                                name: 'National Summary',
	                                hashId: 'nationalstreamssummary',
	                                isHidden: isNatRegion,
	                                Constructor: NationalStreamsSummary,
	                                options: {
	                                	// <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_STREAMS','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_LOCATORS')">
	                                    streamManager: true,
	                                    // </security:authorize>
	                                    url: 'logicalStreams/' + $.url().param('transcoderFacility'),
	                                    details: '#streams-accordions',
	                                    isNatRegion: isNatRegion,
	                                    helpUrl: help.getUrl('LogicalStreamNationalSummary'),
	                                    defaultNatRegion: "<c:out value="${nationalRegionName}"/>",
	                                    stationSearch: 'search/' + $.url().param('transcoderFacility') + '/station',
	                                    subGridAddOnly: "${appProperties['stream.subGridAddOnly']}" !== 'false',
	                                    subGridUpdateOnly: "${appProperties['stream.subGridUpdateOnly']}" !== 'false',
	                                    dataUpdated: function () {
	                                        console.log('streams has updated');
	                                        if (rdzsInited) {
	                                            rdzs.remove();
	                                            rdzsInited = false;
	                                        }
	                                    },
	                                    preActivate: showVersionPickerAnd(streamsPreActivate)
	                                }
	                            },
	                            {
	                                name: 'Stream Source',
	                                hashId: 'streamsourcessummary',
	                                isHidden: !isNatRegion,
	                                resetOn: ['addstream'],
	                                Constructor: StreamSourcesSummary,
	                                options: {
	                                    // <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_STREAMS','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_LOCATORS')">
	                                    streamManager: true,
	                                    // </security:authorize>
	                                    url: 'logicalStreams/' + $.url().param('transcoderFacility'),
	                                    details: '#streams-accordions',
	                                    helpUrl: help.getUrl('LogicalStreamSourcesSummary'),
	                                    defaultNatRegion: "<c:out value="${nationalRegionName}"/>",
	                                    preActivate: showVersionPickerAnd(streamsPreActivate)
	                                }
	                            },
	                            {
	                                name: 'Add a Stream',
	                                hashId: 'addstream',
	                                isHidden: !isNatRegion,
	                                isDisabled : !versionUtil.isEditable() || applicationUtil.isViewerRole(),
	                                Constructor: AddStream,
	                                options: {
	                                	// <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_STREAMS','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_LOCATORS')">
	                                    streamManager: versionUtil.isEditable(),
	                                    // </security:authorize>
	                                	
	                                    url: 'addStream/' + $.url().param('transcoderFacility'),
	                                    stationSearch: 'search/' + $.url().param('transcoderFacility') + '/station',
	                                    productContexts: 'search/' + $.url().param('transcoderFacility') + '/pcs',
	                                    details: '#streams-accordions',
	                                    helpUrl: help.getUrl('LogicalStreamAddStream'),
	                                    preActivate: hideVersionPickerAnd(streamsPreActivate)
	                                }
	                            }
                            ]
                        },
                        {
                            name: 'Source Network Transports',
                            hashId: 'imports',
                            isDefault: false,
                            isDisabled: false,
                            Constructor: Menus,
                            resetOn: ['streams'],
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'Summary',
                                    hashId: 'summary',
                                    isDefault: 1,
                                    Constructor: ImportsSummary,
                                    options: {
                                        // <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_SOURCE_TRANSPORTS')">
                                        streamManager: true,
                                        // </security:authorize>
                                        url: 'sbrTransports/' + $.url().param('transcoderFacility'),
                                        versionAddUrl: 'version/' + $.url().param('transcoderFacility')+'/add',
                                        helpUrl: help.getUrl('SourceNetworkTransportsSummary'),
                                        details: '#imports-accordions',
                                        facilityCode: $.url().param('transcoderFacility'),
                                        defaultNatRegion: "<c:out value="${nationalRegionName}"/>", 
                                        preActivate: showVersionPickerAnd(importsPreActivate),
                                        $error: $error
                                   }
                                },
                                {
                                    name: 'Validate',
                                    hashId: 'validate',
                                    isDefault: 2,
                                    isHidden: isNatRegion,
                                    Constructor: ImportsValidate,
                                    options: {
                                        url: 'sbrTransports/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('SourceNetworkTransportsSummary'),
                                        details: '#imports-accordions',
                                        preActivate: showVersionPickerAnd(importsPreActivate),
                                        $error: $error
                                    }
                                }
                        	]
                        },
                        {
                            name: 'RDZs',
                            hashId: 'rdzs',
                            isDefault: false,
                            Constructor: Menus,
                            isHidden:isTVE || isNatRegion,
                            options: {
                                showHeader: true
                            },
                            children: [
								{
	    							name: 'Summary',
	    							hashId: 'rdzssummary',
	    							isDefault: 2,
	    							isHidden: isNatRegion,
	    							Constructor: RdzsSummary,
	    							options: {
	    								// <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_METADATA','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_RDZS')">
	                                    rdzCreator: true,
	                                    // </security:authorize>        
	                                    url: 'rdz/' + $.url().param('transcoderFacility'),
	                                    helpUrl: help.getUrl('RDZs'),
	                                    details: '#rdzs-accordions',
	                                    isNatRegion: isNatRegion,
	                                    preActivate: showVersionPickerAnd(rdzsPreActivate),
	                                    dataUpdated: function () {
	                                        console.log('rdzs has updated');
	                                        if (streamsInited) {
	                                            streams.remove();
	                                            streamsInited = false;
	                                        }
	                                    }
	    							}
								}
                            ]
                        },
                        {
                            name: 'Transcoders',
                            hashId: 'xcdrs',
                            isDefault: false,
                            isDisabled: false,
                            Constructor: Menus,
                            isHidden:isTVE,
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'Summary',
                                    hashId: 'summary',
                                    isDefault: 1,
                                    Constructor: TranscoderSummary,
                                    options: {
                                    	 // <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_DELIVERY','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_TRANSCODERS')">
                                        transcoderManager: true,
                                        // </security:authorize>
                                        details: '#xcdrs-accordions',
                                        url: 'transcoders/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('TranscodersSummary'),
                                        outputMulticastUdpPort: "${appProperties['transcoder.outputmulticastudpport']}",
                                        streamSearch: 'search/' + $.url().param('transcoderFacility') + '/stream',
                                        preActivate: hideVersionPickerAnd(xcdrsPreActivate)
                                   }
                                }
                        	]
                        },
                        {
	                        name: 'Packagers',
	                        hashId: 'packagers',
	                        isDefault: false,
	                        isDisabled: false,
	                        Constructor: Menus,
	                        isHidden:isTVE,
	                        options: {
	                            showHeader: true
	                        },
	                        children: [
	                            {
	                                name: 'Summary',
	                                hashId: 'summary',
	                                isDefault: 1,
	                                Constructor: PackagersSummary,
	                                options: {
	                                	url: 'packagers/' + $.url().param('transcoderFacility'),
	                                    helpUrl: help.getUrl('PackagersSummary'),
	                                    details: '#packagers-accordions',
	                                    preActivate: hideVersionPickerAnd(packagersPreActivate),
	                                    $error: $error
	                               }
	                            }                      
	                    	]
	                    },
                        {
	                    	name: 'Recorder Managers',
                            hashId: 'rec-mgr',
                            isDefault: false,
                            isDisabled: false,
                            isHidden: isTVE,
                            Constructor: Menus,
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'Summary',
                                    hashId: 'summary',
                                    isDefault: 1,
                                    Constructor: RecorderManagerSummary,
                                    options: {
                                    	// <security:authorize access="hasAnyAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_MANAGE_DELIVERY','ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_RECORDER_MANAGERS')">
                                        recorderManagerConfigurer: true,
                                        // </security:authorize>
                                        details: '#recorderMgrs-accordions',
                                        url: 'recorderManager/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('RecorderManagerSummary'),
                                        preActivate: hideVersionPickerAnd(recorderMgrsPreActivate),
                                        $error: $error
                                   }
                                }
                            ]
                        },
                        {
	                        name: 'Locators',
	                        hashId: 'locators',
	                        isDefault: false,
	                        isDisabled: false,
	                        Constructor: Menus,
	                        options: {
	                            showHeader: true
	                        },
	                        children: [
	                            {
	                                name: 'Summary',
	                                hashId: 'summary',
	                                isDefault: 1,
	                                Constructor: LocatorsSummary,
	                                options: {
	                                	url: 'locators/' + $.url().param('transcoderFacility'),
	                                    helpUrl: help.getUrl('LocatorsSummary'),
	                                    details: '#locators-accordions',
	                                    preActivate: showVersionPickerAnd(locatorsPreActivate),
	                                    $error: $error
	                               }
	                            }                      
	                    	]
	                    },
                        {
                            name: 'Stations',
                            hashId: 'stations',
                            isDefault: false,
                            isDisabled: false,
                            Constructor: Menus,
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'SBR',
                                    hashId: 'peg-manage',
                                    isDefault: 1,
                                    isHidden: !isPartnerComcast(),
                                    Constructor: PegManagement,
                                    options: {
                                     	// <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_SINGLE_BIT_RATE')">
                                        stationManager: true,
                                        // </security:authorize>
                                        url: 'pegs',
                                        helpUrl: help.getUrl('PegManagement'),
                                        details: '#stations-accordions',
                                        preActivate: hideVersionPickerAnd(stationsPreActivate)
                                    }
                                },
                                {
                                    name: 'Whitelist',
                                    hashId: 'whitelist-manage',
                                    isDefault: 2,
                                    Constructor: WhitelistManagement,
                                    options: {
                                     	// <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_WHITELIST')">
                                        stationManager: true,
                                        // </security:authorize>
                                        url: 'whitelist',
                                        helpUrl: help.getUrl('WhitelistManagement'),
                                        details: '#stations-accordions',
                                        preActivate: hideVersionPickerAnd(stationsPreActivate),
                                        $error: $error,
                                        isPartnerComcast: isPartnerComcast()
                                    }
                                },
                                {
                                    name: 'IP PPV',
                                    hashId: 'ppv-manage',
                                    isDefault: 3,
                                    isHidden: isTVE,
                                    Constructor: PPVManagement,
                                    options: {
                                     	// <security:authorize access="hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_PAY_PER_VIEW')">
                                        stationManager: true,
                                        // </security:authorize>
                                        url: 'payPerViewStations',
                                        helpUrl: help.getUrl('PPVManagement'),
                                        details: '#stations-accordions',
                                        preActivate: hideVersionPickerAnd(stationsPreActivate)
                                    }
                                }
                            ]
                        },
                        {
                            name: 'Administration',
                            hashId: 'admin',
                            isDefault: false,
                            isDisabled: false,
                            isHidden: !isAdmin,
                            Constructor: Menus,
                            options: {
                                showHeader: true
                            },
                            children: [
                                {
                                    name: 'Users',
                                    hashId: 'user-manage',
                                    isDefault: 1,
                                 	// <security:authorize access="!hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_USERS')">
                                    isHidden: true,
                                    // </security:authorize>
                                    Constructor: UserManagement,
                                    options: {
                                        url: 'admin/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('UserManagement'),
                                        details: '#admin-accordions',
                                        //showAccordion: false,
                                        preActivate: hideVersionPickerAnd(adminPreActivate)
                                    }
                                },
                                {
                                    name: 'Partners',
                                    hashId: 'partner-manage',
                                 	// <security:authorize access="!hasAuthority('ROLE_CHQCDC-XDM_FLIGHTPLANNER_RIGHT_MANAGE_PARTNERS')">
                                    isHidden: true,
                                    // </security:authorize>
                                    Constructor: PartnerManagement,
                                    options: {
                                        url: 'admin/' + $.url().param('transcoderFacility'),
                                        helpUrl: help.getUrl('PartnerManagement'),
                                        details: '#admin-accordions',
                                        preActivate: hideVersionPickerAnd(adminPreActivate)
                                    }
                                }
                            ]
                        }
                    ],
                    sfpPage = new Page('top-tabs', sfpMainMenu, Tabs);

                // remove default window close button ( X ) from dialog header
                $error.parent().find('.ui-dialog-titlebar-close').remove();

                $('body').layout({
                    onresize_end: function (name, element, state, options) {
                        if (name === 'center') {
                            console.debug('layout onresize() ' + name);
                            sfpPage.resize();
                        }
                    }
                });
                
                $(document).ajaxSend(function( event, xhr, settings ) {
                	//console.log(settings.url);
                	if ( settings.url.indexOf("?") == -1){
                		settings.url += "?";
                	} else {
                		if ( !settings.url.endsWith("&") ){
                			settings.url += "&";
                		}
                	}
                	var selectedVersion = $('#versionSelect').val();
                	console.log('selectedVersion:'+selectedVersion);
                	settings.url += "version="+selectedVersion;
                	//console.log(settings.url);
                });
                	

                $(document).ajaxComplete(function (event, jqXHR, ajaxOptions) {
                    //console.log('ajaxComplete()');
                    //console.log(event);
                    //console.log(jqXHR);
                    //console.log('Content-Type: ' + jqXHR.getResponseHeader('Content-Type'));
                    //console.log('X-Requires-Auth: ' + jqXHR.getResponseHeader('X-Requires-Auth'));
                    //console.log(ajaxOptions);

                    if (jqXHR.getResponseHeader('X-Requires-Auth') === 'true') {
                        window.location.reload();
                    }
                });

                sfpPage.render();
            });
        });
    </script>
    <c:if test="${(appProperties['piwik.site.id'] ne null) && (appProperties['piwik.site.url'] ne null)}">
        <script type="text/javascript">
            var _paq = _paq || [];
            /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
            _paq.push(['trackPageView']);
            _paq.push(['enableLinkTracking']);
            (function() {
                var u='${appProperties['piwik.site.url']}';
                _paq.push(['setTrackerUrl', u+'piwik.php']);
                _paq.push(['setSiteId', '' + ${appProperties['piwik.site.id']}]);
                var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
            })();
            window.addEventListener('hashchange', function() {
                _paq.push(['setCustomUrl', '/' + window.location.hash.substr(1)]);
                _paq.push(['setDocumentTitle', window.location.hash.substr(1)]);
                _paq.push(['trackPageView']);
            });
        </script>
    </c:if>
</head>
<body class="ui-widget-content">

    <%@ include file="includes/div-north.jsp" %>
    <div class="ui-layout-center ui-widget-content" id="top-tabs" style="display: none;">
    </div>
    <div class="ui-layout-west ui-widget-content" style="overflow: hidden">
    	<div id="changes-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="system-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="xcdrs-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="streams-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="rdzs-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="packagers-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="recorderMgrs-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="locators-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="imports-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="admin-accordions" class="basic" style="height: 100%;">
        </div>
        <div id="stations-accordions" class="basic" style="height: 100%;">
        </div>
    </div>
    <div id="file-export-container"></div>
</body>
</html>
