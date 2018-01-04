<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="security" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title><spring:message code="${appProperties['app.title.key']}" text="Stream Flight Planner"/></title>
    <link rel="website icon" href="resources/img/${appProperties['app.favicon']}" type="image/x-icon" />
    <link type="text/css" href="resources/css/style.css?v=${buildNumber}" rel="stylesheet" />
    <script type="text/javascript">
    </script>
    <style type="text/css">
    </style>
</head>
<body class="ui-widget-content">
    <%@ include file="top.jsp" %>
</body>
</html>
