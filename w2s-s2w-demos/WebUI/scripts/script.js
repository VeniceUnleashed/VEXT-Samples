var el = document.getElementById('marker');

function ShowMarker(show){
	if (show) {
		el.style.display = 'block';
	} else {
		el.style.display = 'none';
	}
}

function UpdateMarker(x, y){
	el.style.left = x + 'px';
	el.style.top = y + 'px';
}