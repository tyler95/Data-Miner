
function ShowPageInfoInConsole() {

	console.log( "this page contains: "
		+ window.document.anchors.length + " anchors, "
		+ window.document.images.length + " images, and "
		+ window.document.links.length + " links." )
		
	console.log( "the document url is: " + window.document.URL )
	
	console.log( "the document title is: " + window.document.title )

}

function logIn() {
    browser.eval("document.getElementById('username').value = 'blank109'")
    
    browser.eval("document.getElementById('password').value = 'Tygus@95'")
    
    browser.eval("Validations()")
}

console.log("page load for " + program + " " + version)


