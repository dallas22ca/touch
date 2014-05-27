$(document).on "keypress", "#home_long_address", (e) ->
	code = if e.keyCode then e.keyCode else e.which
	false if code == 13

$(document).on "click", ".show_map", ->
	$("#map_wrapper, .mini_content_wrapper").toggle()
	Homes.loadWithGoogle "Homes.initMap"
	false

@Homes =
	init: ->
		if $("#home_long_address").length
			Homes.loadWithGoogle "Homes.initHomes"

	loadWithGoogle: (callback_name) ->
		if typeof google == "undefined"
			$.getScript "https://maps.googleapis.com/maps/api/js?v=3&sensor=true&libraries=places&callback=#{callback_name}"
		else
			fn = window
			for ns in callback_name.split(".")
				fn = fn[ns]
			fn()
	
	initHomes: ->
		autocomplete = new google.maps.places.Autocomplete $("#home_long_address")[0],
			types: ['geocode']
		
		google.maps.event.addListener autocomplete, "place_changed", ->
			address_components = autocomplete.getPlace().address_components
			location_components = autocomplete.getPlace().geometry.location
			components = {}
			address_fields = ["street_number", "route", "administrative_area_level_1", "locality", "country", "postal_code", "postal_code_prefix"]
			location_fields = ["A", "k"]
		
			for component in address_components
				for field in address_fields
					if typeof component.types != "undefined" && component.types[0] == field
						components[field] = component.long_name

			$("[data-address]").val "#{components["street_number"]} #{components["route"]}"
			$("[data-city]").val components["locality"]
			$("[data-province]").val components["administrative_area_level_1"]
			$("[data-country]").val components["country"]

			$("[data-latitude]").val location_components.lat()
			$("[data-longitude]").val location_components.lng()
			
			if typeof components["postal_code"] != "undefined"
				$("[data-postal-code]").val components["postal_code"]
			
			if typeof components["postal_code_prefix"] != "undefined"
				$("[data-postal-code]").val components["postal_code_prefix"]
	
	createMarker: (map, type, data, bounds = false) ->
		if data.latitude != null
			if type == "home"
				position = new google.maps.LatLng data.latitude, data.longitude
				title = data.address
				image = "/imgs/map/home.png"
				colour = "1123A4"
			else
				loc = data.geometry.location
				position = new google.maps.LatLng loc.lat(), loc.lng()
				title = data.name
				image = "/imgs/map/school.png"
				
			bounds.extend position if bounds
	
			new google.maps.Marker
				position: position
				map: map
				icon: image
				title: title
		
	initMap: ->
		mapOptions = {}
		map = new google.maps.Map $("#map")[0], mapOptions
		bounds = new google.maps.LatLngBounds()
		
		for home in $("#map_wrapper").data("homes")
			Homes.createMarker map, "home", home, bounds
		
		map.setCenter bounds.getCenter()
		map.fitBounds bounds
		
		# service = new google.maps.places.PlacesService map
		# service.nearbySearch
		# 	location: bounds.getCenter()
		# 	radius: 1000
		# 	types: ["school"]
		# , (results, status) ->
		# 	if status == google.maps.places.PlacesServiceStatus.OK
		# 		for place in results
		# 			Homes.createMarker map, "place", place