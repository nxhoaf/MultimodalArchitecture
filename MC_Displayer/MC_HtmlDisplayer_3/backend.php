<?php

header("Cache-Control: no-cache, must-revalidate");
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
flush();

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Comet php backend</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>

<script type="text/javascript">
  // KHTML browser don't share javascripts between iframes
  var is_khtml = navigator.appName.match("Konqueror") || navigator.appVersion.match("KHTML");
  if (is_khtml)
  {
    var prototypejs = document.createElement('script');
    prototypejs.setAttribute('type','text/javascript');
    prototypejs.setAttribute('src','prototype.js');
    var head = document.getElementsByTagName('head');
    head[0].appendChild(prototypejs);
  }
  // load the comet object
  var comet = window.parent.comet;
</script>

<?php

 // //while(1) {
 	// Start
 	$data = "{'jsonrpc':'2.0','response':{'id':'r308','type':'3','status':'1','context':'c5','data':{'deliveryMode':'visual,cognitive'},'source':'www.berthele.com/soa2m/services/servicesCC/CCs_Orchestrator.php','target':'MC_500fa8f4968f8'}}";
	$response = 'comet.onDataReceived("' . $data . '");';
	sleep(10); 
  echo '<script type="text/javascript">';
  //echo 'comet.printServerTime('.time().');';
  echo $response;
  echo '</script>';
  ob_implicit_flush(true);
	ob_end_flush();
  flush(); // used to send the echoed data to the client
  //sleep(5); // a little break to unload the server CPU
 //}

 
 	sleep(3);
 // Pause
 $data = "{'jsonrpc':'2.0','response':{'id':'r308','type':'5','status':'1','context':'c5','data':{'deliveryMode':'visual,cognitive'},'source':'www.berthele.com/soa2m/services/servicesCC/CCs_Orchestrator.php','target':'MC_500fa8f4968f8'}}";
	$response = 'comet.onDataReceived("' . $data . '");';
	 
  echo '<script type="text/javascript">';
  //echo 'comet.printServerTime('.time().');';
  echo $response;
  echo '</script>';
  ob_implicit_flush(true);
	ob_end_flush();
  flush();
  
  
  sleep(3);
 // Resume
 $data = "{'jsonrpc':'2.0','response':{'id':'r308','type':'6','status':'1','context':'c5','data':{'deliveryMode':'visual,cognitive'},'source':'www.berthele.com/soa2m/services/servicesCC/CCs_Orchestrator.php','target':'MC_500fa8f4968f8'}}";
	$response = 'comet.onDataReceived("' . $data . '");';
	 
  echo '<script type="text/javascript">';
  //echo 'comet.printServerTime('.time().');';
  echo $response;
  echo '</script>';
  ob_implicit_flush(true);
	ob_end_flush();
  flush();
  
  
  
  sleep(3);
 // Cancel
 $data = "{'jsonrpc':'2.0','response':{'id':'r308','type':'4','status':'1','context':'c5','data':{'deliveryMode':'visual,cognitive'},'source':'www.berthele.com/soa2m/services/servicesCC/CCs_Orchestrator.php','target':'MC_500fa8f4968f8'}}";
	$response = 'comet.onDataReceived("' . $data . '");';
	 
  echo '<script type="text/javascript">';
  //echo 'comet.printServerTime('.time().');';
  echo $response;
  echo '</script>';
  ob_implicit_flush(true);
	ob_end_flush();
  flush();
  
   sleep(3);
 // Clear context
 $data = "{'jsonrpc':'2.0','response':{'id':'r308','type':'1','status':'1','context':'c5','data':{'deliveryMode':'visual,cognitive'},'source':'www.berthele.com/soa2m/services/servicesCC/CCs_Orchestrator.php','target':'MC_500fa8f4968f8'}}";
	$response = 'comet.onDataReceived("' . $data . '");';
	 
  echo '<script type="text/javascript">';
  //echo 'comet.printServerTime('.time().');';
  echo $response;
  echo '</script>';
  ob_implicit_flush(true);
	ob_end_flush();
  flush();
?>


</body>
</html>